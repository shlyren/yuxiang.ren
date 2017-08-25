---
title: hexo博客自动部署到多台服务器
date: 2017-08-25 08:35:45
categories: 教程
tags: 教程
---

最近搞了负载均衡, 那么就牵扯到快速部署到多台服务器的问题了, 当然可以一个一个单独的提交, 但是这样效率就太低了。

如果能够同时提交到多个服务器就更好了，当然方法有很多种, 下面介绍常用的两种。

<!-- more -->

# git提交到多个仓库

1. 编辑`.git`文件夹下的`config`文件, 这是git仓库的配置文件, 它的默认文件格式是这样的

   ```reStructuredText
   [core]
   	repositoryformatversion = 0
   	filemode = true
   	bare = false
   	logallrefupdates = true
   	ignorecase = true
   	precomposeunicode = true
   	autocrlf = false
   [remote "origin"]
   	url = git@github.com:shlyren/yuxiang.ren.git
   	fetch = +refs/heads/*:refs/remotes/origin/*
   [branch "master"]
   	remote = origin
   	merge = refs/heads/master
   ```

2. 我们字样 在`[remote "origin"]`下面添加别的其他的仓库地址就可以了, 比如再添加两个仓库

   ```
   url = 106.14.9.43:repos/yuxiang.ren.git
   url = 45.32.54.225:repos/yuxiang.ren.git
   ```

3. 添加后的文件

   ```ya
   [core]
   	repositoryformatversion = 0
   	filemode = true
   	bare = false
   	logallrefupdates = true
   	ignorecase = true
   	precomposeunicode = true
   	autocrlf = false
   [remote "origin"]
   	url = git@github.com:shlyren/yuxiang.ren.git
   	url = 106.14.9.43:repos/yuxiang.ren.git
   	url = 45.32.54.225:repos/yuxiang.ren.git
   	fetch = +refs/heads/*:refs/remotes/origin/*
   [branch "master"]
   	remote = origin
   	merge = refs/heads/master
   ```

4. 然后就可以使用git命令提交了

   ​

   上一个方法虽然快速了很多, 但是还是有一点麻烦, 下面介绍一种更简洁的方法 , 通过hexo的自动提交的功能。


# 通过hexo一键部署功能


1. Hexo 提供了快速方便的一键部署功能，让您只需一条命令就能将网站部署到服务器上。

   * hexo的配置文件`_config.yml`中 有一个这样的参数, 这是部署到github page的配置

     ```yaml
     deploy:
       type: git
       repo: git@github.com:shlyren/shlyren.github.io.git #github仓库
       branch: origin
     ```

2. 如果多个仓库,可以这样写

   ```yaml
   deploy:
     type: git
     repo: 
       github: git@github.com:shlyren/shlyren.github.io.git #github
       git1: root@106.14.9.43:repos/yuxiang.ren.git #服务器1仓库
       git2: root@45.32.54.225:repos/yuxiang.ren.git #服务器1仓库
     branch: origin
   ```

3. 然后就可以使用hexo的`deploy`自动部署了。

4. 需要注意的是`yaml`的缩进, 确保每一级的缩进长度相同。

5. 通过命令一键部署

   ```shell
   hexo d -g
   ```

   ​

