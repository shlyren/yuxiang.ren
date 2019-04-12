---
title: KVO及KVC
categories: 笔记
layout: single-column
tags: [笔记, OC]
---

### KVO

> KVO全程为key-value observing，即键值监听。通常用于监听实例对象某个属性值的变化的。

#### 原理

如果某个对象使用了KVO监听，那么这个实例对象的isa指针指向`NSKVONotifying_*`这个类对象。这个类是由runtime动态生成的一个类，并且这个类的**suppclass**指针指向添加KVO监听的实例对象的类对象。在这类中，他实现了所监听的属性的setter方法，并在此方法中调用了``_NSSetIntValueAndNotify()``这个函数。其大致实现如下（伪代码）：

```objective-c
@interface NSKVONotifying_Myclass : Myclass @end
@implementation NSKVONotifying_Myclass
- (void)setAge:(int)age 
{
    _NSSetIntValueAndNotify();
}

- (void)didChangeValueForKey:(NSString*)key 
{
  // 通知监听器 调用监听器代码
    [observe observeValueForKeyPath: key ofObject: self change: nil context: nil];
}

// 屏蔽内部实现，隐藏真实类的存在
- (Class)class 
{
  return [Myclass class];
}
- (void)dealloc
{
  // 收尾工作
}
- (BOOL)_isKVOA
{
	return true;
}

// Foundation 框架函数
/*
void _NSSetIntValueAndNotify() {
    [self willChangeValueForKey:@"age"];
    [super setAge: age]; // 原来方法实现
    [self didChangeValueForKey:@"age"];
}
*/
@end
```

- `_NSSet*ValueAndNotify()`内部实现(调用顺序)
  - 调用`willChangeValueForKey:`
  - 调用原来的`setter`
  - 调用`didChangeValueForKey`
  - `didChangeValueForKey`内部调用`observeValueForKeyPath:ofObject:changecontext:`

* 证明`NSKVONotifying_*`存在`-calss`，`-dealloc`，`-_isKVOA`

  ```objective-c
  // 通过class打印其所有方法
  - (void)printMethodNameOfClass:(Class)cls
  {
  	unsigned int count;
    // runtime 函数
    Method *methods = class_copyMethodList(cls, &count);
    for(int i = 0; i < count; i++) {
      Method method = methods[i];
   		NSString *methodName = NSStringFromSelector(method_getName(method));
      NSLog(@"%@", methodName);
    }
    
    // 释放
    free(methods);
  }
  ```



#### 问题

1. KVO本质？
  - 利用RuntimeAPI动态生成一个子类，并且让instance对象的isa指向这个全新的子类
  - 当修改instance对象的属性时，会调用Foundation的``_NSSetXXXValueAndNotify``函数
    - ``willChangeValueForKey:``
    - 父类原来的setter
    - ``didChangeVaueForKey:``
      - 触发监听器(Observe)的监听方法： `observeValueForKeyPath:ofObject:change:context:`

2. 如何手动触发KVO？

- 手动调用以下方法：

  ```objective-c
  [instance willChangeValueForKey:@"key"];
  [instance didChangeValueForKey:@"key"];
  ```


3. 直接修改成员变量会触发KVO么？

- 不会触发KVO



---

### KVC

> KVC全程为Key-Value coding，俗称键值编码，是通过一个key来访问某个属性

#### 常见API
  - `- (void)setValue:(id)value forKey:(NSString*)key;`
  - `- (void)setValue:(id)value forKeyPath:(NSString *)keyPath`;
  - `- (id)valueForKey:(NSString *)key;`
  - `- (id)valueForKeyPath:(NSString *)keyPath;`

#### <span id="set">赋值原理</span>
![赋值原理](https://i.loli.net/2019/04/12/5caff125669da.png)

1. 按照`setKey:`、`_setKey:`顺序查找方法
  - 如果有，传递参数并调用方法
  - 如果没有，进行第二步，

2. 查看`+ (BOOL)accessInstanceVariablesDirectly`方法的返回值(默认为YES)
  - 返回YES: 按照`_key`, `_isKey`,`key`,`isKey`顺序查找成员变量
    - 找到直接赋值
    - 未找到进行第三步
  - 返回NO: 不允许直接访问成员变量，进行第三步

3. 调用`setValue:forUndefinedKey:`方法并抛出异常`NSUnknowKeyException`

#### <span id="get">取值原理</span>
![取值原理](https://i.loli.net/2019/04/12/5caff1fca5971.png)

1. 按照`getKey`，`key`，`isKey`，`_key`顺序查找方法
   - 如果有，返回对应方法反的的值
   - 如果没有，在进行第二步
2. 查看`+ (BOOL)accessInstanceVariablesDirectly`方法的返回值(默认为YES)
   - 返回YES: 按照`_key`, `_isKey`,`key`,`isKey`顺序查找成员变量
    - 找到直接赋值
    - 未找到进行第三步
  - 返回NO: 不允许直接访问成员变量，进行第三步
3. 调用`valueForUndefinedKey:`方法并抛出异常`NSUnknowKeyException`

####  问题

1. 通过KVC修改对象属性值会触发KVO吗？

   会，不管有没有调用`setter`方法都会触发KVO

2. KVC赋值和取值原理是什么？

   - [赋值原理](#set)
   - [取值原理](#get)