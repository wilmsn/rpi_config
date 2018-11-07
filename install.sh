#!/bin/sh
cp etc_nginx_wilmie /etc/nginx/sites-available/wilmie
ln -s /etc/nginx/sites-available/wilmie /etc/nginx/sites-enabled/wilmie
cp init_nginx /etc/init.d/nginx
chmod 755 /etc/init.d/nginx
systemctl daemon-reload
/etc/init.d/nginx restart
cp afterboot /etc/init.d/afterboot
chmod 755 /etc/init.d/afterboot
/etc/init.d/afterboot start
sudo update-rc.d afterboot defaults
cp smb.conf /etc/samba/smb.conf
/etc/init.d/samba restart
