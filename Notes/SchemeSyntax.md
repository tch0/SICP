## Scheme语法汇总

SICP中用的[R5RS版本的Scheme文档](https://docs.racket-lang.org/r5rs/r5rs-std/r5rs.html)。

定义函数：
```scheme
(define (func args)
    (define (inner-func args) ret-value)
    return-value
)
```

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
- `(even? n)` 判断是否为偶数，`odd?`偶数。
- `(gcd a b)` 最大公约数。

序对操作：
- `(cons a b)`得到序对`(a . b)`
- `(car x)`，取序对第一个元素。
- `(cdr x)`，取序对第二个元素。