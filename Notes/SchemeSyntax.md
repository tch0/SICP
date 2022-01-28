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