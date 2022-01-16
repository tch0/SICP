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