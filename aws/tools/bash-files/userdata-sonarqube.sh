#! /bin/bash

### Install Java-11
sudo su -
apt-get update
apt-get install openjdk-11-jdk -y

### Install Postgres database
sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'  
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
apt-get install postgresql -y

### Set postgres password and config database
runuser -l postgres -c "createuser sonar"
sudo -i -u postgres psql -c "ALTER USER sonar WITH ENCRYPTED PASSWORD 'admin';"
sudo -i -u postgres psql -c "CREATE DATABASE sonarqube OWNER sonar;"
sudo -i -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE sonarqube to sonar;"
systemctl restart  postgresql

cat <<EOT> /etc/sysctl.conf
vm.max_map_count=524288
fs.file-max=131072
ulimit -n 131072
ulimit -u 8192
EOT

cat <<EOT> /etc/security/limits.conf
sonarqube   -   nofile   131072
sonarqube   -   nproc    8192
EOT

### SonarQube Setup
cd /opt
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-8.9.2.46101.zip
apt install unzip
unzip sonarqube-8.9.2.46101.zip
mv sonarqube-8.9.2.46101 sonarqube

cat <<EOT> sonarqube/conf/sonar.properties
sonar.jdbc.username=sonar
sonar.jdbc.password=admin
sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube
sonar.search.javaOpts=-Xmx512m -Xms512m -XX:MaxDirectMemorySize=256m -XX:+HeapDumpOnOutOfMemoryError
EOT

cat >> /etc/systemd/system/sonarqube.service <<EOT
[Unit]
Description=SonarQube service
After=syslog.target network.target
[Service]
Type=forking
User=sonar
Group=sonar
PermissionsStartOnly=true
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start 
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
StandardOutput=syslog
LimitNOFILE=65536
LimitNPROC=4096
TimeoutStartSec=5
Restart=always
[Install]
WantedBy=multi-user.target
EOT


### Add sonar user and grant ownership to /opt/sonarqube
useradd -d /opt/sonarqube sonar
chown -R sonar:sonar /opt/sonarqube


### Reload the daemon and start sonarqube service
systemctl daemon-reload
systemctl enable sonarqube.service
systemctl start sonarqube.service 

init 6
