---
title: Category
categories: 笔记
layout: single-column
tags: [笔记, Objective-C]
---



### 概念

> 分类里的对象方法会存放在这个类的类对象里。它回来程序运行时（runtime）将所有的方法合并到类对象中。



###底层结构
当对一个分类`NSObject+custom`进行编译(xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc NSObject+custom.m)后。在它的cpp文件内会发现这样一个结构体，此结构体就是存储这个分类及其所定义的属性、方法等信息，此结构体定义在`objc-runtime`头文件中。

```c++
struct _category_t {
  const char *name; // 分类的类名
  struct _class_t *cls; // 
  const struct _method_list_t *instance_methods; // 对象方法列表
  const struct _method_list_t *class_methods; // 类方法列表
  const struct _protocol_list_t *protocols; // 协议列表
  const struct _prop_list_t *properties; // 属性列表 
}
```

当程序运行时，程序会利用运行时机制将`instance_menthods`内所有方法合并到`name`值的类的类对象方法列表中，其他变量亦是如此。

### Category的加载处理过程

#### 加载顺序

1. 通过Runtime加载某个类的所有Category

2. 把所有的Category的方法、属性、协议数据、合并到一个大数组

   >  后面参与编译的Category数据会在数组的前面

3. 将合并后的分类数据(方法、属性、协议)插入到类原来数据的前面

#### 源码解读

1. objc-os.mm
  - _objc_init
  - map_images
  - map_images_nolock

2. Objc-runtime-new.mm
   - _read_images
   - remethodizeClass
   - attachCateggories
   - attchLists
   - realloc、memmove、memcpy

   

### +load方法

#### 调用时间

  - +load方法会在runtime加载类、分类时调用
  - 每个类、分类的+load，在程序运行过程中只调用一次

#### 调用方式

  ==**+load方法是根据方法地址直接调用，并不是经过~~objc_msgSend~~函数调用。**==

#### <span id='loadstep'>调用顺序</span>

> 在存在继承、分类的情况下的+load调用顺序

1. 先调用类的+load
   - 按照编译向后顺序调用(先便后，先调用)
   - 调用子类的+load之前会先调用父类的+load
2. 再调用分类的+load
   - 按照编译向后顺序调用(先编译、先调用)

#### 源码解读

  - objc-os.mm

    - _objc_init

    - load_images

    - prepare_load_methods

      > schedule_class_load
      >
      > add_class_to_loadable_list
      >
      > add_category_to_loadable_list

    - call_load_methosd

      > call_calss_loads
      >
      > call_category_loads
      >
      > (*load_methods)(cls, SEL _load)




### +initialize方法

#### 调用时间

- +initialize方法会在类第一次接收到消息时调用

#### 调用方式

- ==**+initialize是通过objc_msgSend函数调用的**==

#### <span id="initstep">调用顺序</span>

- 先调用父类+initialize，再调用子类+initialize

  - 如果分类实现了+initialize，就会覆盖本身的+initialize
  - 如果子类没有实现+initialize，会调用父类+initialize

#### 源码解读

- objc-msg-arm64.s
  - objc_msgSend
- objc-runtime-new.mm
  - class_getInstanceMethod
  - lookUpImpOrNil
  - lookUpImpOrForward
  - _class_initialize
  - callinitialize
  - objc_msgSend(cls, SEL_initialize)



### <span id='associatedObject'>关联对象</span>

####  相关API

- `objc_setAssociatedObject`: 设置关联对象
- `objc_getAssociatedObject`:  获取关联对象
- `objc_removeAssociatedObjects`: 移除所有关联对象

#### 实现代码

```objective-c
// .h file
@interface Person (Test)
@property (nonatomic, copy) NSString *name;
@end

// .m file
@implementation Person (Test)
- (void)setName:(NSString *)name
{
    objc_setAssociatedObject(self, @selector(name), name, OBJC_ASSOCIATION_COPY);
}

- (NSString *)name
{
    return objc_getAssociatedObject(self, @selector(name))
}
@end

```

  - 上述函数中key的用法
    - 定义全局变量`static const char NameKey;` 然后传入NameKey的地址 `&NameKey`
    - 直接传入指定值，例如`@"nameKey"`
    - @selecter(name)
    - ...



#### 底层结构(原理)

1. 实现关联对象的核心有：

  - AssociationsManager
  - AssociationsHashMap
  - ObjectAssociationMap
  - ObjcAssociation

2. objc4源码解读

   ![原理图](https://i.loli.net/2019/04/16/5cb54779a93c2.png)

3. 总结

   - 关联对象并不是存储在被关联对象本身内存中
   - 关联对象存储在一个全局统一的Manager中。
   - 设置关联对象为nill，即移除关联对象
     - name = nil；



### 常见问题

1. Category的使用场合？

   - 为某个类添加属性、方法、协议等。

2. Category的实现原理？

   - Category编译之后的底层结构是struct category_t，里面存储了分类对象方法、属性、协议等。在程序运行时，通过运行时机制将Category的数据合并到类信息中

3. Category和Extension的区别是什么？

   - Extension在编译的时候，其数据就已经包含在类信息中
   - Category在运行时，才会将数据合并到类信息中

4. Category中有load方法吗？什么时候调用，load方法能继承吗？

   - 有。
   - 在runtime加载类、分类时调用。
   - 可以继承，但一般情况下不会主动调用load方法，都是让系统自动调用。

   

5. load，initialize方法区别是什么？他们在category中的调用顺序？出现继承时的他们之间的调用过程？

   - 区别(调用方式，)

     - load 通过函数地址，initialize通过objc_msgSend调用，只调用一次
     - load是runtime加载类、分类时调用，initialize是类第一次接收到消息时调用，每个类只调用一次

     - 如果子类没有实现+initialize，会调用父类+initialize(所以父类的+initialize可能会调用多次)
     - 如果分类实现了+initialize，就会覆盖本身的+initialize

   - 调用顺序：
     - load[调用顺序](#loadstep)
     - initialize[调用顺序](#initstep)

6. Category能否添加成员变量？如果可以，如何给Category添加成员变量?

      不能直接添加。但可以间接添加，通过runtime 动态添加([关联对象](#associatedObject))



