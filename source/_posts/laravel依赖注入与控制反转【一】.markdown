---
layout: post
title: '[Laravel]依赖注入与控制反转【一】'
date: 2022-09-20 22:14:49 +0800
categories: Laravel
---

> 在laravel中，依赖注入是将组件注入到应用程序中的一种行为，属于依赖的显示申明；控制反转是面向对象编程的一种设计原则，用于减低计算机代码之间的耦合度，是一个类把自己的的控制权交给另外一个对象，类间的依赖由这个对象去解决。

- laravel的依赖注入和控制反转是什么

  - 1、依赖注入
    
    依赖注入一词是由 Martin Fowler 提出的术语，它是将组件注入到应用程序中的一种行为。就像 Ward Cunningham 说的:
    依赖注入是敏捷架构中关键元素。
    
    例子：
    
    ``
        
        class UserProvider {
    
            protected $connection;
    
            public function __construct(){
    
                $this->connection = new Connection;
    
            }
    
            public function retrieveByCredentials( array $credentials ){
    
                $user = $this->connection
    
                                ->where( 'email', $credentials['email'])
    
                                ->where( 'password', $credentials['password'])
    
                                ->first();
                return $user;
            }
        }
    
    ``

    如果你要测试或者维护这个类，你必须访问数据库的实例来进行一些查询。为了避免必须这样做，你可以将此类与其他类进行 解耦 ，你有三个选项之一，可以将 Connection 类注入而不需要直接使用它。
    
    - 2、控制反转

        控制反转（Inversion of Control，缩写为IoC），是面向对象编程中的一种设计原则，可以用来减低计算机代码之间的耦合度。其中最常见的方式叫做依赖注入（Dependency Injection，简称DI），还有一种方式叫“依赖查找”（Dependency Lookup）。通过控制反转，对象在被创建的时候，由一个调控系统内所有对象的外界实体，将其所依赖的对象的引用传递给它。
    
        简单说来，就是一个类把自己的的控制权交给另外一个对象，类间的依赖由这个对象去解决。依赖注入属于依赖的显示申明，而依赖查找则是通过查找来解决依赖。
        
        控制反转并不是一种方法，而是一种设计思想，laravel和Spring框架框架一样，不用纠结名词上的反转，解释就是传统的对象都是主动取赋予对象的属性，而框架内我们所做的只是操作容器，容器会自动的通过映射来查找需要的属性并进行赋予，对象只是被动的接受依赖对象，从对象属性的获取方式来看问题。
    
