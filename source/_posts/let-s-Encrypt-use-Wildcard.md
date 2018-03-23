---
title: let's Encrypt 申请通配符(ACME)
layout: single-column
date: 2018-03-21 15:44:13
categories: 教程
tags:
---



官方教程: https://github.com/Neilpang/acme.sh/wiki/%E8%AF%B4%E6%98%8E



### 1. 安装 **acme.sh**

```bash
curl  https://get.acme.sh | sh
```

​	会默认安装到`~/.acme.sh`

### 2. 进入安装目录

```bash
cd ~/.acme.sh
```

### 3. 通过dns验证域名

不同dns服务商申请apiKey:

https://github.com/Neilpang/acme.sh/blob/master/dnsapi/README.md

### 4. 申请出证书

```bash
acme.sh --issue --dns dns_ali -d shlyren.com -d *.shlyren.com
```

​	*`dns_ali`:表示的阿里云dns, 其他dns申请请访问https://github.com/Neilpang/acme.sh/blob/master/dnsapi/README.md



### 5. 配置

申请成功后证书文件会保存到`~/.acme.sh/your dome`文件夹下