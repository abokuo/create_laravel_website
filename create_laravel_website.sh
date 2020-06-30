#!/bin/bash
# This script is about to create Laravel based website, and set the configuration of
# Web Server (Nginx), Database Connection (with MySQL Server), and FTP (VSFTPd).
# 2020 即時互動科技版權所有
# Changelog
# 2020/xx/xx 加入條件判斷及列出輸入內容
# 2020/06/30 首次發行 by A-Bo Lee abo@realtime.tw
#
# 變數定義
# site_name Laravel 網站專案資料夾，建議以網址命名
# 同時會作為 Nginx 設定、SSL 憑證、連線日誌、AWStats 設定檔名稱
# db_server 資料庫伺服器名
# db_name 資料庫名稱
# db_username 資料庫連線帳號
# db_password 資料庫連線密碼
# dbadmin 資料庫管理者帳號
# dbadmin_password 資料庫管理者密碼
# ftp_username FTP虛擬使用者帳號
# ftp_password FTP虛擬使用者密碼
# site_backup 網站例行備份名字，與網址相同，但是將「.」更改為「_」

# 設定程式路徑
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# 說明要做的所有事情
clear
echo "Hello, here are several things you will do:"
echo "1. Create a Laravel project based webisite, project name is url of your website."
echo "2. Setup database connection of your website."
echo "3. Create Nginx configuration of your website. (optional)"
echo "4. Create FTP connection of VSFTPd, so let you can login website root via FTP."
echo "5. Craete a cron job of your website, let you do something every minute."
echo "6. Make a backup schedule of your website."
echo "7. Create AWStats configuration, let you know about how many page views on your website, and many other things with AWStats report."
echo "So, let's start it."
sleep 3
echo ""

# 建立 Laravel 網站專案
read -p "What's your Laravel project name? " site_name
echo "Okay, let's build Laravel project at ${site_name}..."
#cd /mnt/webdisk # for Realtime
cd /var/www/html/ #  for common linux system
composer create-project laravel/laravel $site_name 5.8.* --no-dev

# 收集資料庫連線資訊
read -p "What's database server hostname of your Laravel project? " db_server
read -p "What's your database name of Laravel project? " db_name
read -p "What's your database username of Laravel project? " db_username
read -p "What's your database password of Laravel project? " db_password
echo "Okay, let's set up the configuration of database."
sleep 1

# 編輯專案 .env，設定 Laravel 專案資料庫連線資訊
#sed -i "s/DB_HOST=127.0.0.1/DB_HOST=${db_server}/" /mnt/webdisk/$site_name/.env
#sed -i "s/DB_DATABASE=laravel/DB_DATABASE=${db_name}/" /mnt/webdisk/$site_name/.env
#sed -i "s/DB_USERNAME=root/DB_USERNAME=${db_username}/" /mnt/webdisk/$site_name/.env
#sed -i "s/DB_PASSWORD=/DB_PASSWORD=${db_password}/" /mnt/webdisk/$site_name/.env
# above for Realtime
# below for common linux system
sed -i "s/DB_HOST=127.0.0.1/DB_HOST=${db_server}/" /var/www/html/$site_name/.env
sed -i "s/DB_DATABASE=laravel/DB_DATABASE=${db_name}/" /var/www/html/$site_name/.env
sed -i "s/DB_USERNAME=root/DB_USERNAME=${db_username}/" /var/www/html/$site_name/.env
sed -i "s/DB_PASSWORD=/DB_PASSWORD=${db_password}/" /var/www/html/$site_name/.env

# 編輯專案 .env，定義 Laravel 專案網址
echo "Now, make your APP_URL setting as URL of your website."
#sed -i "s/APP_URL=http:\/\/localhost/APP_URL=https:\/\/${site_name}/" /mnt/webdisk/$site_name/.env # for Realtime
sed -i "s/APP_URL=http:\/\/localhost/APP_URL=https:\/\/${site_name}/" /var/www/html/$site_name/.env # for common linux system

# 定義資料庫編碼、校正以及不使用嚴謹模式
echo "It's important about the collation of your data in database, let it be utf8mb4_general_ci."
#sed -i 's/utf8mb4_unicode_ci/utf8mb4_general_ci/' /mnt/webdisk/$site_name/config/database\.php # for Realtime
#sed -i "s/'strict' => true/'strict' => false/" /mnt/webdisk/$site_name/config/database\.php # for Realtime
sed -i 's/utf8mb4_unicode_ci/utf8mb4_general_ci/' /var/www/html/$site_name/config/database.php # for common linux system
sed -i "s/'strict' => true/'strict' => false/" /var/www/html/$site_name/config/database.php # for common linux system

# 將專案目錄權限歸給 Nginx：可能是 nginx:nginx 或 www-data:www-data(Ubuntu)
echo "Let the directories (and files) permission of project are belong to Nginx."
#chown -R nginx:nginx /mnt/webdisk/$site_name # for Realtime
chown -R nginx:nginx /var/www/html/$site_name # for common linux system

# 登入資料庫伺服器，建立專案要使用的連線資訊：資料庫項目、資料庫連線帳號、資料庫連線密碼

# 使用 acme.sh 向 Let's Encrypt 申請 SSL 憑證：透過 CloudFlare DNS API
#echo "Issue SSL certificate of Let's Encrypt via CloudFlare DNS API..."
#cd /root/.acme.sh/
#./acme.sh --issue --dns dns_cf -d $site_name

# 使用 acme.sh 將已申請的安全憑證，安裝 Nginx 用的 SSL 安全憑證資料至指定目錄
#echo "Install SSL certificate of ${site_name} for Nginx."
#cd /root/.acme.sh
#./acme.sh --install-cert -d $site_name --key-file /etc/nginx/ssl/$site_name.key --fullchain-file /etc/nginx/ssl/$site_name.crt --reloadcmd "systemctl force-reload nginx"

# 建立專案的 Nginx 設定檔
echo "Let's create Nginx configuration of ${site_name}..."
sleep 1
cp /etc/nginx/example.com.conf /etc/nginx/conf.d/$site_name.conf
sed -i "s/example.com/${site_name}/g" /etc/nginx/conf.d/$site_name.conf

# 加上測試 Nginx 設定
# nginx -t

# Nginx 重新讀取網站設定資料夾，啟動網站
echo "Reloading Nginx configuration..."
systemctl reload nginx

# 建立 FTP　虛擬使用者登入資訊
echo "Create FTP account and password.."
cd /etc/vsftpd/
read -p "What is FTP username? " ftp_username
read -p "What is FTP password? " ftp_password
echo "Adding vistual user in VSFTPd..."
echo -e "${ftp_username}\n${ftp_password}" >> virtuser

# 設定 FTP 虛擬使用者存取權限
echo "Adding vistual user FTP setting of website..."
cd /etc/vsftpd/vsftpd_user_conf
cp example $ftp_username
sed -i "s/example.com/${site_name}/" $ftp_username

# 將帳號資料轉成資料庫格式
db_load -T -t hash -f /etc/vsftpd/virtuser /etc/vsftpd/vsftpd-virtual-user\.db

# site_backup 網站例行備份名字，網址相同，但是將「.」更改為「_」，適用於 Realtime
#echo "Adding to website backup list..."
#site_backup=${site_name//./_}
#cd /mnt/webdisk/site_backup
#echo -e "${site_backup},/mnt/webdisk/${site_name}/" >> list.txt

# 將專案加入排程，每分鐘一次
echo "Add a schedule into your cron job of host for your project."
sleep 1
#echo "#${site_name} system schedule\n*  *  *  *  * root php /mnt/webdisk/${site_name}/artisan schedule:run 1>> /dev/null 2>&1 " >> /etc/crontab
# above for Realtime
# below for common linux system 
echo "#${site_name} system schedule" >> /etc/crontab
echo "*  *  *  *  * root php /var/www/html/${site_name}/artisan schedule:run 1>> /dev/null 2>&1 " >> /etc/crontab

#設定流量報表
#echo "Setting AWStats website report"
#cp /etc/awstats/awstats.example.com\.conf /etc/awstats/awstats.$site_name\.conf
#sed -i 's/"example.com/$site_name/g' /etc/awstats/awstats.$site_name\.conf
#echo $site_name >> /root/awslist.txt

echo -e "All done, enjoy!"