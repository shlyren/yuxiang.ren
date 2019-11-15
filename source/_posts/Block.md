---
title: Block
categories: 笔记
layout: single-column
tags: [笔记, Objective-C]
---

### 本质

- 本质是一个OC对象，内部有一个isa指针

- 封装了函数调用以及函数调用环境的OC对象

- block底层结构如下图所示

  ![结构图](https://i.loli.net/2019/04/16/5cb5526944b5c.png)



### 底层结构

![底层结构](https://i.loli.net/2019/04/16/5cb55b750b442.png)



### 变量捕获

> 为了保证block内部能够正常访问外部变量，block有个变量捕获机制

<table border=0 cellpadding=0 cellspacing=0 width=522 style='border-collapse:
 collapse;table-layout:fixed;width:391pt'>
 <col width=87 style='width:65pt'>
 <col width=119 style='mso-width-source:userset;mso-width-alt:3797;width:89pt'>
 <col width=193 style='mso-width-source:userset;mso-width-alt:6186;width:145pt'>
 <col width=123 style='mso-width-source:userset;mso-width-alt:3925;width:92pt'>
 <tr height=21 style='height:16.0pt'>
  <td colspan=2 height=21 class=xl67 width=206 style='height:16.0pt;width:154pt'>变量类型</td>
  <td class=xl67 width=193 style='width:145pt'>捕获到block内部</td>
  <td class=xl67 width=123 style='width:92pt'>访问方式</td>
 </tr>
 <tr height=24 style='height:18.0pt'>
  <td rowspan=2 height=48 class=xl65 style='height:36.0pt;width:100.0pt'>局部变量</td>
  <td class=xl65>auto</td>
  <td class=xl66>✅</td>
  <td class=xl65>值传递</td>
 </tr>
 <tr height=24 style='height:18.0pt'>
  <td height=24 class=xl65 style='height:18.0pt'>static</td>
  <td class=xl66>✅</td>
  <td class=xl65>指针传递</td>
 </tr>
 <tr height=21 style='height:16.0pt'>
  <td colspan=2 height=21 class=xl65 style='height:16.0pt'>全局变量</td>
  <td class=xl65>❌</td>
  <td class=xl65>直接访问</td>
 </tr>
</table>



### block的类型

> block有3中类型，可以通过调用class的方法或者isa指针查看具体类型，最终都是继承自NSBlock

- `__NSGlobalBlock__`(_NSConcreateGlobalBlock)：没有访问auto变量

- `__NSStackBlock__`(_NSConcreateStackBlock)：访问auto变量，存放于栈，随时可能被销毁

- `__NSMallocBlock__`(_NSConcreateMallocBlock)：`__NSStackBlock__`调用了copy

  

### 内存分配
  ![内存分配.png](https://i.loli.net/2019/04/16/5cb57e3f5e417.png)
  - .text区：代码段
  - .data区：数据段，一般存放全局变量
  - 堆：动态分配内存，需要程序员申请内存，也需要自己管理内存
  - 栈：系统自动分配内存



### block的copy

#### MRC

> 每一种类型的block调用copy后的结构如下

| Block的类               | 副本源的配置存储域 | 复制效果     |
| ----------------------- | :----------------- | ------------ |
| _NSConcreateGlobalBlock | 程序的数据区域     | 什么也不做   |
| _NSConcreateStackBlock  | 栈                 | 从栈复制到堆 |
| _NSConcreateMallocBlock | 堆                 | 引用计数增加 |

- 建议写法

  `@property (nonatomic, copy) void (^block)(void);`



#### ARC

1. 在ARC环境下，编译器会根据情况自动将栈上的block复制到堆上，比如
   - block作为函数返回值时
   - 将block赋值给`__strong`指针时
   - block作为Cocoa API中方法名含有usingBlock的方法参数时
   - block作为GCD API方法参数时
2. 建议写法
   - `@property (strong, nonatomic) void (^block)(void);`
   - `@propertu (copy, nonatomic) void (^block)(void);`



### 对象类型的auto

1. 当block内部访问了对象类型的auto变量时

   - 如果block在栈上， 将不会对auto变量产生强引用

2. 如果block被拷贝到堆上

   - 堆调用block内部的copy函数
   - copy函数内部会调用_Block_object_assign函数
   - _Block_object_assign函数会根据auto变量的修饰符(`__strong`,`__weak__`,`__unsafe_unretained`)做出相应的操作，类似于retain(形成强引用、弱引用)

3. 如果block从堆上移除

   - 会调用gblock内部的dispose函数
   - dispose函数内部会调用_Block_object_dispose函数
   - _Block_object_dispose函数会自动书房引用的auto变量，类似于release

| 函数        | 调用时机            |
| ---------- | ------------------ |
| copy函数    | 栈上Block复制到堆上时 |
| dispose函数 | 堆上的Block被废弃时   |

   

### __block

#### 本质
- __block用于解决block内部无法修改auto变量值的问题
- __block不能修饰全局变量、静态变量(static)
- 编译器会将__block变量包装成一个对象
![底层.png](https://i.loli.net/2019/04/16/5cb5a4cfe409a.png)



#### 内存管理

- 当block在栈上时，并不会对__block变量产生强引用
- 当block呗copy到堆时
  - 会调用block内部的copy函数
  - copy函数会调用_Block_object_assign函数
  - _Block_object_assign函数会对__block变量强引用
![内存管理.png](https://i.loli.net/2019/04/16/5cb5a9f5c6e14.png)

### 循环引用

####  ARC

1. 通过`__weak`解决，推荐

  - 不会产生强引用，指向的对象销毁时会自动置为nill

  ```objective-c
  __weak typeof(self) weakSelf = self; 
  self.bolck = ^{
    NSLog(@"%@", weakSelf);
  };
  ```

2. 通过`__unsafe_unretaine`解决

  - 不会产生强引用，不安全(野指针)。指向的对象销毁时，指针指向的地址值不变

  ```objective-c
  __unsafe_unretaine typeof(self) weakSelf = self; 
  self.bolck = ^{
    NSLog(@"%@", weakSelf);
  };
  ```

3. 通过`__block`解决

   - 必须要调用block

   ```objective-c
   __block typeof(self) blockSelf = self;
   self.block = ^{
     NSLog(@"%@", blockSelf);
     blockSelf = nil;
   };
   self.block();
   ```



#### MRC

1. 通过`__unsafe_unretaine`解决，同ARC

   ```objective-c
   __unsafe_unretaine typeof(self) weakSelf = self; 
   self.bolck = ^{
     NSLog(@"%@", weakSelf);
   };
   ```

2. 通过`__block`解决，同ARC

   ```objective-c
   __block typeof(self) blockSelf = self;
   self.block = ^{
     NSLog(@"%@", blockSelf);
     blockSelf = nil;
   };
   self.block();
   ```

   

### 相关问题

1. block底层原理?

   封装了函数调用及其调用环境的oc对象

2. __block的作用，使用注意点?

   用于解决block内部无法修改auto变量值的问题

3. __block修饰为什么是copy，使用注意点？

   block一旦没有进行copy操作，就不会在堆上。

   需要注意循环引用

