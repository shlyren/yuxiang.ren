---
title: 在Nginx上部署Let's Encrypt证书
date: 2017-08-25 22:42:05
categories: 教程
tags: [命令, Ubuntu]
layout: single-column
---

1. 安装git, 已安装可忽略

   ```ruby
   apt update
   apt -y install git
   ```

2. clone Let's Encrypt 源码

   ```ruby
   git clone https://github.com/letsencrypt/letsencrypt
   ```


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

6. 如果出现报错:

   ```
   OSError: Command /opt/eff.org/certbot/venv/bin/python2.7 - setuptools pkg_resources pip wheel failed with error code 2
   ```

   执行下面命令:

   ```bash
   sudo apt-get install letsencryp
   apt-get purge python-virtualenv python3-virtualenv virtualenv
   pip install virtualenv
   ```

   然后重新执行第五步.

7. 然后会让你输入各种信息, 反正基本上选择yes什么的, 下面我贴上我申请时的终端信息

   ```bash
   service nginx stop #停止nginx
   cd letsencrypt/ #进入letsencrypt文件夹
   ./letsencrypt-auto certonly --standalone #生成证书
   Saving debug log to /var/log/letsencrypt/letsencrypt.log
   Enter email address (used for urgent renewal and security notices) (Enter 'c' to
   cancel): mail@yuxiang.ren #输入邮箱

   -------------------------------------------------------------------------------
   Please read the Terms of Service at
   https://letsencrypt.org/documents/LE-SA-v1.1.1-August-1-2016.pdf. You must agree
   in order to register with the ACME server at
   https://acme-v01.api.letsencrypt.org/directory
   -------------------------------------------------------------------------------
   (A)gree/(C)ancel: A #同意

   -------------------------------------------------------------------------------
   Would you be willing to share your email address with the Electronic Frontier
   Foundation, a founding partner of the Let's Encrypt project and the non-profit
   organization that develops Certbot? We'd like to send you email about EFF and
   our work to encrypt the web, protect its users and defend digital rights.
   -------------------------------------------------------------------------------
   (Y)es/(N)o: Y #是
   Please enter in your domain name(s) (comma and/or space separated)  (Enter 'c'
   to cancel): baixiaotu.cc #输入域名 多域名用空格分开      
   Obtaining a new certificate
   Performing the following challenges:
   tls-sni-01 challenge for baixiaotu.cc
   Waiting for verification...
   Cleaning up challenges
   ```

7. 如果看到这样的信息表示生成成功

   ```ruby
   IMPORTANT NOTES:
    - Congratulations! Your certificate and chain have been saved at:
      /etc/letsencrypt/live/baixiaotu.cc/fullchain.pem #证书目录
      Your key file has been saved at:
      /etc/letsencrypt/live/baixiaotu.cc/privkey.pem #私钥目录
      Your cert will expire on 2017-11-25. To obtain a new or tweaked
      version of this certificate in the future, simply run
      letsencrypt-auto again. To non-interactively renew *all* of your
      certificates, run "letsencrypt-auto renew"
    - Your account credentials have been saved in your Certbot
      configuration directory at /etc/letsencrypt. You should make a
      secure backup of this folder now. This configuration directory will
      also contain certificates and private keys obtained by Certbot so
      making regular backups of this folder is ideal.
    - If you like Certbot, please consider supporting our work by:

      Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
      Donating to EFF:                    https://eff.org/donate-le

   ```

8. 证书文件保存在`/etc/letsencrypt/live/`所对应的域名文件夹下

   * `fullchain.pem` 为证书文件
   * `privkey.pem` 为私钥

9. 然后在nging配置文件里配置一下

   ```ruby
   server {
   	listen 443;
       server_name baixiaotu.cc;
       ssl     on;
       ssl_certificate     /etc/letsencrypt/live/baixiaotu.cc/fullchain.pem; #证书
       ssl_certificate_key /etc/letsencrypt/live/baixiaotu.cc/privkey.pem;#私钥
   	root /var/www/baixiaotu.cc/;
   }
   ```

10. 把80端口重定向

  ```ruby
  server {
   	listen 80;
  	server_name baixiaotu.cc *.baixiaotu.cc;
  	#rewrite ^(.*)$ https://$host$1$ permanent;
  	rewrite ^(.*)$ https://baixiaotu.cc permanent;
  }
  ```

11. 开启nginx

    ```shell
    service nginx start
    ```