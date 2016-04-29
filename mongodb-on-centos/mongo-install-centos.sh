
#Modify Sudoers file to not require tty for shell script execution on CentOS
# sudo sed -i '/Defaults[[:space:]]\+requiretty/s/^/#/' /etc/sudoers

# Enable write access to the mongodb.repo and configure it for installation

#sudo chmod 777 /etc/yum.repos.d/mongodb.repo
touch /etc/yum.repos.d/mongodb-enterprise.repo 
echo "[mongodb-org-3.0]" >> /etc/yum.repos.d/mongodb-enterprise.repo 
echo "name=MongoDB Repository" >> /etc/yum.repos.d/mongodb-enterprise.repo 
echo "baseurl=https://repo.mongodb.com/yum/redhat/\$releasever/mongodb-enterprise/stable/\$basearch/" >> /etc/yum.repos.d/mongodb-enterprise.repo
echo "gpgcheck=1" >> /etc/yum.repos.d/mongodb-enterprise.repo
echo "enabled=1" >> /etc/yum.repos.d/mongodb-enterprise.repo
echo "gpgkey=https://www.mongodb.org/static/pgp/server-3.2.asc" >>  /etc/yum.repos.d/mongodb-enterprise.repo
# Install updates
yum -y update

#Install Mongo DB, xfs driver, & SELINUX management tools
yum install -y xfsprogs mongodb-enterprise policycoreutils-python

#enable access fo relevant ports for SELINUX
semanage port -a -t mongod_port_t -p tcp 27017

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
cp /etc/security/limits.d/90-nproc.conf /etc/security/limits.d/99-mongodb-nproc.conf
sed -i 's/1024/32000/g' /etc/security/limits.d/99-mongodb-nproc.conf

#start mongodb
service mongod start

#set mongo to start on reboot
chkconfig mongod on
