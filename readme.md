
大概就这样的吧.. 还是庆幸写出来, 作为菜鸟升级的练习.  
下面说到的语法问题的确是困扰我很严重的, 当然中文我至少能说清楚点.  
单纯的文本的源代码, 即便设计了诸多语法, 可能也就 Ruby 那样糊里花哨  
像 Lisp 那么括号, 层级多了也讨不到好. Python 简洁是简洁了, 算我钦佩了吧.  
不管怎样, 图形是一个选项, 我们去尝试了多少比没有尝试要好..  
这里主要是代码块和空格作为变量标识符的可能性.. 算了, 扯不下去  

我现在实现的部分大概是能在网页上进行操作, 程序里面就全局以列表存着代码  
就是说可以随时把代码以列表形式提出, 作为其它的用途而不用再解一边  
我写的代码挺浪费资源的... 主要是想看看那个图形界面, 然后心痒了  
就当体验下网页操作列表状代码的感觉吧, 下面是英文不顺只好乱扯:P  

What I was thinking about:  
==  

Lisp is said to handle AST without syntax sugar(or sth liks that),  
So far, I'm not learning theories about compiling, quite fuzzy about it.  

But what I learnt is that source file are just data to give to computes,  
it would be parsed to lists, for example, then a interpreter tries to run it.  
That what I got from the great tutorial <http://norvig.com/lispy.html>.  

There are two things about syntax bothered me for a while.  

While parsing Lisp(.. I'm a beginner to say that..), blanks are different:  
`(vector 1 2 3)` can be parses to `[1 2 3]`, but `(string hello world)` cannot.  
Because `' '` was used to seperate symbols as a syntax sugar.  
Yeah, spaces looks great clear in the source, it's used most frequently.  
But what if we write code in a graphic editor? It should be defferent.  

(Besides, Linux, being written in English, supports Chinese input quite bad.  
The Chinese candidates are much like the the pop menu in Sublime Text.  
If Chinese ime was nested in Linux that firmly, it should have be wonderfull.)  

And the methods used to close a code block are always ugly(personally).  
Does `end` and `function(){}` always helps in making is readable?  
I'm just thinking that, if we choose a proper design in a graphic way,  
there should be a better options for us to try. That's my opinon.  

I'm still trying. As a bad student and unskillful nerd(?), that's my only attemp.  
Just some demostrations here. I'm not able to make it so far. Check it.  

Demo  
==  

Try to type in words or `enter` `cancel` `esc` `home` `end` `arror`...  
<http://docview.cnodejs.net/test_ideas/code_blocks/html.html?html>  
Debugged on Ubuntu __Chrome__, not confident enough to care that.  

Plan  
==  

If this could became a real script language...  

* Running in browser  
* Fetch libs from web while running  
* save versions into a tree  

More  
==  

Day dreaming.  
