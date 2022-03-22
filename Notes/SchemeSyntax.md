<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](https://github.com/thlorenz/doctoc)*

- [Scheme语法汇总](#scheme%E8%AF%AD%E6%B3%95%E6%B1%87%E6%80%BB)
- [SICP Picture Language](#sicp-picture-language)
- [R5RS语法解读](#r5rs%E8%AF%AD%E6%B3%95%E8%A7%A3%E8%AF%BB)
  - [1. 总览](#1-%E6%80%BB%E8%A7%88)
  - [2. 词法约定](#2-%E8%AF%8D%E6%B3%95%E7%BA%A6%E5%AE%9A)
  - [3. 基本概念](#3-%E5%9F%BA%E6%9C%AC%E6%A6%82%E5%BF%B5)
  - [4. 表达式](#4-%E8%A1%A8%E8%BE%BE%E5%BC%8F)
  - [5. 程序结构](#5-%E7%A8%8B%E5%BA%8F%E7%BB%93%E6%9E%84)
  - [6. 标准过程](#6-%E6%A0%87%E5%87%86%E8%BF%87%E7%A8%8B)
  - [7. 形式化的语法和语义](#7-%E5%BD%A2%E5%BC%8F%E5%8C%96%E7%9A%84%E8%AF%AD%E6%B3%95%E5%92%8C%E8%AF%AD%E4%B9%89)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Scheme语法汇总

SICP中用的[R5RS版本的Scheme文档](https://docs.racket-lang.org/r5rs/r5rs-std/r5rs.html)。

首先请注意：
- 谈到语法，请特别注意使用的编译器，支持些什么，不支持些什么，某个语法来自于何处。
- 推荐使用SICP中统一使用的标准语法也即是R5RS版本的Scheme，Racket中的`#lang sicp`提供了良好的支持。
- 如果使用`#lang racket`之类，某些语法可能会有些微区别需要注意。

定义函数：
```scheme
(define (func args)
    (define (inner-func args) ret-value)
    return-value
)
```
- 变长参数，`(define (func a . b) ...)`，则`b`可以对应传入零个或者多个参数，组合为一个列表通过参数 `b` 引用，没有时则为`nil`。

S-表达式：
- 每个`()`的式子称为S表达式，其中第一个值作为函数（运算符也是函数），然后作用于后续的所有参数上求值得到结果。
- 使用单引号`'`或者反引号`` ` ``用于S表达式前，则不对S表达式求值。
- 分为普通表达式与特殊形式。
- S表达式可以嵌套。
- 普通表达式按照顺序依次求值，一定有一个值，特殊形式则各有各的规则不一定有值。

特殊形式：
- `define`用于定义函数或值。
- `if`只会对两个子表达式之一求值。
- `and or`具有短路求值特性。

条件与谓词：
- `cond if`
- 真假`true #t`与`false #f`，`#lang sicp`中是等价的。
- 关系运算：`> >= < <= =`

内置过程（函数）：
- [R5RS Scheme的标准过程文档](https://docs.racket-lang.org/r5rs/r5rs-std/r5rs-Z-H-9.html)。
- `(newline)` 输出新行。
- `(display obj)` 输出一个对象的字符串表示。


来自Racket的过程或常量：
- 不在R5RS版本的Scheme语法中，但在Racket的引入`#lang sicp`后可以使用。如果需要移植到其他支持R5RS版本的Scheme的解释器上的话需要考虑这些值或函数是否存在或含义是否相同。
- `nil : null?`,`'()`的别名，空值？
- `inc x`自增，等价于`(+ x 1)`。
- `dec x`自减，等价于`(- x 1)`。
- `the-empty-stream : stream?`，空的流。
- `(cons-stream first-expr rest-expr)`产生一个`stream`。
- `(stream-null? s) → boolean?`流是否为空，返回`#t #f`。
- `(runtime) → natural-number/c`微秒为单位的当前时间测量，有一个固定的开始。
- `(random n) → real?`生成0到n-1的随机整数，如果n是整数，如果不是，则生成0到n（不包含）的随机（浮点）数。
- `(amb expr ...)`amb运算符。这是什么东西？
- `true false`表示`#t #f`。
- `(identity v)`返回参数自己。
- `(error message-sym) → any`抛出错误，打印错误信息，有多个重载。

基本数学过程：
- `(sqrt x)`平方根。
- `(log x)` 自然对数。
- `(exp x)` 自然对数的底数e的幂。
- `(expt a b)` 求a的b次方。
- `(remainder a b)` 求余`a % b`。
- `(even? n)` 判断是否为偶数，`odd?`奇数。
- `(gcd a b)` 最大公约数，`lcm`最小公倍数。

序对操作：
- `(cons a b)`得到序对`(a . b)`
- `(car x)`，取序对第一个元素。
- `(cdr x)`，取序对第二个元素。
- `(cadr x)` 等价于`(car (cdr x))`，类似形式很多比如`caddr cadar`同理。

列表：
- 文档：[Pairs and lists](https://docs.racket-lang.org/r5rs/r5rs-std/r5rs-Z-H-9.html#%25_sec_6.3.2)
- `nil`Racket提供，等价于`'()`空表，或者`(list)`。
- 表`(list 1 2 3)`等价于`'(1 2 3)`。
- 基本操作`null?`，检查是否是空表。


## SICP Picture Language

在2.2.4节，介绍了SICP Picture Language作为实例：
```scheme
#lang sicp
(#%require sicp-pict)
(paint einstein)
```
- 使用`(#%require sicp-pict)`添加图形语言的支持。
- 在DrRacket中运行可以查看到绘制出来的图片，在VsCode只会命令行输出对象的字符串表示。
- [SICP Picture Language文档](https://docs.racket-lang.org/sicp-manual/SICP_Picture_Language.html)

图形描述语言总结：
- `painter`是表示绘制信息的数据，函数类型的数据，使用`frame`作为参数。
- `frame`表示一种二维变换，其数据由坐标原点和两个坐标轴的单位向量构成。坐标和向量都用向量数据类型表示。相关函数：
    - `frame?` 
    - `make-frame` 
    - `frame-origin` 
    - `frame-edge1` 
    - `frame-edge2` 
    - `make-relative-frame` 
    - `frame-coord-map` 使用该`frame`对坐标进行变换。
- 绘图的区间是`(0,0) - (1,1)`，坐标用向量表示，向量是使用两个坐标表示的数据。相关函数：
    - `vect?`
    - `make-vect`
    - `vector-xcor`
    - `vector-ycor`
    - `vector-add`
    - `vector-sub`
    - `vector-scale`
    - `zero-vector`
- 线段`segment`是坐标的序对，表示一个线段。相关函数：
    - `segment?`
    - `make-segment`
    - `segment-start`
    - `segment-end`
    - `vects->segments` 点集转线段的列表，两两一对。
- 一些原始`painter`：使用点、坐标、线段、颜色、函数、加载的图片等数据在单位矩形内绘制图形的`painter`。
    - `painter/c`
    - `number->painter`
    - `color->painter`
    - `segments->painter` 绘制线段集合。
    - `vects->painter` 
    - `procedure->painter` 按照一个过程绘制，假定在单位矩形内。
    - `bitmap->painter`
    - `load->painter`
- 高阶`painter`：也就是接受一个或多个`painter`作为参数然做一些转换后返回一个新的`painter`，使用这些高阶函数时`painter`作为数据满足**闭包性质**，所以可以将这些高阶函数组合嵌套使用。函数：
    - `transfrom-painter` 传入一个`frame`转换的坐标原点和坐标轴数据，返回一个对`painter`做此转换的高阶函数（接受`painter`返回`painter`的函数）。
    - `flip-horiz` 水平翻转。
    - `flip-vert` 数值翻转。
    - `rotate90 rotate180 rotate270` 逆时针旋转。
    - `beside` 左右并列排布两个`painter`。
    - `below` 上下排列两个`painter`。
    - `above3` 上下排列三个`painter`。
    - `superpose` 重叠绘制两个`painter`。
- 一些简单的内建`painter`:
    - `black white gray` 绘制纯色。
    - `diagonal-shading` 从右上角黑色到左下角灰色的渐变。
    - `mark-of-zorro` 绘制一个Z。
    - `einstein` 绘制一个爱因斯坦的图像，常用于测试。
    - `(escher)` 绘制埃舍尔的画Square Limit。
- 将`painter`绘制出来：`paint`函数。

## R5RS语法解读

翻译总结自[Revised5 Report on the Algorithmic Language Scheme](https://schemers.org/Documents/Standards/R5RS/HTML/r5rs.html)，可能不是所有细节都准确和完整，但大体方向是不会有问题的。

### 1. 总览

语义：
- 静态作用域，每一个变量的使用都被绑定到一个词法作用域内的变量所绑定。
- 动态类型，类型依赖于底层的值，而非变量。
- 实现一定要求尾递归。
- 参数传递只有值传递。
- Scheme的数值计算模型：整数同时是一个有理数，有理数同时是一个实数，实数同时是一个复数，自动类型提升并做精确的计算。

语法：
- 同所有Lisp方言一样，非常简单，使用小括号包含的前缀表达式。无论是数据还是过程。
- 可以对S表达式求值或者不求值。
- 可以使用`eval`对数据求值，使用`read`将S表示式读取为数据。

记号和术语：
- Scheme的一部分语法是实现可选的，一部分特性被标记为库。
- 错误处理和未定义行为：
    - 错误情形指错误被捕获。当错误发生时，实现需要检测并报告错误。
- 命名约定：
    - 如果过程返回布尔值，则以`?`结尾。
    - 如果一个过程修改了前面定义的变量其中的值，那么以`!`结尾。
    - 命名中出现`->`表示将一个对象从一个类型转换为另一个类型，如`list->vector`。


### 2. 词法约定

编写Scheme程序时的词法约定：
- 除了在字符和字符串常量中之外不区分大小写。`Foo`和`fOO`是同一个标识符。

标识符：
- 字母、数字和扩展的字符可以构成标识符，数字不能开头。
- 扩展字符包括：`! $ % & * + - . / : < = > ? @ ^ _ ~`。
- 标识符的两个用途：
    - 变量或者词法关键字。
    - 放在字面量中作为符号（symbol）。

空白符与注释：
- 空格换行（实现通常会添加的制表符、换页符等）等空白符，用以改善可读性，并且分隔词法记号，没有其他任何作用。空白符不能出现在一个token中，可以出现在字符串中，此时是有含义的。
- 分号`;`用以标识行注释的起始。注释被视为与空白符同作用。

其他记号：
- `.+-`可出现在数字字面值表示中，也可以用于标识符中，但不能用于开头。单独字符也可以用作标识符。`.`也被用作可变参数列表。
- `()`标识分组或者表。
- `'`单引号用作字面量。
- `` ` ``表示几乎是常量的数据。
- `, ,@`和反引号连用。
- `"`双引号用于字符串。
- `\`反斜杠用于字符常量或者字符串常量中的转义。
- `[ ] { } |`为以后可能的扩展预留。
- `#`视情况用于多种用途：
    - 表示真假的布尔常量`#t #f`。
    - `#\`表字符常量。
    - `#()`表示向量常量。
    - `#e #i #b #o #d #x`用于数字。


### 3. 基本概念

变量、词法关键字、作用域：
- 表示一种语法的标识符叫做词法关键字。称为作绑定到了这个语法。
- 一个表示一个存储位置的标识符叫做变量，称为绑定到了这个位置（内存空间）。这个位置中保存的值称作变量的值。
- 所有可见的绑定集合组成了**环境**（environment ）。
- 特定的表达式可以用来创建新的语法，将词法关键字绑定到这些新语法上。其他的表达式则创建新的位置，并将变量绑定到这个位置。
- 最基本的变量绑定是lambda表达式，所有的变量绑定都可以被等价为lambda表达式。其他的变变量绑定有`let let* letrec do`。
- Scheme是带有块结构的静态作用域的语言，所有的绑定都有一个作用域，在这其中，绑定才可见。这个作用域取决于建立绑定的特定结构。比如如果是lambda表达式，那么作用域就是整个lambda表达式。所有的标识符引用都指向最内层绑定的那个东西，如果在各层作用域中都没有这个标识符，那么就是最顶层的环境。如果都没有找到，就会提示未绑定（unbound）。

互斥的类型（Disjointness of types）：
- 没有一个对象满足下列所有谓词：`boolean? pair? symbol? number? char? string? vector? port? procedure?`。
- 这些谓词用来判断布尔、序对、符号、数值、字符、字符串、向量、端口、过程。空表`'()`是比较特殊的对象，不满足上面所有的谓词，用`null?`来判断。
- 尽管有单独的布尔类型，但所有的Scheme对象都可以被用来做条件判断，除了`#f`所有的对象都视为真。

外部表示（external representations）：
- Scheme中的一个重要概念就是一个对象的字符序列形式的外部表示。比如值`28`的外部表示就是字符串`28`，包含8和13的列表的外部表示就是`(8 13)`。
- 一个对象的外部表示并不一定唯一，比如`(8 13)`也可以表示为`(8 . (13 . ()))`。
- 许多对象都有标准的外部表示，但是比如过程就没有（特定实现可能会定义）。
- 可以在程序中使用外部表示来获取这个对象，使用`quote`。
- 外部表示可以用来输入或者输出，`read`过程解析外部表示，`write`过程用以生成外部表示。他们共同组成了强大的输入输出设施。
- Scheme语法的特性就是任何表示表达式的字符序列，同时又是某个对象的外部表示。这是一种强有力的手段，读写设施（`read/write`）可以像解释器或者编译器将程序视作数据一样来读写数据。

存储模型：
- 序对、向量、字符串这些类型隐式地表示存储位置或者存储位置的序列。可以使用比如`string-set!`改变字符串某个位置存储的值，但表示字符串的变量依然指向这个位置。
- 从一个存储位置获取对象可以使用`car vector-ref string-ref`等过程。
- 每一个存储位置都被标记了是否正在被使用，未被使用的位置不会被任何变量引用。
- 当变量被绑定时，某些未被使用的位置可能被启用，用来绑定到该变量。
- 某些系统中会将常量放到只读的内存中，Scheme中的类似手段是，将一个存储位置表示为不可变（immutable），如果它表示字面量的话。

恰当的尾递归：
- Scheme的实现被要求正确地尾递归。需要支持非常量数量的尾递归调用，任何一个尾递归都只应该返回一次，即是最终的结果。
- 如果下列的`<tail expression>`是一个尾递归上下文中话，那么下列表达式都是尾递归。
```
(if <expression> <tail expression> <tail expression>)
(if <expression> <tail expression>)

(cond <cond clause>+)
(cond <cond clause>* (else <tail sequence>))

(case <expression>
          <case clause>+)
(case <expression>
          <case clause>*
          (else <tail sequence>))

(and <expression>* <tail expression>)
(or <expression>* <tail expression>)

(let (<binding spec>*) <tail body>)
(let <variable> (<binding spec>*) <tail body>)
(let* (<binding spec>*) <tail body>)
(letrec (<binding spec>*) <tail body>)

(let-syntax (<syntax spec>*) <tail body>)
(letrec-syntax (<syntax spec>*) <tail body>)

(begin <tail sequence>)

(do (<iteration spec>*)
                    (<test> <tail sequence>)
          <expression>*)

where

<cond clause> ---> (<test> <tail sequence>)
<case clause> ---> ((<datum>*) <tail sequence>)

<tail body> ---> <definition>* <tail sequence>
<tail sequence> ---> <expression>* <tail expression>
```


### 4. 表达式

表达式被分为原始的和派生的。原始表达式类型包括变量和过程调用，派生的表达式被定义为库特性。

1、原始表达式：
- 变量引用：
    - 即变量作为表达式：`<variable>`。
    - 得到变量绑定的位置处的值，如果未绑定则抛出错误。
- 字面量表达式：
    - 形式：`(quote <datum>) '<datum> <constant>`。
    - `<datum>`可以是任何Scheme对象的外部表示，`'<datum>`是`(quote <datum>)`的缩写，等价。
    - 常量可以是字符串常量，数值常量，字符常量，布尔常量，比如：`"hello" 10 #t`。
    - 使用`!`结尾的修改函数修改常量会报错。
- 过程调用：
    - 形式：`(<operator> <operand1> ...)`，也叫做组合式。
    - 求值顺序是不确定的，整个表达式和传入的操作数表达式总是以同样的规则求值。但并发求值的结果需要与顺序求值一致。
    - 空表`()`不是一个语法上合法的表达式，不能被求值。
- 过程：
    - 形式：`(lambda <formals> <body>)`，`<formals>`是参数的列表。`<body>`是一个或多个表达式的序列。
    - `lambda`表达式被求值为一个过程。
    - 当`lambda`求值时生效的环境被记录为过程的一部分。
    - 调用`lambda`是，`lambda`求值时的环境会被扩展，形式参数到实际参数内存位置的绑定会被添加到环境中。
    - `lambda`体内的表达式会在这个扩展了的环境中依次被求值。最后一个表达式作为这个过程调用的返回值。
    - `<formal>`形参列表的格式为`(<var1> ...)`或者`(<var1> ... <varn> . <varn+1>)`，后者接受可变参数，并且最后一个形式参数为对应位置0个或多个参数的列表。
    - 每个过程都以其存储位置作为标记，以便`eqv? eq?`能够工作。
    - 如果要将所有的参数都视为可变参数，可以写为`(lambda x ...)`则x为所有传入参数构成的列表。
- 条件：
    - 语法：`(if <test> <consequent> <alternate>)`或者`(if <test> <consequent>)`。
    - 其中`<Test>` `<consequent>` `<alternate>`可以是任意表达式。
    - 先对`<Test>`求值，为真则求前者，假则求后者，如果为假且假对应结果未指定，则结果未定义。
- 赋值：
    - 语法：`(set! <variable> <expression>)`。
    - 对`<expression>`求值，然后将结果存储到`<variable>`绑定的位置。
    - `set!`表达式的结果是不确定的（一般来说是没有返回值）。

2、派生表达式：

条件：
- 库语法`cond`表达式：
    - `(cond <clause1> <clause2> ...)`
    - 每个`<clause>`都形如`(<test> <expression1> ...)`，也可以形如`(<test> => <expression>)`。
    - 最后一个子句成为else子句，形如`(else <expression1> <expression2> ...)`。
    - 依次对每一个`<test>`求值，直到某个`<test>`结果为真，然后一次求这个子句后的多个表达式，返回最后一个表达式的值。
    - 如果某个子句只有`<test>`，其后没有表达式，那么其值为真时作为最终结果返回。
    - 如果自举是`=>`形式的话，那么对`<expression>`求值的结果必须是一个过程，其接受一个参数，然后返回使用这个过程传入`<test>`表达式的值得到的结果。
    - 如果所有`<test>`为假，且没有else子句，那么结果未指定（unspecified）。如果有，那么就返回else子句的最后一个表达式的值。
- 库语法`case`表达式：
    - 形式：` (case <key> <clause1> <clause2> ...)`
    - `<key>`可以是任何表达式。
    - 每个字句形如`((<datum1> ...) <expression1> <expression2> ...)`，其中的`<datum>`是某个对象的外部表示（external representation），所有的`<datum>`必须不同，最后一个可以是形如`(else <expression1> <expression2> ...)`的else子句。
    - 对`<key>`求值后依次和每个字句中的`<datnm>`比较（使用`eqv?`），然后和`cond`类似，依次求值并返回最后一个表达式。如果都不相同，那么就对else子句中表达式求值。
- 与：
    - 形式：`(and <test1> ...)`。
    - 从左到右求值，短路求值，某一个是false就返回，否则继续往后求。所有都为true则返回最后一个表达式值。
    - 无表达式返回`#t`。
- 或：
    - 形式：`(or <test1> ...)`。
    - 从左到右求值，短路求值，某一个是true就返回，如果所有都是false，那么返回最后一个表达式值（正常来说应该是`#f`）。
    - 无表达式返回`#f`。

绑定结构：
- 有3种绑定结构`let let* letrec`，带给了Scheme块结构。这三种结构是等价的，但是为其绑定建立的作用域不同。
    - 在`let`结构中，绑定的初始值是在所有变量被绑定之前计算的。
    - `let*`中，求值和绑定是顺序进行的。对一个变量对应表达式求值之后即进行绑定。
    - 而在`letrec`中，当他们的初始值被计算时所有绑定都是生效的，所以这种情况下允许相互递归。
- `let`绑定：
    - 形式：`(let <bindings> <body>)`。
    - `<bindings>`的形式：`((<variable1> <init1>) ...)`。`<init>`是一个表达式，而`<body>`是一个或者多个表达式，惯例返回最后一个。
    - `let* letrec`形式完全相同，但结果存在差异。
- 差异：
    ```scheme
    ; let
    (let ((x 2) (y 3))
      (* x y)) ; ==> 6
    
    ; let*
    (let ((x 2) (y 3))
      (let* ((x 7)
             (z (+ x y))) ; x is newly set 7, so z is 10, if use let z will be 5
        (* z x))) ; ===> 70
    
    ; letrec
    (letrec ((even? (lambda (n) (if (zero? n) #t (odd? (- n 1)))))
             (odd? (lambda (n) (if (zero? n) #f (even? (- n 1)))))
            )
            (even? 88) ; #t
    )
    ```
- 值得注意的是`letrec`，初始值再结果的环境中求值（不确定的顺序），每个变量的作用域都是整个`letrec`块。这使得定义相互递归成为可能。有一个限制就是，必须要能够在不知道的每个相互引用的变量的具体指的情况下求得`<init>`（典型如递归定义过程）。如果不能这样的话，会报错。在最常见的情况下，`letrec`的所有变量都是`lambda`表达式。

其他结构：
- 序列（顺序执行）：
    - 库语法：`(begin <expression1> <expression2> ...)`。
    - 从左到右依次求值每一个表达式，返回最后一个表达式的值。
    - 常用在比如输入输出。
- 迭代：`do`：
    - 形式：
    ```scheme
    (do ((<variable1> <init1> <step1>) 
         ...)
        (<test> <expression> ...)
        <command> ...)
    ```
    - 求值规则：求值所有的`<init>`表达式（顺序不定），将`<variable>`绑定到新位置，将`<init>`表达式结果绑定到对应的`<variable>`的位置。然后循环阶段开始。
    - 每轮循环以求值`<test>`开始，如果为false，那么求值`<command>`。然后对所有`<step>`求值之后将其绑定到对应的`<varaible>`，然后开始下一轮循环。
    - 如果`<test>`求值为true，那么对后续的所有表达式依次求值，并返回最后一个表达式的值，如果没有表达式，那么返回值未指定。
    - `<step>`可以被省略，此时等价于`(<variable> <init> <varaible>)`
    - 例子：
    ```scheme
    ; iteration
    (do ((vec (make-vector 5)) ; (<variable1> <init> <step>)
         (i 0 (+ i 1)))
        ((= i 5) vec) ; (<test> <expression> ...)
        (vector-set! vec i (* i i)) ; set value of index i to i*i
    )
    ; result: #(0 1 4 9 16)
    ```
- 迭代：命名let：
    - 形式：`(let <variable> <bindings> <body>)`。
    - 相比普通的`let`多了一个变量，提供比`do`更通用的循环，并且也可以表达递归。
    - 命名`let`和普通的相比语义基本相同，区别仅仅是在`<body>`内将`<variable>`绑定为了一个过程，它的形式参数就是`let`中绑定的那些变量，函数体就是`<body>`。这样`<body>`的执行就可以通过在内部调用`<variable>`来重复了。
    - 例子：
    ```scheme
    ; named let
    (let loop ((a 10))
        (if (> a 0)
            (begin (display a) (display " ") (loop (- a 1)))
        )
    )
    ; result: 10 9 8 7 6 5 4 3 2 1
    ```
- 延迟求值/懒惰求值
    - 形式：`(delay <expression>)`。
    - 和`force`过程一起实现懒惰求值（或者需要时再调用）。
    - 返回一个称为promise的对象，这个对象在以后可能会被`force`过程询问以对其中的表达式求值，然后传递结果值。
- `quasiquote`：
    - 形式：`quasiquote <qq template>)` 或者`` `<qq template>``。
    - 是一种在构建列表或者向量时非常有用的形式，如果说大部分但不是所有的结构都提前知道时，就可以用`quasiquote`。
    - 如果`<qq template>`中没有出现逗号，那么`` `<qq tempalte>``就等价于`'<qq tempalte>`。如果出现了逗号，那么逗号后面的部分就不被`quote`。会将其求值结果插入到对应位置。
    - 如果逗号后出现`@`，即出现`,@`，那么中间的值需要求值为一个列表，并将列表去掉，将其中所有的值插入到对应位置，而不是插入列表。
    - `,@`仅应该出现在列表或者向量中的`quasiquote`中。
    - `quasiquote`可以嵌套。
    - 例子：
    ```scheme
    `(,(+ 1 2) 4) ; (3 4)
    `(,@(cons 1 nil) 3) ; (1 3)
    `,(+ 1 2) ; 3
    `,`,`,`(1 2) ; (1 2)
    ```
    - `,<expression>` 等价于 `(unquote <expression>)`。
    - `,@<expression>` 等价于 `(unquote-splicing <expression>)`。
    - 他们都是`quote`的逆操作，不过只能用于`quasiquote`中，并且后者只能用于列表和向量的`quasiquote`中。

3、宏：

Scheme程序可以定义和使用派生的表达式类型。
- 程序定义的表达式类型有自己的语法：`(<keyword> <datum> ...)`。
    - 其中`<keyword>`是一个标识符，唯一地决定了表达式类型。
    - 这个标识符被称作宏的句法（词法？句法？）关键字（syntactic keyword），或者简单关键字。`<datum>`的数量和他们的语法取决于表达式类型。
    - 每一个宏的实例叫做一个宏的使用（a use of the macro）。
    - 定义了怎样将一个宏转录成更为原始的表达式的规则集称之为宏的转换器（transfromer of the macro）。
- 宏包含两个部分：
    - 一个表达式集合，用以建立宏关键字到宏转换器的联系，并控制宏内的作用域。
    - 一个定义宏转换器的模式语言。
- 宏的词法关键字绑定可能会覆盖变量绑定，本地变量绑定可能会覆盖关键字绑定。所有使用模式语言定义的宏都是引用透明的，因此可以保留Scheme的词法作用域：
    - 如果一个宏转换器为一个标识符（变量或者关键字）插入了一个绑定。
    - todo。

将结构绑定到句法关键字：todo。

模式语言（pattern language）：todo。

### 5. 程序结构

程序：
- 一个Scheme程序包含一系列表达式，定义和语法定义。表达式见见上一节，定义和语法定义见本节。
- 程序一般来说保存在文件中或者在Scheme系统中交互式地输入。当然其他类型也是有可能的。
- 出现在最顶层的定义和语法定义可以被声明式地翻译，然后在顶层环境中发生绑定或者修改已有绑定的值。
- 最顶层的表达式被命令式地翻译，他们按照程序加载或者调用的顺序执行，典型操作是执行某些初始化操作。
- 最顶层的`(begin <form11> ...)`就等价于这些表达式、定义、语法定义的序列。

定义：
- 在一些（但不是所有）能够使用表达式的上下文中可以使用定义。定义仅仅能用于程序的顶层和`<body>`的开始位置。
- 定义可以是以下形式：
    - `(define <variable> <expression>)`
    - `(define (<variable> <formals>) <body>)`
    - `<formals>`可以是零个或多个变量。或者是一个或多个变量后跟`.`然后跟一个变量。
    - 上一个形式等价于：`define <variable> (lambda (<formals>) <body>))`
    - `(define (<variable> . <formal>) <body>)`这个形式等价于`(define <variable>(lambda <formal> <body>))`。

顶层定义：
- 如果变量已经绑定了的话，顶层的`(define <variable> <expression>)`本质上和`(set! <variable> <expression>)`效果相同。
- 如果未绑定的话，那么定义会先绑定然后执行赋值。对未绑定的变量执行`set!`会报错。
- 一个Scheme实现中会使用一个尝试环境，其中所有可能的变量都被绑定了位置，但其中的值未指定。在这种实现中对这些变量`set!`赋值就等价于定义。

内部定义：
- 在`<body>`的最顶部可以出现定义。
- 更准确地说是`lambda let let* letrec let-syntax letrec-syntax`表达式或者一个合适形式的定义的顶层。
- 这些定义被叫做内部定义。
- 内部定义定义的变量是局部于这个`<body>`的。这种情况下，变量被绑定而不是被赋值，绑定的作用域是整个`<body>`。
- 一个包含内部定义的`<body>`总是等价于对应的`letrec`表达式。同`letrec`，必须要能够求出每一个内部定义的值，所以不能引用正在被定义的变量。
- 内部定义中出现`begin`包含起来的一系列定义，相当于将这一系列定义一次放在对应位置。

语法定义：
- 仅在程序顶层有效。
- 形式：`(define-syntax <keyword> <transformer spec>)`。
- `<keyword>`是标识符，`<transfromer spec>`必须是`syntax-rules`的一个实例。通过将`<keyword>`绑定的特定的转换器来扩展顶层的句法环境（syntactic environment）。
- 没有与`define-syntax`类似的内部定义。
- 但是宏可以在任何允许的环境下展开为定义或者语法定义，当一个定义或者语法定义覆盖了一个句法关键字是会报错。

### 6. 标准过程

本节描述Scheme的内建过程，Scheme的顶层环境会被初始化，一些有用的变量和过程会被绑定在其中。
- 比如`abs`就是一个库函数，默认添加，值为求绝对值的函数。
- 可以使用顶层定义绑定变量，也可以使用赋值修改这种绑定。这些操作并不会修改Scheme内置过程的行为。修改Scheme内置过程的定义可能会有不确定的效果（但一般来说是直接覆盖库的定义）。

等价谓词：
- 谓词是永远返回布尔值（也就是`#t`或者`#f`）的过程。
- 等价谓词就像是数学中的等价关系一样（满足自反、对称、传递）。
- 其中`eq?`是最好也是最具有分辨性的，`equal?`是最宽泛的，`eqv?`的分辨性比`eq?`略低。
- `(eqv? obj1 obj2)`：
    - 简单地说，当obj1和obj2通常可以视为同一对象时，为`#t`。
    - `eqv?`返回`#t`当下面几种情况：
        - `obj1 obj2`同时为`#t`或者`#f`。
        - 都是符号且满足：`(string=? (symbol->string obj1) (symbol->string obj2))`
        - 都是数，且数值相等，无论是精确表示地还是不精确表示的数（他们必须都是精确表示或者都是不精确表示，exact and inexact）。
        - 都是字符，且使用`char=?`判断相等。
        - 都是空表。
        - 都是序对、向量、字符串并且表示同样的位置。
        - 都是过程，且他们的位置标记相同（localtion tags，即表示存储在同一个位置）。
    - `eqv?`返回`#f`当以下几种情况：
        - 类型不同。
        - 一个是`#t`，另一个是`#f`。
        - 都是符号，但转成字符串后不等。
        - 一个是精确的数，而另一个不是。
        - 都是数，但不等（`=`返回false）。
        - 都是字符但不等。
        - 一个是空表，另一个不是。
        - 都是序对、向量、字符串但位置不同。
        - 都是过程，但同样参数结果不同。
    - 下面的例子是上面的情况中未包含的：
    ```scheme
    (eqv? "" "")                     ; ===>  unspecified
    (eqv? '#() '#())                 ; ===>  unspecified
    (eqv? (lambda (x) x)
          (lambda (x) x))            ; ===>  unspecified
    (eqv? (lambda (x) x)
          (lambda (y) y))            ; ===>  unspecified
    ```
    - 因为常量不能修改，所以允许实现在合适的时候共享某些常量的结构，所以常量和常量（比如字符串）的比较结果通常是实现定义的。（如果共享了，那么就是`#t`，没有那么就是`#f`）。
    - 对于有内部状态的过程而言，如果状态会影响最终的结果，那么每次调用结果就是不同的：
    ```scheme
    (define (gen-counter)
        (let ((n 0))
            (lambda ()
                (set! n (+ n 1))
                n
            )
        )
    )
    (let ((g (gen-counter)))
        (eqv? g g)
    ) ; ==> #t
    (eqv? (gen-counter) (gen-counter)) ; ==> #f
    ```
    - 如果内部状态不会影响最终结果，那么结果就是实现定义的：
    ```scheme
    ; if local state does not affect the final result
    (define (gen-loser)
        (let ((n 0))
            (lambda ()
                (set! n (+ n 1))
                100
            )
        )
    )
    (let ((g (gen-loser))) (eqv? g g)) ; ==> #t
    (eqv? (gen-loser) (gen-loser)) ; ==> implemention-defined, in Racket it's #f
    ```
- `(eq? obj1 obj2)`
    - 和`eqv?`类似，不过可以检测一些更为细微的区别，也就是判等条件比`eqv?`更为苛刻。
    - `eq?`和`eqv?`保证在符号、布尔值、空表、序对、过程和非空字符串、向量上的完全相等的行为。但是`eq?`对数值和字符的判断行为是依赖于实现的，并且如果`eqv?`返回true，那么`eq?`一定也返回true。`eqv?`和`eq?`仅仅在空向量和空字符串上行为有点区别。
- `(equal? obj1 obj2)`
    - 递归地比较序对、向量、字符串的内容，在内部对字符、符号等数据使用`eqv?`进行比较。
    - 一个粗略地规则是，如果两个对象打印出来结果相同，那么`equal?`返回true。
    - 如果数据是循环的数据结构，那么`equal?`可能不会终止。

数值（Numbers）：
- Scheme的数值使用整数、有理数、实数、复数的方式对数值进行建模。
- 数值类型：
    - 数值被安排为一些子类型的层次，每一层都是上一层的子集。
    - 数值（number）
        - 复数（complex）
        - 实数（real）
        - 有理数（rational）
        - 整数（integer）
    - 对应的谓词是：`number? complex? real? rational? integer?`。
    - 比如3是整数，所以3也是有理数、实数和复数。
    - 一个数值（number）的类型和其在计算机内的表示没有简单的对应关系。尽管每个Scheme实现都会为整数3提供两种不同的表示，他们都表示同一个整数3。
    - Scheme的操作将数值视为抽象数据，尽可能和他们的表示相独立。而Scheme的实现可能会使用定点数、浮点数或者其他形式来表示一个数。这对于程序员来说是透明的，不需要去考虑。
    - 但是，有一点是有必要的，那就是区分一个数是精确表示的，还是非精确表示的。比如要精确表示一个无理数是不容易的，通常会使用一个有理数来近似，这是就是不精确的。
    - Scheme显式的区分一个数是精确的还是不精确的。这是与他们的类型正交的（也就是说每个类型的数都可能是精确或不精确的）。
- 精确性（exactness）：
    - Scheme数值可能是精确的（exact），也可能是不精确的（inexact）。
    - 一个数是精确的数：如果他是一个精确的常数，或者由精确地数仅经过精确的操作运算派生而来。
    - 一个数是非精确的数：它是非精确的常数，或者从非精确的数派生而来，或者经过非精确的操作运算而来。
    - 非精确性是一个有传染性的属性。
    - 两个使用精确数进行同样运算的不同实现，如果没有涉及到非精确的中间结果，那么他们的结果一定是相等的。但如果涉及到非精确计算或者非精确数，那么由于浮点数的近似等原因，结果就不一定相等了。
    - 像+这种有理运算，如果参数都是精确数，那么结果也一定是。如果这个运算无法产生精确结果，那么通常会报告违反了实现限制，或者将结果转换为非精确数。
    - 除了`inexact->exact`，其他函数如果使用了非精确参数，那么一定要返回非精确结果。
    - 当然如果一个方法可以证明他的非精确参数并不会对结果的精确性产生影响，那么也可以返回精确的结果，比如精确的0和非精确数相乘结果也一定是精确0。
- 实现限制：略。
- 数值字面值的语法：
    - 大小写在数值字面值中并不敏感。
    - 加上前缀之后一个数可以使用二进制、八进制、十进制、十六进制表示，`#b #o #d #x`。没有前缀默认视为十进制。
    - 可以用前缀显式指定为精确还是不精确的。`#e`表示精确，`#i`表示不精确。可以出现在进制前缀之前或者之后。如果没有精确性前缀，那么可以是精确也可以是不精确。如果包含十进制小数点，指数或者在数值的位置上有`#`那么就是非精确的，否则就是精确。
    - 可以使用后缀`s f d l`（short、float、double、long）显式指明精度。
    - 可以添加负号表负值。
- 数值操作：
    - 类型检验：`number? complex? real? rational? integer?`，可以被用在任何类型的对象上（包括非数值对象）。
    - 精确性检验：`exact? inexact?`，精确表示的数结果是true。
    - 比较操作：`= < > <= >=`，可以支持多个参数。需要具有传递性。当用于非精确数时，结果可能会因为一点精确性而不同，可能需要在程序中考虑精度问题。特别是`=`和`zero?`。
    - 正负形奇偶性：`zero? positive? negative? odd? even?`。
    - 最大最小值：`max min`支持多参数。
    - 和与积：`+ *`支持多参数。
    - 差与商：`- /`支持一个或多个参数。一个参数是`-`可以表示负号，即用0去减。`/`一个参数时用1去除。多个参数就是连续相减或相除，左结合。
    - 绝对值：`abs`，单参数。
    - 除法：`quotient remainder modulo`，2个参数，商、余数、模。数论中的整数计算，结果都是整数：
        - 商是结果向0取整。
        - 余数的符号和被除数（第一个参数）相同。
        - 模符号与除数（第二个参数）相同。
    - 最大公约数最小公倍数：`gcd lcm`支持多参数，结果总是非负。
    - 有理数分子与分母：`numerator denominator`，化到最简形式下的，分母永远为正。
    - 取整：`floor ceiling truncate round`，向上取整、向下取整、截断（向0取整）、舍入。
    - 有理化：`(rationalize x y)`，取大于x小于y的最简单的有理数。
    ```scheme
    (rationalize
      (inexact->exact .3) 1/10) ;          ===> 1/3    ; exact
    (rationalize .3 1/10)       ;          ===> #i1/3  ; inexact
    ```
    - 通用数学函数：`exp log sin cos tan asin acos atan atan`。`exp log`是自然指数和对数，atan有单参数和双参数版本，双参数的`(atan y x)`计算`(angle (make-rectangular x y))`。
    - 平方根：`sqrt`。结果可能会有正实数部分，或者实部为0虚部为正。
    - 指数：`(expt z1 z2)`，如果z1不为0，那么结果等于`(expt e (* z2 (log z1)))`，0的0次方为1，0的其他次方为1。
    - 通用复数操作：`make-rectangular make-polar real-part imag-part magnitude angle`。两种方式构造复数以及取实部虚部、模与辐角。
        - 复数两种表示：z = x1 + x2i = x3*e^(ix4)。那么`real-part imag-part magnitude angle`的结果分别是`x1 x2 |x3| x4`。
    - 精确与非精确数互相转换：`(exact->inexact z) (inexact->exact z)`。这应该是一一映射，也即是这两个函数是互逆的。
- 数值输入与输出；
    - 数值转字符串：`(number->string z)` `(number->string z radix)`。`radix`应该是精确的2、8、10、16，默认是十进制。结果中不会包含显式的进制前缀。
    - 字符串转整数：`(string->number string) (string->number string radix)`给定字符串的最大精度的数值表示。默认十进制，但是可以被字符串的显式前缀覆盖。无法字符串非法，那么返回`#f`。

其他非数值类型：
- 包括布尔、序对、列表、符号、字符串和向量。
- 布尔：
    - 真和假写作：`#t #f`。
    - 真正重要的是Scheme的条件表达式`if cond and or do`视`#f`为假，其他所有值（包括空表空字符串等）都为真。
    - 布尔字面值求值为他们自己，所以不需要被`quote`，如果非要`quote`，注意含义是一样的。
    - 取反：`(not obj)`，`#f`则返回`#t`，否则返回`#f`。
    - 判断是否是布尔值：`(boolean? obj)`，仅仅只有`#t #f`返回`#t`，否则返回`#f`。

- 序对和列表（pairs and lists）：
    - 一个序对（某些时候也成为点对）是一个Scheme中的一种数据结构，有两个域，前者用`car`取出，后者用`cdr`取出（用这两个过程是因为历史原因）。
    - 使用`(cons a b)`创建。可以使用`set-car! set-cdr!`对两个域赋值。
    - 序对主要用来表示列表（list）。列表被递归定义为其`cdr`是空表或者一个列表的数据结构。
    - 列表中连续的`car`域中的数据就是列表的元素。例如一个两个元素的列表表示为`(cons elem1 (cons elem2 nil)`。
    - 空表一般用字面值`'()`表示，很多实现中都给了`nil`这个别名。
    - 序对的外部表示是带点表示法（dotted notation）：`(c1 . c2)`，注意这是外部表示，是用在字面值中的（也就是在`quote`中使用），而非一个求值结果是序对的表达式。
    - 可以用更加精简的外部表示来表示列表：`(1 2 3)`和`(1 . (2 . (3 . ())))`是一个含义，前者是列表的精简表示，后者是序对（列表是一个特殊的嵌套的序对）的带点表示。
    - 不以空表结束的序对链成为不恰当列表（improper list，注意这并不是列表），比如`(a b c . d)`表示`(a . b . (c . d))`。
    - 如果更改了列表的某一个`cdr`域，那么可能上一刻一个数据是列表，下一刻就不是了。
    - 序对方法：
        - `(pair? obj)`
        - `(cons obj1 obj2)`
        - `(car pair)`
        - `(cdr pair)`
        - `(set-car! pair obj)`无返回值（return value is unspecified）
        - `(set-cdr! pair obj)`无返回值（return value is unspecified）
        - `caar cadr`等方法就是将`car cdr`依次组合，左边在外层，右边在里层，库函数最多可以有四层，例如`cadadr cdaaar`等。
    - 列表方法：
        - `(list? obj)`
        - `(list obj ...)`
        - `(length list)`列表长度。
        - `(append list ...)`返回将后续所有列表依次附加到第一个列表上的结果，最后一个结果不一定需要是列表，此时结果就是一个improper list。
        - `(reverse list)`反转列表。
        - `(list-tail list k)`得到忽略前k个元素后的列表，不够k个则报错。
        - `(list-ref list k)`得到列表的第k个元素，不够报错。
        - `(memq/memv/mmeber obj list)`得到`car`是给定元素的子列表，分别使用`eq? eqv? equal?`比较，如果未出现在列表中，则返回`#f`。
        - `(assq/assv/assoc obj alist)`，其中`alist`必须是序对的列表（association list），查找列表中第一个`car`等于`obj`的序对，并返回这个序对。`assq/assv/assoc`分别使用`eq? eqv? equal?`比较。未找到返回`#f`。
        - 上面几个方法都不是单纯的谓词，可能返回有用的值，所以并没有在末尾加`?`。
- 符号（symbols）：
    - 符号是非常有用的，因为如果他们拼写相同那么他们就是完全相同的（在`eqv?`的层面上）。
    - 因为对于标识符来说正需要这样做，所以很多实现在内部使用符号来表示标识符。
    - 符号的很多应用中都非常有用，例如用来表示枚举值。
    - 符号的命名规则与标识符完全相同。
    - 保证字面量表达式或者`read`返回的符号经过`write`之后，再`read`回来一定和原来的符号是相同的。也就是`read/write`不变性。
    - 但`string->double`过程则不能保证不变性，因为字符串中可能存在非标准的字符。
    - 过程：
        - `symbol?`
        - `(symbol->string symbol)`符号转字符串。
        - `(string->symbol string)`字符串转符号。
- 字符：
    - 表示可打印字符如字母数字等，使用`#\<character>`或者`#\<character name>`来表示。
    ```scheme
    #\a ; lower case letter
    #\A ; upper case letter
    #\( ; left parenthesis
    #\ ; the space character
    #\space	; the preferred way to write a space
    #\newline ; the newline character
    ```
    - 如果`#\`后面直接跟一个字母的情况，那么后面必须再有一个分隔符，比如空格或括号。以同不是字母的情况区分开来。
    - 字符是自己求值的，不需要`quote`。
    - 字符相关过程，如果忽略大小写得话，会在名称中嵌入`-ci`（去掉case sensitive的意思？）。
    - 方法：
        - `char?`
        - 字符比较：`char=? char<? char>? char<=? char>=?`，比较的是在字符集中的顺序。保证：数字<大写字母<小写字母。
        ```scheme
        (char<? #\1 #\A) ; #t
        (char<? #\1 #\a) ; #t
        (char<? #\A #\a) ; #t
        ```
        - 忽略大小写的版本就是在`?`前加`-ci`：`char=-ci? char<-ci? char>-ci? char<=-ci? char>=-ci?`。
        - 字符类别：`char-alphabetic? char-numeric? char-whitespace? char-upper-case? char-lower-case?`。空白符包括空格、制表符、换行、换页、回车。
        - 字符与整数互相转换：`(char->integer char) (integer->char n)`。
        - 大小写互相转换：`char-upcase char-downcase`。
- 字符串：
    - 字符串是字符的序列，字符串是使用双引号括起来的序列。在字符串内部使用双引号需要使用`\`转义，反斜杠本身则使用`\\`转义。
    - 字符串长度是一个非负整数，字符串创建时被固定。有效索引为0到长度-1。
    - 一般说下标从a开始到b，都是指包含a但不包含b。
    - 忽略大小写的过程同样有`-ci`。
    - 过程：
        - `string?`
        - `(make-string k) (make-string k char)`返回新分配的长度k的字符串，所有元素初始化为`char`，未指定则不确定。
        - `(string char ...)`得到由参数构成的字符串。
        - `(string-length string)`字符串长度。
        - `(string-ref string k)`得到第k个字符。
        - `(string-set! string k char)`设置第k个字符。
        - `(string=? string1 string2) (string-ci=? string1 string2)`字符串判等。
        - 字符串比较：`string<? string>? string>=? string<=?`以及`string-ci<? string-ci>? string-ci>=? string-ci<=?`，接受两个参数，字典序比较。
        - `(substring string start end)`子串，含`start`不含`end`。
        - `(string-append string ...)`得到所有字符串的拼接。
        - 字符串和列表转换：`(string->list string) (list->string list)`。
        - `(string-copy string)`复制字符串。
        - `(string-fill! string char)`填充字符串的每个元素为给定字符。
- 向量：
    - 向量通常拥有比列表更小的存储空间以及更快的随机索引访问时间。
    - 同样通过下标访问，下标从0开始到长度-1。
    - 外部表示使用`#(obj ...)`这种形式。
    - 过程：
        - `vector?`
        - `(make-vector k) (make-vector k fill)`创建长度k的向量，如果给了元素那么填充为`fill`，否则未指定。
        - `(vector obj ...)`得到所有参数作为元素的向量。
        - `(vector-length vector)`长度。
        - `(vector-ref vector k)`随机下标访问。
        - `(vector-set! vector k obj)`按下标设置某一个元素。
        - 与列表互相转换：`(vector->list vector) (list->vector list)`。
        - `(vector-fill! vector fill)`填充所有元素。

控制特性：
- 这里介绍通过特殊方式控制程序执行的控制流的原始函数。
- 谓词`(procedure? obj)`判断一个对象是否是过程。
- `(apply proc arg1 ... args)`
    - 使用`(append (list arg1 ...) args)`作为参数调用函数`proc`。
- `(map proc list1 list2 ...)`
    - 对列表元素做映射，`proc`支持多参数，列表数量需要与参数数量一致，并且多个列表元素个数要一致。
    - 返回结果的列表。
- `(for-each proc list1 list2 ...)`
    - 和`map`完全类似，不是需要的是调用的副作用。
    - 无返回值/未指定返回值。
- `(force promise)`
    - 得到这个`promise`的值，如果这个`promise`还没有被计算，那么就计算并返回。
    - 如果已经计算，那么返回先前的结果。
    - `force delay`旨在让程序以函数式编程的风格来书写，在程序需要值的时候才去计算，也就是实现懒惰求值。
    - 无论`force`多少次，都只会在第一次的时候计算一次。
- `(call-with-current-continuation proc)`：
    - `proc`必须是接受一个参数的过程，
    - todo（暂时没太看懂）。
- `(values obj ...)`，todo。
- `(call-with-values producer consumer)`，todo。

Eval：
- `(eval expression environment-specifier)`
    - 在特定的环境中对表达式进行求值，并返回其值。
    - `expression`需要是一个表示为数据的Scheme表达式。
    - `environment-specifier`必须是以下三个程序之一的返回值。
- `(scheme-report-environment version)`
- `(null-environment version)`
    - `version`必须是精确整数5，对应于当前的Scheme版本（the Revised5 Report on Scheme）。
    - `scheme-report-environment`返回一个包含本报告中的所有绑定的环境说明符。
    - `null-environment`返回一个包含所有词法关键字绑定的环境说明符。
- 可选过程：`(interaction-environment)`
    - 包含环境定义的绑定的环境描述符。通常是上面的环境的超集。
    - 这个过程的意图是给用户一个可以动态求值表示的环境。

输入输出：
- 端口：
    - 端口代表输入输出设备。
    - 在Scheme中，一个输入端口是可以通过命令发送字符的Scheme对象，一个输出端口是可以接受字符的Scheme对象。
    - 打开文件输入或者输出：
        - `(call-with-input-file string proc)`
        - `(call-with-output-file string proc)`
        - `string`应该表示一个文件，`proc`是接受一个参数的过程。
        - 对于`call-with-input-file`来说，这个文件应该已经存在。
        - 对于`call-with-output-file`来说，如果文件已经存在则结果不确定（即是应该表示一个新文件）。
        - 通过打开文件读或者写获取输出或者输入端口。如果文件无法打开，那么会抛出错误。
        - 如果`proc`返回，那么端口自动关闭，并作为整个函数的返回值，如果不返回，那么端口不会被自动关闭。
    - 判断：
        - `(input-port? obj)` `(output-port? obj)`
    - 得到当前的默认输入和输出端口：
        - `(current-input-port)` `(current-output-port)`
        - `read write`就是在默认端口上。
    - 打开文件读写并将其绑定到默认端口上：
        - `(with-input-from-file string thunk)`
        - `(with-output-to-file string thunk)`
    - 打开文件读写并返回端口：
        - `(open-input-file filename)`
        - `(open-output-file filename)`
    - 关闭端口：
        - `(close-input-port port)`
        - `(close-output-port port)`
        - 对已关闭文件无影响。

- 输入：
    - `(read) (read port)`
        - 将Scheme对象的外部表示读取为Scheme对象本身。
        - 本质是一个parser，从给定端口（或默认端口`current-input-port`中）返回下一个可以解析的对象，并更新端口的第一个字符的指向。
        - 遇到EOF的话，那么会返回文件结束对象（end of file object）。
    - `(read-char) (read-char port)`
        - 从端口中读取下一个字符，并更新端口状态。
        - 到文件尾则返回EOF。
    - `(peek-char) (peek-char port)`
        - 从端口取出下一个字符，不更新端口状态。
    - `(eof-object? obj)`
        - 判断一个对象是否是EOF对象。
    - `(char-ready?) (char-ready? port)`
        - 判断端口是否已经准备好字符。
        - 可以用于交互环境中，判断是否已经有了用户输入。
- 输出：
    - `(write obj)`
    - `(write obj port)`
        - 将对象的写形式（written representation）写到输出端口，字符串的写形式是带双引号的（在其中双引号和反斜杠会被转义）。
        - 字符使用`#\`形式。
    - `(display obj)`
    - `(display obj port)`
         - 将对象写到输出端口，字符串不带双引号，其中没有字符会被转义。
         - 字符是以`write-char`同样的形式输出而非同`write`。
    - 说明：`write`的意图是输出机器能够读取的形式，而`display`的意图是输出人能够读取的形式。
    - `(newline) (newline port)`
        - 写一个换行到输出端口（end of line），不同操作系统上实现可能不同（比如windows的`\n\r`，Unix的`\n`）。
    - `(write-char char) (write-char char port)`
        - 写一个字符到输出端口，是这个字符的含义，而非`#\`表示。
- 系统接口：
    - 系统接口通常都不在此报告的描述范围之内，但一些重要的还是有必要的。
    - `(load filename)`
        - 加载一个Scheme源文件，读取其中的所有表达式和定义，然后对他们顺序求值。
        - `load`并不影响`current-input-port current-output-port`的值。
        - 为了可移植性，`load`必须操作源文件。
    - `(transcript-on filename) (transcript-off)`
        - `filename`是将要常见的文件的字符串名称。
        - `transcript-on`会创建并打开这个文件去写，写的内容是接下来的用户和Scheme系统的交互。
        - `transcript-off`调用后转写结束。
        - 同一时刻只能有一个转写过程。


### 7. 形式化的语法和语义

略，使用EBNF描述，需要实现Scheme的话则必须参考这里。这里的形式化描述对应的非形式化的描述已经在上面了。

包括内容：
- 形式化语法：
    - 词法结构
    - 外部表示
    - 表达式
    - quasiquotation
    - Transformers
    - 程序和定义
- 形式化语义
    - 抽象语法
    - Domain equations
    - 语义函数
    - 辅助函数
- 派生的表达式类型实现

详见：[Revised5 Report on the Algorithmic Language Scheme - Chapter7 - Formal syntax and semantics](https://schemers.org/Documents/Standards/R5RS/HTML/r5rs-Z-H-10.html)