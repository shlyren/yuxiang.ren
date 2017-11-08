---
title: deploy swift server on centos7.3
layout: single-column
date: 2017-09-11 08:56:08
categories: swift
tags: [swift]
---


1. 连接至centos

   ```shell
   ssh root@10.211.5.4 #我用虚拟机装的centos, 所以连接的是本地ip
   ```

2. 安装必要组件

   ```shell
   yum install -y clang git cmake libedit-devel libxml2-devel swig libuuid-devel libuuid
   ```

3. 安装**libbsd**

   ```shell
   mkdir -p /home/swift/src/
   cd /home/swift/src/
   git clone git://anongit.freedesktop.org/git/libbsd libbsd
   cd libbsd/
   yum install -y autoconf automake libtool
   ./autogen
   ```

4. 克隆swift所需的源码

   ```shell
   cd /home/swift/src/
   git clone https://github.com/apple/swift-llvm.git llvm 
   #git clone https://git.oschina.net/renyuxiang/swift-llvm.git llvm
   git clone https://github.com/apple/swift-clang.git clang 
   #git clone https://git.oschina.net/renyuxiang/swift-clang.git clang
   git clone https://github.com/apple/swift-lldb.git lldb
   #git clone https://git.oschina.net/renyuxiang/swift-lldb.git lldb
   git clone https://github.com/apple/swift-cmark.git cmark
   #git clone https://git.oschina.net/renyuxiang/swift-cmark.git cmark
   git clone https://github.com/apple/swift.git swift
   #git clone https://git.oschina.net/renyuxiang/swift.git swift
   ```

5. 安装**ninja**

   ```shell
   cd /home/swift/src/
   git clone https://github.com/ninja-build/ninja.git ninja
   ```

6. 修改C头文件路径


   * 在文件`/home/swift/src/swift/stdlib/public/Glibc/module.map`中将` /usr/include/x86_64-linux-gnu/sys`替换为`/usr/include/sys`, 即去掉`x86_64-linux-gnu/`
   * 例如: 将`/usr/include/x86_64-linux-gnu/sys/ioctl.h` 改为 `/usr/include/sys/ioctl.h`

7. 编译swift编译器

   ```shell
   export SWIFT_SOURCE_ROOT=/home/swift/src
   cd /home/swift/src/
   ./swift/utils/build-script -R
   ```

8. 如果出现以下错误, 说明要更新**CMake**

   ```
   CMake Error at CMakeLists.txt:3 (cmake_minimum_required):
     CMake 3.4.3 or higher is required.  You are running version 2.8.12.2
   ```

9. 更新[CMake](https://cmake.org/download/)

   ```shell
   cd /home
   wget https://cmake.org/files/v3.9/cmake-3.9.0.tar.gz
   tar -zxvf cmake-3.9.0.tar.gz
   cd cmake-3.9.0
   ./bootstrap --prefix=/usr
   make
   make install
   ```

10. 如果编译成功, 在` /home/swift/src/build/Ninja-ReleaseAssert/swift-linux-x86_64/`会出现有关的可执行文件

11. 通过`swift --version`即可查看当前swift版本

    ​

# 部署swift项目