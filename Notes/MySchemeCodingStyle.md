## 我的Scheme编码风格

首先，编码风格这种事情是因人而异的。重点是风格统一与可读性，而非机械地严格死守某种规则。

缩进：
- 使用4个空格作为缩进，不使用Tab。
- 对于普通S-表达式，一般来说风格是操作符/函数与第一个参数位于第一行，后续参数对齐第一个参数。
```scheme
(* (test-func a b c)
   (test-func a b c))
```
- 对于特殊形式，主要指的是`define lamdba let`这三个。函数体或者let赋值列表后的表达式一般来说是直接相较`define let lambda`缩进一个层次也就是4个空格。当然如果表达式体特别简单也可以放在一行。
```scheme
(define (what-func a b c)
    (let ((var1 (som-func xxx xxx))
          (var 190)
          (hello (something)))
        (lambda (x y z)
            (+ x y z)
        )
    )
)
```
- 当然对于嵌套很深的S-表达式，看起来每次都第二个参数换行缩进对齐也会造成一些困扰。此时可以在合理时将比较简单清晰的整个S-表达式（典型如简单的算术运算）放在一行。只在某些表达式上缩进。如果要缩进，那么一定要将第二个参数对齐第一个，并且后续每个参数都缩进对齐。
```scheme
(square (* (+ x y) (- x y)))
```
- 某些表达式也是特殊形式，比如`if and or`这种，和普通S-表达式同等处理。`if`的话个人习惯是无论多简单都换行。
- `let`表达式的赋值列表，每一个赋值项对齐。变量和表达式一般写在一行。
```scheme
(let ((var1 (som-func xxx xxx))
      (var 190)
      (hello (something)))
    (if (> x y)
        yes-expression
        no-expression
    )
)
```
- `cond`中一般来说每个判断后直接同一行跟对应结果，比较复杂也可以换行，对齐条件。
```scheme
(cond ((op1 a b)
       (result1))
      ((op2 x y)
       (test-func hello world))
)
```
- 缩进的处理SICP中的我是很认同的，都大差不差。

括号：
- 个人更喜欢将某些情况下的后括号另起一行。而SICP中无论任何情况都是放在嵌套的表达式的最末尾，观感不是很清晰，层次一多很容易陷入数括号的地狱（虽然编辑器有不同颜色高亮）。
- 括号另起一行的情况包括：`define lamdba let cond`、比较复杂的函数调用，而`if`的话一般还是放末尾。在表达式很长的情况下，后括号另起一行看起来会更清晰。而简单的函数调用、简单的写在一行的`define lambda`则不需要。
```scheme
(lambda (x) (* x x))
(define (mul x y x)
    (* x y z)
)
```
- 总体来说就是多行的`define lambda let cond`一定另起一行，其他则看情况，复杂则换，简单则不换，括号层次实在太多了也可以换一换。
- `let`表达式中赋值部分，第一行左边添加左括号，最后一行右边添加右括号，每一个赋值的括号对齐。