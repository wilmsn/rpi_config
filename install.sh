#!/bin/sh
echo "Installing NGINX"
systemctl daemon-reload
/etc/init.d/nginx stop
cp etc_nginx_rpi1 /etc/nginx/sites-available/rpi1
if [ ! -h /etc/nginx/sites-enabled/rpi1 ]; then
  ln -s /etc/nginx/sites-available/rpi1 /etc/nginx/sites-enabled/rpi1
fi
cp init_nginx /etc/init.d/nginx
chmod 755 /etc/init.d/nginx
systemctl daemon-reload
/etc/init.d/nginx restart
echo
echo "Installing AFTERBOOT"
/etc/init.d/afterboot stop
cp afterboot /etc/init.d/afterboot
chmod 755 /etc/init.d/afterboot
sudo update-rc.d afterboot defaults
systemctl daemon-reload
/etc/init.d/afterboot start
echo "Installing Samba config"
cp smb.conf /etc/samba/smb.conf
/etc/init.d/samba restart
