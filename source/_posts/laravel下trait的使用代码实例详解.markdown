---
layout: post
title: '[Laravel]trait的使用代码实例详解'
date: 2022-10-02 22:14:49 +0800
categories: Laravel
---

- 关于Trait的理解

  Trait是PHP5.4引入的新概念，定义方式和class的定义方式类似。但是并不具备class的完整性。Trait看上去更像是一个class的一部分。它使不相关的两个class能够具有类似的行为。


- Trait的简单使用

  新建一个Trait

  由于数据库操作上使用了eloquent模型，在多表查询时需要指定表格关系。在多个表中都使用了hasmany()关联到了主表。
  于是便把这一段代码块单独提出来并放入了名为HasInvoices的Trait中，文件目录在App\Traits下。**注意Trait名与文件名应该相同。** 


- Trait的引入

  Trait的引入十分简单，在需要代码块的class中使用use Trait名就行。记得头部要用use引入Trait。


- 关于Trait的用法

  在上面所述的用法中，很显然用到的是完全相同的代码块。对于类似而不完全相同的的代码块复用，可以通过判断“不同点”来产生不同的结果。假设初始代码如下，人类A，动物类B，机器人类C。都具有付出成本，执行行为的能力。但由于彼此之间不具备继承关系，所以不适合使用继承。


  ``
    
      <?php
      class A{
       public $action = "逛街";
       public $money = 200;
       public function action(){
        echo "花了".$this->money.$this->action."\n";
       }
      }
      
      class B{
       public $action = "吃骨头";
       public $time = 2;
       public function action(){
        echo "花了".$this->time."分钟".$this->action."\n";
       }
      }
      
      class C{
       public $action = "跳舞";
       public $time = 30;
       public function action(){
        echo "花了".$this->time."分钟".$this->action."\n";
       }
      }
      $a = new A;
      $b = new B;
      $c = new C;
      echo $a->action();
      echo $b->action();
      echo $c->action();
  

  ``


**运行结果**

![img.png](img.png)


**将action函数提出到Trait，修改后代码**



```
  trait D{
  public function action(){
  echo "花了".(property_exists($this,'time')? $this->time."分钟":$this->money)
  .$this->action."\n";
  }
  }
  
  class A{
  use D;
  public $action = "逛街";
  public $money = 200;
  }
  
  class B{
  use D;
  public $action = "吃骨头";
  public $time = 2;
  }
  
  class C{
  use D;
  public $action = "跳舞";
  public $time = 30;
  }
  $a = new A;
  $b = new B;
  $c = new C;
  echo $a->action();
  echo $b->action();
  echo $c->action();

```

**运行结果**

![img_1.png](img_1.png)
