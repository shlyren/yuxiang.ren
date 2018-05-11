---
title: 在Ubuntu上部署msyql
layout: single-column
date: 2018-04-28 10:42:18
categories: 教程
tags: 教程
---



##一  安装mysql

   ```bash
apt install mysql-server
apt isntall mysql-client
apt install libmysqlclient-dev
   ```


##二 配置mysql

   1. 支持远程登录

      * 编辑 配置文件:
        ```bash
        vi /etc/mysql/mysql.conf.d/mysqld.cnf
        ```

      *  注释掉`bind-address = 127.0.0.1：`
      	```basic
        #
        # Instead of skip-networking the default is now to listen only on
        # localhost which is more compatible and is not less secure.
        # bind-address           = 127.0.0.1  // 注释掉这里
        #
        # * Fine Tuning
        #
      	```

 2. 支持中文字符以及emoji表情
      * 编辑配置文件
         ```bash
         vi /etc/mysql/my.cnf
         ```
      * 添加一些参数
        ```basic
        [client]
        default-character-set=utf8mb4

        [mysqld]
        character-set-client-handshake = FALSE
        character-set-server = utf8mb4
        collation-server = utf8mb4_unicode_ci
        init_connect=’SET NAMES utf8mb4'

        [mysql]
        default-character-set=utf8mb4
        ```

   3. 重启mysql

      ```bash
      service mysql restart
      ```


##三 创建数据库, 表

1. 创建数据库

   * 登录mysql

     ```bash
     mysql -u root -p
  	```

   * 输入密码(在安装mysql的时候会有提示让你输入默认密码的)

   * 创建一个数据库

     ```bash
     create database db_test; #db_test 为数据库名
     ```

   * 进入`db_test`数据库

     ```bash
     use db_test;
     ```

2. 创建表

   * 创建一个名为`t_test_2`的表, 

     ```bash
     create table if not exists t_test_2 (id int unsigned, text varchar(100));
     ```

     * sql语句可访问: http://www.runoob.com/mysql/mysql-create-tables.html

   * 插入一个带有emoji的中文字符

     ```bash
     INSERT INTO t_test_2 (text) VALUES ('中文👀');
     ```

3. 查看表

   ```ba
   SELECT * FROM t_test_2;
   ```

   * 这是后会发现id为null, 因为 在之前创建表的时候并没有让id自增, 这时候可以这样解决

     ```bash
     ALTER TABLE t_test_2 MODIFY id int unsigned auto_increment primary key;
     ```

   * 也可以在一开始创建表的时候加上`auto_increment primary key`;

     ```bash
     create table if not exists t_test_2 (id int unsigned auto_increment primary key, text varchar(100));
     ```



## 四 解决中文乱码

1.  登陆 mysql
  ```bash
  mysql -u root -p
  ```

2.  修改database的字符集：

  `ALTER DATABASE 数据库名 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;`

3.  修改table的字符集：

    `ALTER TABLE 表名 CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;`

4.  修改column的字符集：

     `ALTER TABLE 表名 CHANGE 字段名 字段名 该字段原来的数据类型 CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;`
