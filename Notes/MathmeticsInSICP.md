## SICP中涉及到的数学

公式以及定理之类的。

### 第一章 构造过程抽象

整数素性检验相关定理：
- [费马小定理](https://zh.wikipedia.org/wiki/%E8%B4%B9%E9%A9%AC%E5%B0%8F%E5%AE%9A%E7%90%86)
- [Miller-Robin检验](https://zh.wikipedia.org/wiki/%E7%B1%B3%E5%8B%92-%E6%8B%89%E5%AE%BE%E6%A3%80%E9%AA%8C)

数值积分：
- [数值积分的辛普森规则](https://en.wikipedia.org/wiki/Simpson%27s_rule)

定积分的近似数值计算：
$$\int_{a}^{b} f = [f(a+\frac{dx}{2}) + f(a+dx+\frac{dx}{2}) + f(a+2dx+\frac{dx}{2}) + ...] dx$$

数值积分的辛普森规则：
$$\int_a^b f = \frac{h}{3}[y_0 + 4y_1 + 2y_2 + 4y_3 + 2y_4 + ... + 2y_{n-2} + 4y_{n-1} + y_n]$$
其中$h = (b-a) / n$, n是一个偶数，越大精度越高, $y_k = f(a + kh)$。

计算派的近似值（无穷级数）：
$$\frac{\pi}{8} = \frac{1}{(1\cdot 3)} + \frac{1}{(5\cdot 7)} + \frac{1}{(9\cdot 11)} + ...$$

派的乘法近似公式：
$$\frac{\pi}{4} = \frac{2\cdot 4\cdot 4\cdot 6\cdot 6\cdot 8\cdots}{3\cdot 3\cdot 5\cdot 5\cdot 7\cdot 7\cdots}$$

无穷连分数公式：
$$
f = \dfrac{N_1}{D_1 + \dfrac{N_2}{D_2 + \dfrac{N_3}{D_3 + ...}}}
$$

计算时可以用只算到第k项来近似：
$$f_k = \dfrac{N_1}{D_1 + \dfrac{N_2}{\ddots+\dfrac{N_k}{D_k}}}$$

相关阅读：
- [Euler连分数公式与广义连分数 - 知乎 - 茶凉凉凉凉](https://zhuanlan.zhihu.com/p/110671418)
- [Euler's continued fraction formula - Wikipedia](https://en.wikipedia.org/wiki/Euler%27s_continued_fraction_formula)

自然对数的底数e的无穷连分式近似：

$$
e = 2+\dfrac{1}{1 + \dfrac{1}{2 + \dfrac{1}{1+ \cdots}}}
$$

其中$N_i$全是1，$D_i$分别为$1,2,1,1,4,1,1,6,1,1,8,...$。

正切函数的无穷连分式表示：
$$
\tan x = \dfrac{x}{1-\dfrac{x^2}{3-\dfrac{x^2}{5-\ddots}}}
$$

### 第二章 构造数据抽象

lambda演算相关概念：
- [Lambda calculus](https://en.wikipedia.org/wiki/Lambda_calculus)
- [Church encoding](https://en.wikipedia.org/wiki/Church_encoding)
- [认知科学家写给小白的Lambda演算](https://zhuanlan.zhihu.com/p/30510749)

光速入门λ演算：
- 在λ演算中，一行符号被叫做表达式。长得像这个样子：`(λx.xy)(ab)`。
- 表达式包含的基本要素：
    - 单个字母（`abcd...`）称作变量。
    - 括号`()`，被括起来的部分是一个整体。
    - 希腊字母`λ`和点号`.`，用来描述函数。比如`λx.x`，`λ`后`.`前的字母称为变量，点之前成为头部（head），点之后称为体部（body）。
- 一些规则：
    - 变量的名称无具体含义，只是一个名字，可以任意命名。两个变量如果是一个名字，那么他们就是同一个变量。
    - 函数什么也不计算，它只是一个表达式，有头和体，唯一能做的事情就是解析（resolving）它。
    - `λ`这个符号并无特殊含义，只是用来表示函数。
    - 在`λ`表达式后添加表达式，表示用这个表达式应用在`λ`上，也就是替换其中的变量。比如`(λx.xy)(ab)`就解析为`aby`。
    - `λ`是默认柯里化的，也就是`λx.λy.xyz`等价于`λxy.xyz`。应用时从前往后依次应用于对应变量。
    - 括号中的表达式最先被计算。
    - 看起来`.`是右结合的。

用λ演算定义整字，也就是练习2.6所述的问题了，即邱奇编码：
- `0 = λsz.z`。
- 类似地，`1 = λsz.s(z)`，`2 = λsz.s(s(z))`, `3 = λsz.s(s(s(z)))`...
- 换言之，这里的计数法就是在`z`上嵌套表达式`s()`多少次。
- 后继函数（也就是对当前整字加1）：`S = λabc.b(abc)`。
- 后继函数对0演算：
```
S0  = (λabc.b(abc))(λsz.z)
    = λbc.b((λsz.z)bc)
    = λbc.b((λz.z)c)
    = λbc.b(c)
    = 1
```
- 加法：也就是自动化后继函数，比如3+2可以表示为，在3上调用2次后继函数。加法和后继是统一的。
```
3+2 = 3S2 = (λsz.s(s(s(z)))) (λabc.b(abc)) (λxy.x(x(y)))
          = ...
          = λ xy.x(x(x(x(x(x(x(x(y))))))))
          = 8
```
- 乘法：`MULITIPLY = λ abc.a(bc)`
```
2x3 = MULITIPLY 2 3 = (λ abc.a(bc)) (λ sz.s(s(z))) (λ xy.x(x(x(y))))
    = λ c.(λ sz.s(s(z)))((λ xy.x(x(x(y))))c)
    = λ cz.((λ xy.x(x(x(y))))c)(((λ xy.x(x(x(y))))c)(z))
    = λ cz.(λ y.c(c(c(y))))(c(c(c(z))))
    = λ cz.(c(c(c(c(c(c(z)))))))
    = 6
```
- 其他就算了，三句两句完全说不清楚。需要系统学习。