---
title: 在Nginx上部署Let's Encrypt证书
date: 2017-08-25 22:42:05
categories: 教程
tags: 教程
---

1. 安装git, 已安装可忽略

   ```ruby
   apt-get update
   apt-get -y install git
   ```

2. clone Let's Encrypt 源码

   ```ruby
   git clone https://github.com/letsencrypt/letsencrypt
   ```


​	<!-- more -->

3. 关闭nginx

   ```ruby
   service nginx stop
   ```

4. 进入`letsencrypt`目录

   ```ruby
   cd letsencrypt
   ```

5. 运行`Standalone`

   ```ruby
   ./letsencrypt-auto certonly --standalone
   ```

6. 然后会让你输入域名, 多域名用空格分开

7. 如果看到这样的信息表示生成成功

   ```ruby
   IMPORTANT NOTES:
   - Congratulations! Your certificate and chain have been saved at
      /etc/letsencrypt/live/example.com/fullchain.pem.
      .......
   ```

8. 证书文件保存在`/etc/letsencrypt/live/`所对应的域名文件夹下

   * `fullchain.pem` 为证书文件
   * `privkey.pem` 为私钥

9. 然后在nging配置文件里配置一下

   ```ruby
   server {
   	listen 443;
       server_name tangziqing.com www.tangziqing.com;
       ssl     on;
       ssl_certificate         /etc/letsencrypt/live/tangziqing.com/fullchain.pem; #证书
       ssl_certificate_key     /etc/letsencrypt/live/tangziqing.com/privkey.pem;#私钥
   	root /var/www/tangziqing.com/;
   }
   ```

10. 把80端口重定向

   ```ruby
   server {
    	listen 80;
   	server_name tangziqing.com *.tangziqing.com;
   	#rewrite ^(.*)$ https://$host$1$ permanent;
   	rewrite ^(.*)$ https://tangziqing.com permanent;
   }
   ```