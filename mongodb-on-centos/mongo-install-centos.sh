
#Modify Sudoers file to not require tty for shell script execution on CentOS
# sudo sed -i '/Defaults[[:space:]]\+requiretty/s/^/#/' /etc/sudoers

# Enable write access to the mongodb.repo and configure it for installation

#sudo chmod 777 /etc/yum.repos.d/mongodb.repo
touch /etc/yum.repos.d/mongodb-enterprise.repo 
echo "[mongodb-org-3.0]" >> /etc/yum.repos.d/mongodb-enterprise.repo 
echo "name=MongoDB Repository" >> /etc/yum.repos.d/mongodb-enterprise.repo 
echo "baseurl=https://repo.mongodb.com/yum/redhat/$releasever/mongodb-enterprise/stable/$basearch/" >> /etc/yum.repos.d/mongodb-enterprise.repo
echo "gpgcheck=1" >> /etc/yum.repos.d/mongodb-enterprise.repo
echo "enabled=1" >> /etc/yum.repos.d/mongodb-enterprise.repo
echo "gpgkey=https://www.mongodb.org/static/pgp/server-3.2.asc" >>  /etc/yum.repos.d/mongodb-enterprise.repo
# Install updates
yum -y update

#Install Mongo DB & xfs driver
yum install -y xfsprogs mongodb-org

