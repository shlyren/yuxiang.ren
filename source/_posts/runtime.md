---
title: Runtime
categories: 笔记
layout: single-column
tags: [笔记, Objective-C]
---



### 简介

- Objective-C是一门动态性特别强的变成语言，跟C、C++等语言有着很大的不同

- Objective-C的动态特性是有Runtime API来支撑的

- Runtime API提供的接口基本上是C语言的，源码由C/C++汇编语言编写



### isa详解-位域

​	![对象的isa](https://i.loli.net/2019/04/17/5cb6c704318de.png)



- 想要学习Runtime，首先要了解他底层的一些常用数据结构，比如isa指针

- 在arm64架构之前，isa就是一个普通的指针，存储着Class、Meta-Class对象的内存地址

- 从arm64架构开始，对isa进行了优化，变成了一个共用体(union)结构，还使用**位域**来存储更多的信息

  ![isa.png](https://i.loli.net/2019/04/17/5cb6ad4fd4316.png)

   - nonpointer
     - 0：代表普通的指针，存储着Class、Meta-Class对象的内存地址
     - 1：代表优化过，使用位域存储更多的信息
  - has_assoc
    - 是否有设置过关联对象。如果没有，释放时会更快
  - has_cxx_dtor
    - 是否有C++的析构函数(.cxx_destruct)，如果没有释放时会更快
  - shiftcls
    - 存储着Class、Meta-Class对象的内存地址信息
  - magic
    - 用于在调试时分辨对象是否未完成初始化
  - weakly_referenced
    - 是否有被弱引用只想过，如果没有，释放时会更快
  - deallocating
    - 对象是否正在释放
  - extra_rc
    - 里面存储的值是引用计数器减1
  - has_sidetable_rc
    - 引用计数器是否过大无法存储在isa中
    - 如果为1，那么引用计数会存储在一个叫SideTable的类的属性中



### 类对象

#### class的结构

![class结构.png](https://i.loli.net/2019/04/17/5cb6c84834aae.png)

#### class_rw_t

> class_rw_t里面的methods、properties、protocols是二位数组，是可读可写的包含了类的初始内容、分类内容

![rw_t.png](https://i.loli.net/2019/04/17/5cb6cb1d8eda4.png)

#### class_ro_t

> class_ro_t里面的baseMethodList、baseProtocols、ivars、baseProperties是一维数组，是只读的，包含了类的初始内容

![ro_t.png](https://i.loli.net/2019/04/17/5cb6cbce98993.png)

#### method_t

> method_t是对方法\函数的封装

```objective-c
struct method_t {
  SEL name; // 函数名
  const char *types; // 编码(返回值类型、参数类型)
  IMP imp; // 指向函数的指针
}
```

- IMP代表函数的具体实现

  ```objc
  typedef id _Nullable (*IMP)(id _Nonnull, SEL _Nonnull, ...);
  ```

- SEL代表方法\函数名，一般叫做选择器，底层结构跟char*类似

  - 可以通过@seelctor()和sel_registarName()获得
  - 可以通过sel_getName()和NSStringFromSelector()转成字符串
  - 不同类中相同名字的方法，所对应的方法选择器是相同的

  ```objc
  typedef struct objc_selector *SEL;
  ```

- types包含了函数的返回值、参数编码的字符串，参阅<a id="typeencoding">Type Encoding</a>。

  ![types.png](https://i.loli.net/2019/04/17/5cb6d6470d7f0.png)

#### cache_t

1. Class内部结构中有个方法缓存(cache_t)，用==散列表(哈希值)==来缓存曾经调用过的方法，可以提高方法的查找速度

   ```objective-c
   struct cache_t {
     struct bucket_t *_buckets; // 散列表
     mask_t _mask; // 散列表长度-1
     mask_t _occupied; // 已经缓存的方法数量
   }
   
   struct bucket_t {
     cache_key_t _key; // SEL作为key
     IMP _imp; // 函数的内存地址
   }
   ```

2. 缓存查找

   - objc-cache.mm

     ```c++
     bucket_t * cache_t::find(cache_key_t k, id receiver)
     ```

#### [Type Encoding](#typeencoding)

> ios中提供了一个叫做@encode的指令，可以将具体的类型表示成字符串编码

|      code      | Meaning                                                      |
| :------------: | :----------------------------------------------------------- |
|       c        | A char                                                       |
|       i        | An int                                                       |
|       s        | A short                                                      |
|       l        | A long. l is treated as a 32-bit quantity on 64-bit programs. |
|       q        | A long long                                                  |
|       c        | An unsigned char                                             |
|       I        | An unsigned int                                              |
|       s        | An unsigned short                                            |
|       L        | An unsigned long                                             |
|       Q        | An unsigned long long                                        |
|       f        | A float                                                      |
|       d        | A double                                                     |
|       B        | A C++ bool or a C99 Bool                                     |
|       v        | A void                                                       |
|       *        | A character string (char *)                                  |
|       @        | An object(whether statically typed or typed id)              |
|       #        | A class object(Class)                                        |
|       :        | A method selector(SEL)                                       |
|  [array type]  | An array                                                     |
| {name=type...} | A structure                                                  |
| (name=type...) | A union                                                      |
|      bunm      | A bit field of num bits                                      |
|     ^type      | A pointer to type                                            |
|       ?        | An unknow type(among other things, this code is used for function pointers) |

 

### objc_msgSend

> 消息机制：给方法调用者发送消息
>
> OC中的方法调用，其实都是转化为objc_msgSend函数调用

#### 执行流程

objc_msgSend的执行流程分为3大阶段：

##### 消息发送

![msgsend.png](https://i.loli.net/2019/04/18/5cb7d22099d16.png)

   - 如果是从class_rw_t中查找方法
     - 已经排序：二分查找
     - 没有排序：便利查找

  - receiver通过isa指针找到receiverClass

  - receiverClass通过superclass指针找到superClass

    

##### 动态方法解析

![动态解析.png](https://i.loli.net/2019/04/18/5cb7d6edd9cd6.png)

   - 开发者可以实现以下方法来
     - `+resolveInstanceMethod:`
     - `+resolveClassMethod:`
   - 动态解析过后，会重新走“消息发送”的流程
     - **从receiverClass的cache中查找方法**这一步开始执行

##### 消息转发

![repost.png](https://i.loli.net/2019/04/18/5cb7dad8b51e9.png)

- 开发者可以在`forwardInvocation:`方法中自定义任何逻辑

  ```objective-c
  - (id)forwardingTargetForSelector:(SEL)aSelector
  {
      if (aSelector == sel_registerName("test")) {
          return [OtherClass new];
      }
      return [super forwardingTargetForSelector:aSelector];
  }
  ```

  

- 以上方法都有对象方法、类方法2个版本（前面可以是加号+，也可以是减号-）

  - 类方法xcode会出现无代码提示

- `methodSignatureForSelector:`方法签名

  ```objective-c
  - (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
  {
      if (aSelector == sel_registerName("test")) {
        //  [[OtherClass new] methodSignatureForSelector:aSelector]
          return [NSMethodSignature signatureWithObjCTypes:"v@:"];
      }
      return [super methodSignatureForSelector:aSelector];
  }
  ```

- `- (void)forwardInvocation:(NSInvocation *)anInvocation`

  - 封装了一个方法调用，包括：方法调用者、方法名、方法参数

  ```objective-c
  - (void)forwardInvocation:(NSInvocation *)anInvocation
  {
      anInvocation.target = [OtherClass new];
  }
  ```

  



#### [动态添加方法](#addmethod)

1. OC

   ```objc
   - (void)other
   {
   	NSLog(@"%s", __func__);
   }
   
   + (BOOL)resolveInstanceMethod:(SEL)sel
   {
       if (sel == @selector(test)) {
           Method method = class_getInstanceMethod(self, @selector(other));
           class_addMethod(self, sel, method_getImplementation(method), method_getTypeEncoding(method))
             returun YES;
       }
       return [super resolveInstanceMethod:sel];
   }
   ```

   - `Method`可以理解为等价于`struct method_t *`

2. C

   ```objc
   void other(id self, SEL _cmd) {
       NSLog(@"%@ - %s - %s", self, sel_getName(_cmd, __func__);
   }
   
   + (BOOL)resolveInstanceMethod:(SEL)sel
   {
       if (sel == @selector(test)) {
           class_addMethod(self, sel, (IMP)other, "v@:");
           return YES;
       }
       return [super resolveInstanceMethod:sel];
   }
   ```


- `@dynamic`是告诉编译器不用自动生成getter和setter的实现，等到运行时再添加方法实现



### super本质

- super调用，底层会转换为objc_msgSendSuper2函数的调用个，接收两个参数
  - struct objc_super2

    ```objective-c
    struct objc_super2 {
      id receiver;
      Class current_class;
    }
    ```

  - SEL

- receiver是消息接受者

- curretn_class是receiver的Class对象

### LLVM

- Objective-C在变为机器代码之前，会被LLVM编译器转为中间代码(Intermediate Representation)
- 可以使用以下命令行指令生成中间代码
  - `clang -emit-llvm -S main.m`
- 语法简介
  - @ - 全局变量
  - % - 局部变量
  - alloca - 在当前执行的函数的堆栈中分配内存，但该函数返回到其调用者时，将自动释放内存
  - i32 - 32位4字节的整数
  - align - 对其
  - load - 读出，stroe 写入
  - icmp - 两个整数值比较，返回布尔值
  - br - 选择分支，根据条件来转向label，不根据条件跳转的话类似goto
  - label - 代码标签
  - call - 调用函数
- 具体可以参考官方文档：https://llvm.org/docs/LangRef.html



### API

#### 类

- 动态创建一个类

  ```objective-c
  /**
  	superclass: 父类，name: 类名，extraBytes: 额外的内存空间
  */
  Class objc_allocateClassPair(Class superclass, const char *name, size_t extraBytes);
  ```

- 注册一个类

  ```objective-c
  void objc_registerClassPair(Class cls);
  ```

- 销毁一个类

  ```objective-c
  void objc_disposeClassPair(Class cls);
  ```

- 获取isa指向的Class

  ```objective-c
  Class object_getClass(id obj);
  ```

- 设置isa指向的Class

  ```objective-c
  Class object_setClass(id obj, Class cls);
  ```

- 判断一个对象是否为Class

  ```objective-c
  BOOL object_isClass(id obj);
  ```

- 判断对象是否是元类

  ```objective-c
  BOOL class_isMetaClass(Class cls);
  ```

- 获取父类

  ```objc
  Class class_getSuperclass(Class cls);
  ```

#### 成员变量

- 获取一个实例变量信息

  ```objective-c
  Ivar class_getInstanceVariable(Class cls, const char *name);
  ```

- 拷贝实例变量列表（最后需要调用free释放）

  ```objective-c
  Ivar *class_copyIvarList(Class cls, unsigned int *outCount);
  ```

- 设置和获取成员变量的值

  ```objective-c
  void object_setIvar(id obj, Ivar ivar, id value);
  id object_getIvar(id obj, Ivar ivar);
  ```

- 动态添加成员变量（已经注册的类是不能动态添加成员变量的）

  ```objective-c
  /**
  	cls: 添加的类
  	name： 变量名
  	size：大小
  	alignment： 对齐， 1
  	types：类型编码 @encode()
  */
  BOOL class_addIvar(Class cls, const char *name, size_t size, uint8_t alignment, const char *types);
  ```

- 获取成员变量的相关信息

  ```objective-c
  const char *ivar_getName(Ivar v); // 变量名
  const char *ivar_getTypeEncoding(Ivar v); // 变量 类型编码
  ```

#### 方法

- 获得一个实例方法、类方法

  ```objective-c
  Method class_getInstanceMethod(Class cls, SEL name);
  Method class_getClassMethod(Class cls, SEL name)
  ```

- 方法实现相关操作

  ```objective-c
  IMP class_getMethodImplementation(Class cls, SEL name);
  IMP method_setImplementation(Method m, IMP imp);
  void method_exchangeImplementations(Method m1, Method m2);
  ```

- 拷贝方法列表（最后需要调用free释放）

  ```objective-c
  Method *class_copyMethodList(Class cls, unsigned int *outCount);
  ```

- 动态添加方法

  ```objective-c
  BOOL class_addMethod(Class cls, SEL name, IMP imp, const char *types);
  ```

- 动态替换方法

  ```objective-c
  IMP class_replaceMethod(Class cls, SEL name, IMP imp, const char *types);
  ```

- 获取方法的相关信息（带有copy的需要调用free去释放）

  ```objective-c
  SEL method_getName(Method m);
  IMP method_getImplementation(Method m);
  const char *method_getTypeEncoding(Method m);
  unsigned int method_getNumberOfArguments(Method m);
  char *method_copyReturnType(Method m);
  char *method_copyArgumentType(Method m, unsigned int index);
  ```

- 选择器相关

  ```objective-c
  const char *sel_getName(SEL sel);
  SEL sel_registerName(const char *str);
  ```

- 用block作为方法实现

  ```objective-c
  IMP imp_implementationWithBlock(id block);
  id imp_getBlock(IMP anImp);
  BOOL imp_removeBlock(IMP anImp);
  ```

  

### 常见问题

1. OC消息机制

   - OC中的方法掉用其实都是转成了objc_msgSend函数的调用，给方法调用者发送了一条消息(方法名)

   - objc_msgSend底层有3大阶段
     - 消息发送（当前类、父类中查找）、动态方法解析、消息转发

2. 什么是Runtime

   - OC是一门动态性比较强的编程语言，允许很多操作推迟到程序运行时再进行
   - OC的动态性就是由Runtime来支撑和实现的，Runtime是一套C语言的API，封装了很多动态性相关的函数
   - 平时编写的OC代码，底层都是转换成了Runtime API进行调用

3. 具体应用

   - 利用关联对象（AssociatedObject）给分类添加属性
   - 遍历类的所有成员变量（修改textfield的占位文字颜色、字典转模型、自动归档解档）
   - 交换方法实现（交换系统的方法）
   - 利用消息转发机制解决方法找不到的异常问题
   - …...