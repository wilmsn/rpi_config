#!/bin/sh
echo -n "Database Username? [$USER] "
read input
if [ -z "${input}" ]; then
   DBUSER=${USER}
else
   DBUSER=${input}
fi
echo -n "Password for DB-User : ${DBUSER}? [] "
read input
if [ -z "${input}" ]; then
   exit
else
   DBPASSWD=${input}
fi
   
echo "Installing NGINX"
sudo systemctl daemon-reload
sudo /etc/init.d/nginx stop
sudo cp etc_nginx_rpi1 /etc/nginx/sites-available/rpi1
if [ ! -h /etc/nginx/sites-enabled/rpi1 ]; then
  sudo ln -s /etc/nginx/sites-available/rpi1 /etc/nginx/sites-enabled/rpi1
fi
sudo cp init_nginx /etc/init.d/nginx
sudo chmod 755 /etc/init.d/nginx
sudo systemctl daemon-reload
sudo /etc/init.d/nginx restart
echo
echo "Installing AFTERBOOT"
if [ -e /etc/init.d/afterboot ]; then
    sudo /etc/init.d/afterboot stop
fi
sudo cp afterboot /etc/init.d/afterboot
sudo chmod 755 /etc/init.d/afterboot
sudo update-rc.d afterboot defaults
sudo systemctl daemon-reload
sudo /etc/init.d/afterboot start
echo "Installing Samba config"
sudo cp smb.conf /etc/samba/smb.conf
sudo /etc/init.d/samba restart
echo "Config MariaDB"
echo -n "Use this storage for database: "
DBSTORAGE=$(df | grep sda | awk '{print $6}')
echo "${DBSTORAGE}/database"
if [ ! -d ${DBSTORAGE}/database ]; then
  sudo mkdir ${DBSTORAGE}/database
  sudo chown mysql:mysql ${DBSTORAGE}/database
fi
if [ ! -L /database ]; then
  sudo ln -s ${DBSTORAGE}/database /database
fi
echo "Stopping MariaDB"
sudo service mariadb stop
echo "Changing config file"
sudo sed -i "s#^datadir.*=.*#datadir  =  \/database#" /etc/mysql/mariadb.conf.d/50-server.cnf 
echo -n "Its now: "
cat /etc/mysql/mariadb.conf.d/50-server.cnf | grep datadir
echo "Create initial (system)database"
sudo mysql_install_db --user=mysql
echo "Starting MariaDB"
sudo service mariadb start
if [ ! -d ~/projekte ]; then
  mkdir ~/projekte
fi
if [ ! -d ~/projekte/RF24 ]; then
  cd projekte
  git clone https://github.com/wilmsn/RF24
  cd RF24
  make
  sudo make install
  cd
fi
if [ ! -d ~/projekte/RF24Network ]; then
  cd projekte
  git clone https://github.com/wilmsn/RF24Network
  cd RF24Network
  make
  sudo make install
  cd
fi
if [ ! -d ~/projekte/RF24Hub ]; then
  cd projekte
  git clone https://github.com/wilmsn/RF24Hub
  cd RF24Hub
  make
  if [ ! -d /etc/rf24hub ]; then
    mkdir /etc/rf24hub
  fi	
  sudo cp rf24hubd.cfg /etc/rf24hub/rf24hub.cfg
  sudo sed -i "s#^db_username.*=.*#db_username=${DBUSER}#" /etc/rf24hub/rf24hub.cfg
  sudo sed -i "s#^db_password.*=.*#db_password=${DBPASSWD}#" /etc/rf24hub/rf24hub.cfg
  sudo make install
  cd
fi

