# create_laravel_website.sh
本 shell script 執行以下動作：
1. 建立 Laravel 專案。
2. 設定 Laravel 專案資料庫連線資訊。
3. 設定 Laravel 專案目錄/檔案的權限給 Web server (Nginx) .
4. 建立 Laravel 專案在 Nginx 的配置檔案
5. 為 Laravel 專案申請 Let's Encrypt 憑證。
6. 設定 VSFTPd 虛擬使用者及登入設定
7. 建立 AWStats 設定檔案。

本腳本運作前請確認 Composer、Nginx、VSFTPd 及 AWStats 均已安裝、運作。 
第 4、6、7 步驟透過複製範例檔案後置換關鍵部分完成，其中： 
* example.com.conf：複製至 /etc/nginx/ 
* example：複製至 /etc/vsftpd/vsftpd_user_conf/ 
* awstats.example.com.conf：複製至 /etc/awstats/ 
