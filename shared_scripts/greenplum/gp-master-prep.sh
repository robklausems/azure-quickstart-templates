
#Modify Sudoers file to not require tty for shell script execution on CentOS
# sudo sed -i '/Defaults[[:space:]]\+requiretty/s/^/#/' /etc/sudoers

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

#set limits
touch /etc/security/limits.d/99-greenplum-nproc.conf
echo "* soft nofile 65536" >> /etc/security/limits.d/99-greenplum-nproc.conf
echo "* hard nofile 65536" >> /etc/security/limits.d/99-greenplum-nproc.conf
echo "* soft nproc 131072" >> /etc/security/limits.d/99-greenplum-nproc.conf
echo "* hard nproc 131072"  >> /etc/security/limits.d/99-greenplum-nproc.conf

#Install xfs driver, & SELINUX management tools
yum install -y xfsprogs mdadm policycoreutils-python microsoft-hyper-v

#disable iptables
/sbin/chkconfig iptables off 

#disable SELINUX
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config 

#set readahead
/sbin/blockdev --setra 16384 /dev/sda
/sbin/blockdev --setra 16384 /dev/sdb

#enable root login for ssh. yeah, I know....
sed -i 's/#PermitRootLogin/PermitRootLogin/g' /etc/ssh/sshd_config

#various /etc/sysctl.conf changes...
sed -i 's/kernel.sysrq/#kernel.sysrq/g' /etc/sysctl.conf 
sed -i 's/kernel.shmmax/#kernel.shmmax/g' /etc/sysctl.conf
sed -i 's/kernel.shmall/#kernel.shmall/g' /etc/sysctl.conf

echo "kernel.sysrq = 1" >> /etc/sysctl.conf
echo "kernel.shmmax = 500000000" >> /etc/sysctl.conf
echo "kernel.shmall = 4000000000" >> /etc/sysctl.conf
echo "kernel.shmmni = 4096" >> /etc/sysctl.conf
echo "kernel.sem = 250 512000 100 2048" >> /etc/sysctl.conf
echo "kernel.msgmni = 2048" >> /etc/sysctl.conf
echo "net.ipv4.tcp_tw_recycle = 1" >> /etc/sysctl.conf
echo "net.ipv4.tcp_max_syn_backlog = 4096" >> /etc/sysctl.conf
echo "net.ipv4.conf.all.arp_filter = 1" >> /etc/sysctl.conf
echo "net.ipv4.ip_local_port_range = 1025 65535" >> /etc/sysctl.conf
echo "net.core.netdev_max_backlog = 10000" >> /etc/sysctl.conf
echo "net.core.rmem_max = 2097152" >> /etc/sysctl.conf
echo "net.core.wmem_max = 2097152" >> /etc/sysctl.conf
echo "vm.overcommit_memory = 2" >> /etc/sysctl.conf

#enable access fo relevant ports for SELINUX
#semanage port -a -t greenplum_port_t -p tcp 99999

#format & mount the data storage disk
#echo "\nPartitioning data drive...\n"
#echo -e "n\np\n1\n\n\nw" | fdisk -c /dev/sdc
#echo "\nFormatting /dev/sdc1\n"
#mkfs -t xfs /dev/sdc1
#mkdir /data
#mount /dev/sdc1 /data
#chown gpadmin:gpadmin /data
#echo "\nGetting UUID info...\n"
#blkid -u filesystem /dev/sdc1 > ~/blkinfo.txt
#cat ~/blkinfo.txt | awk -F "[= ]" '{print $3}'|tr -d "\"" > ~/UUID.txt
#cat ~/UUID.txt | sed "s/.\{0\}/UUID=/" | sed "s/$/\t\/data\txfs\trw,noatime,inode64,allocsize=16m \t0 0/" > ~/newUUID.txt
#echo "\nWriting fstab info...\n"
#cat ~/newUUID.txt >> /etc/fstab

#done
exit 0