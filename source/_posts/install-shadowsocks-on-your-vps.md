---
title: 安装shadowsocks
date: 2017-03-30 14:39:09
categories: 教程
tags: [命令, 翻墙]
layout: single-column
---



## 一. 安装

1. 登录你的vps

2. 安装PIP环境

   ```shell
   apt-get install python-gevent python-pip
   ```

3. 安装`shadowsocks`

   ```Shell
   pip install shadowsocks
   ```

##2.  配置信息

1. 创建`config.json`文件
   * 进入shadowsocks文件夹: `cd /etc/shadowsocks`
   * 创建配置文件: `touch config.json`
2. 编辑`config.json`
* 打开vi编辑器: `vi config.json`
* 按照下列格式填写配置信息
 ```json
 {
 "server":"123.123.123.123", # 服务器地址
 "server_port":9000, #端口号
 "local_port":9000, # 本地端口号
 "password":"123456", # 密码
 "timeout":600, # 超时时间
 "method":"rc4-md5" # 密码类型
 }
 ```

* 保存并且退出
* 阿里云香港搭shadowsocks服务的注意事项
  1. 如果服务器是专有网络，`/etc/shadowsocks/config.json` 中的`server ip`是私有ip,而非公网ip
  2. 服务器实例的安全组规则需要增加 自定义 TCP 在 相关端口（9000） 的访问 ,（允许所有ip访问，设置为0.0.0.0/0）

## 三. 开启服务

1. 执行启动服务器: `nohup ssserver -c /etc/shadowsocks/config.json > log &`
2. 设置开机启动: `/usr/local/bin/ssserver -c /etc/shadowsocks/config.json`

