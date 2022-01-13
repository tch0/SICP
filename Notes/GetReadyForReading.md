## SICP

《计算机程序的构造和解释》
- 讲述计算机程序的道与术，授人以渔的方法论，而非某确切技术的细枝末节。
- MIT有使用本书的课程：6.001: Structure and Interpretation of Computer Programs。
- 使用Lisp的方言Scheme作用开发语言。不需要先系统学习Scheme，在看书过程中学习使用就行。
- Scheme是一门动态的、函数式的编程语言。

## 书籍阅读

- SICP中文第二版，机械工业出版社，最好有纸质版，电子版也行。
- [英文原版在线阅读](https://mitpress.mit.edu/sites/default/files/sicp/full-text/book/book.html)
- [LaTex版本的英文书籍](https://github.com/sarabander/sicp-pdf)
- [书籍官网相关资源：代码项目等](https://www.mitpress.mit.edu/sites/default/files/sicp/index.html)，这里可以找到所有相关资料。

## 开发环境配置

SICP使用Scheme语言（Lisp的方言）来练习和实践，需要配置开发环境。MIT使用[MIT Scheme](https://www.mitpress.mit.edu/sites/default/files/sicp/scheme/index.html)作用开发环境。就现在来说，有点老了，更好的是使用[DrRacket](https://racket-lang.org/)。

相关阅读：
- [学习SICP（《计算机程序的构造和解释》）的一些准备工作](https://zhuanlan.zhihu.com/p/34313034)
- [DrRacket 的安装与 SICP 的配置](https://zhuanlan.zhihu.com/p/37056659)

Windows环境配置：
- 搜索DrRacket，下载最新版（当前时刻v8.3），管理员权限安装。
- 配置DrRacket：Help，使用简体中文作为界面语言。熟悉使用后推荐使用英文。
- 安装SICP Package，[教程](https://docs.racket-lang.org/sicp-manual/)。
    - File,Package Manager,Do What I Mean。
    - 输入sicp，install。安装源地址：https://github.com/sicp-lang/sicp。
- 测试，Run，得到预期结果则配置成功。
```scheme
#lang sicp
(inc 42)
```

关于[Racket](https://zh.wikipedia.org/zh-cn/Racket)：
> Racket（原名 PLT Scheme）是个通用、多范型，属于Lisp家族的函数式程序设计语言，它的设计目之一是为了提供一种用于创造设计与实现其它编程语言的平台，Racket被用于脚本程序设计、通用程序设计、计算机科学教育和学术研究等不同领域。

> Racket有一个实现平台，包含了执行环境、函数库、即时编译器（JIT compiler）等等，还有提供一个以Racket本身写成的开发环境 DrRacket (原名 DrScheme)。

- SICP就是其中一个包。
- DrRacket安装之后同样有一系列工具，添加环境变量之后即可使用。
- raco是Racket的包管理器。

关于SICP语言：
- Scheme经过许多年之后已经发展了很多，SICP仅使用其中一个子集。
- `#lang sicp`提供了一个早期版本的Scheme。
- 程序的第一行使用`#lang sicp`就可以使用。
- 更多语法细节参考[这里](https://docs.racket-lang.org/sicp-manual/index.html)。

SICP Language的一些语法细节：
- `nil : null?`,`'()`的别名，空值？
- `inc x`自增，等价于`(+ x 1)`。
- `dec x`自减，等价于`(- x 1)`。
- `the-empty-stream : stream?`，空的流。
- `(cons-stream first-expr rest-expr)`产生一个`stream`。
- `(stream-null? s) → boolean?`流是否为空，返回`#t #f`。
- `(runtime) → natural-number/c`微秒为单位的当前时间测量，有一个固定的开始。
- `(random n) → real?`生成0到n-1的随机整数，如果n是整数，如果不是，则生成0到n（不包含）的随机（浮点）数。
- `(amb expr ...)`amb运算符。这是什么东西？
- 同时Racket支持`true false identity error`。

`#lang sicp`还提供了SICP Picture Language，提供了很强的图片操作能力。

看起来这样就已经可以编译运行了。看起来DrRacket好像缺少项目管理方案，可以使用一个包[MatrixForChange/files-viewer](https://github.com/MatrixForChange/files-viewer)来管理文件夹。

代码跳转和定义：Ctrl+F直接搜索。

项目和文件管理：TODO。

调试：VsCode不支持调试，使用DrRacket，Debug，图形化断点调试，和其他语言差别不大，不过是以每个S表达式为步骤执行的。

## 使用VsCode

使用Magic Racket插件：
- 首先需要raco在环境变量中。
- 安装`racket-langserver`（语言服务器）：
```shell
raco pkg install racket-langserver
```
- 更新：
```shell
raco pkg update racket-langserver
```
- 如果不需要语言服务器，也可以配置中设置`magic-racket.lsp.enabled": false`。
- 从github下载，梯子需要启用全局模式。

语言服务器提供：
- 符号定义跳转，悬停信息。
- 语法高亮支持。
- 支持`#lang racket`的所有标准函数。
- 很多按钮功能支持。

REPL环境：
- 可以通过右上角的按钮加载和执行文件。也可以通过终端。
- 命令：`Ctrl+Shift+P, Racket:...`。

其他插件：
- 彩虹括号2，提供自定义的括号高亮。
- AyaSEditor插件提供括号缩进支持，也可以不用。

## 更多资料

Scheme语言：
- Yet Another Scheme Tutorial是一本Scheme入门教程，[中文版翻译](http://deathking.github.io/yast-cn/)。

MIT课程资料：
- MIT视频公开课《计算机程序的构造和解释》中文化项目及课程学习资料搜集：[DeathKing/Learning-SICP](https://github.com/DeathKing/Learning-SICP/)。

SICP题解：
- [SICP中文解题集](https://sicp.readthedocs.io/en/latest/)
- [Scheme Wiki中的英文题解](http://community.schemewiki.org/?SICP-Solutions)

在线练习：
- [SICP（计算机程序的构造和解释）的在线练习场](https://zhuanlan.zhihu.com/p/341576984)

关于Lisp：
- [为什么Lisp语言如此先进？（译文）-阮一峰](http://www.ruanyifeng.com/blog/2010/10/why_lisp_is_superior.html)
- [The Nature of Lisp](https://www.defmacro.org/ramblings/lisp.html)，[中译版](https://zhuanlan.zhihu.com/p/26876852)
