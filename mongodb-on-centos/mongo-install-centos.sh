
#Modify Sudoers file to not require tty for shell script execution on CentOS
# sudo sed -i '/Defaults[[:space:]]\+requiretty/s/^/#/' /etc/sudoers

# Enable write access to the mongodb.repo and configure it for installation

#sudo chmod 777 /etc/yum.repos.d/mongodb.repo
touch /etc/yum.repos.d/mongodb-enterprise.repo 
echo "[mongodb-enterprise]" >> /etc/yum.repos.d/mongodb-enterprise.repo 
echo "name=MongoDB Enterprise Repository" >> /etc/yum.repos.d/mongodb-enterprise.repo 
echo "baseurl=https://repo.mongodb.com/yum/redhat/\$releasever/mongodb-enterprise/stable/\$basearch/" >> /etc/yum.repos.d/mongodb-enterprise.repo
echo "gpgcheck=1" >> /etc/yum.repos.d/mongodb-enterprise.repo
echo "enabled=1" >> /etc/yum.repos.d/mongodb-enterprise.repo
echo "gpgkey=https://www.mongodb.org/static/pgp/server-3.2.asc" >>  /etc/yum.repos.d/mongodb-enterprise.repo
# Install updates
#yum -y update

# Disable THP on a running system
echo never > /sys/kernel/mm/transparent_hugepage/enabled
echo never > /sys/kernel/mm/transparent_hugepage/defrag

# Disable THP upon reboot
cp -p /etc/rc.d/rc.local /etc/rc.d/rc.local.`date +%Y%m%d-%H:%M`
sed -i -e '$i \ if test -f /sys/kernel/mm/transparent_hugepage/enabled; then \
		 echo never > /sys/kernel/mm/transparent_hugepage/enabled \
	  fi \ \
	if test -f /sys/kernel/mm/transparent_hugepage/defrag; then \
	   echo never > /sys/kernel/mm/transparent_hugepage/defrag \
	fi \
	\n' /etc/rc.d/rc.local
chmod +x /etc/rc.d/rc.local

#set soft rlimits
ulimit -u 32000

#set soft rlimits when sytem reboots
cp /etc/security/limits.d/90-nproc.conf /etc/security/limits.d/99-mongodb-nproc.conf
sed -i 's/1024/32000/g' /etc/security/limits.d/99-mongodb-nproc.conf

#enable access fo relevant ports for SELINUX
semanage port -a -t mongod_port_t -p tcp 27017

#format & mount the data storage disk
echo -e "n\np\n1\n\n\nw" | fdisk /dev/sdc
mkfs -t xfs /dev/sdc1
mkdir /data
mount /dev/sdc1 /data
read UUID FS_TYPE < <(blkid -u filesystem /dev/sdc1|awk -F "[= ]" '{print $3" "$5}'|tr -d "\"")
LINE="UUID=\"${UUID}\"\t/data\txfs\tnoatime,nodiratime,nodev,noexec,nosuid\t1 2"
echo -e "${LINE}" >> /etc/fstab

#Install Mongo DB, xfs driver, & SELINUX management tools
yum install -y xfsprogs mongodb-enterprise policycoreutils-python
chown mongod:mongod /data

#listen on all ports
sed -i 's/bindIp/#bindIp/g' /etc/mongod.conf

#mod mongo conf to use /data for data
sed -i 's/dbPath: \/var\/lib\/mongo/dbPath: \/data/g' /etc/mongod.conf

#start mongodb
service mongod start

#set mongo to start on reboot
chkconfig mongod on
