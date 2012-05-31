
## 概览  

打算写的是一个图形的代码操作界面, 再想完成一个在线执行的功能.  
界面部分基本用 CSS 排好了, 但交互和执行方面有我目前解决不了的 bug.  
我加上了不少关于编辑的快捷操作, 但没进行详细介绍.  
顺带有个能管理编辑代码不同分支的工具, 只是证明了可行.  
我的目标是尝试新的风格的代码编写体验, 编辑图形的代码.  
Demo 在这里: http://jiyinyiyong.github.com/code_blocks/html.html  

#### 失败  

界面上我大概做到我盼望实现的了, 但细节可以说很失败.  
已知一个明显的漏洞是 `ctrl-z` 返回历史在存储中有逆向, 一个错误.  
另一个是递归函数不能正常运行, 而且我当前做的也只是基本的几个.  
现在匆匆忙忙想完成一个介绍, 而且我只希望做提供想法的一个.  

## 目标  

原先出发点只是解析 Lisp 不允许空格有种不和谐, 我用图形来弥补.  
但看了几篇文章之后, 我觉得该想想更多曾经困扰我的问题了, 比如:  
[Limitations of the Unix Philosophy and the Ultimate Solution to Parsing](http://yinwang0.wordpress.com/2011/04/14/unix/)  
看到 [@yinwang0](http://weibo.com/yinwang0) 的说法, 之前我厌恶语法的原因也就明了了.  
目前只是不会写编译器的新手的尝试, 下面是我对未来的想法:  

#### 界面  

缩进和代码块是算法管理的, 因而准确清晰, 目前不清楚可读性.  
有些小型区块被折叠到一行当中, 以保留适当的可读性.  
书写的过程设计到区块的出入, 不如纯文本快捷, 但有改进的余地.  
文本用下划线, 不限制标识符内容, 允许有空格, 检测头部进行运算.  
我想是叫上一些对鼠标的动态效果, 总体上做出一些未来感的界面.  

![code style](http://img.hb.aicdn.com/63325b89dd6d8df3c7a5690993b4085accfeb22680b2-B9wwy2)  

#### 历史分支  

"撤销" "重做" 功能的升级就是控制版本形成版本树一类的工具,  
目标是你可以边尝试性写测试, 一边在另一条分支开始新的代码结构.  
但由于代码通常是多个文件构成, 这未必有用, 即便有时真的可行.  
我猜测这和 Git 一类工具之前还能有更好的方案的余地, 等待.  

![versions](http://img.hb.aicdn.com/db9654e0c3d269c96b5c4917cde20b9fe4c21f503242-sVuPC8)  

#### 候选输入  

操作系统只能输入英文字符, 然后输入法字词框终于让支持多语言了.  
有了选字框, 输入字符串以外数据类型也成为了可能, 比如 JSON.  
其界面为了全局的一致, 我认为代码提示界面相对更可行, 像 Sublime 的.  
我的想法是操作体统全局用带提示的光标, 注意是"全局的提示".  
就像算法推荐所有可用图形表示的可输入内容... 目前比较含糊.  

![hint in sublime](http://www.windows7hacker.com/wp-content/uploads/2012/02/auto_complete.png)  

#### 编程语言  

写一门语言大概很多人的愿望, 我现在止于想, 主要是语法这种表象.  
既然想过了界面, 表层形式我大概有数. 当然重点是怎样用在处理问题.  
一个麻烦是我没学会就反感了各种语言, CoffeeScript, Clojure 还好,  
现在我只知道 FP 是个方向, 具体怎样要花好多工夫.  