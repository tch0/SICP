## 书中比较复杂的代码汇总

- [第四章第一节的元循环求值器](../4MetalinguisticAbstraction/P252.MetacircularEvaluator.rkt)：一个较为完整的包含了大部分Scheme语法的元循环求值器，最终实现为了一个Scheme的REPL交互环境，实现了环境、框架、`quote set! if define lambda begin cond let/let*/named let/letrec`、函数调用等。在环境中安装一些基本过程后即可开始使用，数据类型与parser是直接使用Scheme内置过程提供的支持。简陋但五脏俱全。[语法分析与求值分离的版本](../4MetalinguisticAbstraction/P273.MetacircularEvaluator2.rkt)。

## 比较复杂的习题汇总

暂无。