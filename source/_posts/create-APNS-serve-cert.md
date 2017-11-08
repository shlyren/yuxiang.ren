---
title: 配置APNS服务器证书
layout: single-column
date: 2017-10-27 16:27:42
categories: 教程
tags: 教程
---



1. 将apple推送证书导入钥匙串
2. 从钥匙串导出`Apple Development iOS Push Server`证书`cert.p12`密码为空
3. 从钥匙串导出`Apple Development iOS Push Server`秘钥`key.p12`密码为空
4. 打开终端生成pem文件
5. `openssl pkcs12 -clcerts -nokeys -out cert.pem -in cert.p12 `
6. `openssl pkcs12 -nocerts -out key.pem -in key.p12 ` 需要设置密码`123456`
7. `openssl rsa -in key.pem -out noenc.pem` 取消密码
8. `cat cert.pem noenc.pem > apns-dev.pem`合并文件
9. 服务器使用`apns-dev.pem`文件