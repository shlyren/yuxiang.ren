---
title: 使用gem更新报错的问题
date: 2016-12-02 14:01:01
categories: iOS
tags: [命令,Cocoapods]
layout: single-column
---

## gem install cocoapods

使用`gem install cocoapods`更新报`You don't have write permissions for the /Library/Ruby/Gems/2.0.0 directory`错.
解决方法: 使用`sudo gem install cocoapods` 更新

## sudo gem install cocoapods
使用`sudo gem install cocoapods`更新报`Operation not permitted - /usr/bin/pod`错

解决方法: 使用`sudo gem install -n /usr/local/bin cocoapods`


