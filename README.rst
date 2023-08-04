:Title: ReST to article report beamer
:subtitle: rst2arb
:Author: shmilee; Shmilee
:Date: \today

.. role:: latex(raw)
   :format: latex

.. raw:: latex

    \newpage

简介
====

pandoc 配合 xelatex ,将含 cjk 文字的 rst 文档 转为 article report 或 beamer。  

准备
====

* 安装 `texlive <http://www.latex-project.org/>`_ , `pandoc <http://johnmacfarlane.net/pandoc/>`_ , python3 。

* 文本编辑器: `vim <http://www.vim.org>`_ 不错。  

* 熟悉 `rst <http://docutils.sourceforge.net/docs/user/rst/quickstart.html>`_

使用
========

* test测试

  .. code:: bash

    make test

* 安装到系统

  .. code:: bash

    make BIN_DIR=/usr/local/bin \
    ETC_DIR=/usr/local/etc \
    template_PATH=/usr/local/share/pandoc/user-templates install

* 查看已有 Style

  .. code:: bash

    rst2arb --list
    rst2arb -i article report beamer

* 修改 `～/.rst2arb.conf`, 添加 Style

  .. code::

    [beamer_solarized]
    alias_name    = bsolar
    doc_class     = beamer
    template      = /usr/local/share/pandoc/user-templates/latex-cjk.tex
    latex_engine  = xelatex
    other_options = ["-V colortheme:solarized",
                 "-V theme:default",
                 ..........]

* 生成 article, report, beamer

  .. code:: bash

    rst2arb -s article README.rst -o cache/article.pdf
    rst2arb -s report README.rst -o cache/report.pdf
    rst2arb -s beamer README.rst -o cache/beamer-default.pdf
    rst2arb -s bsolar README.rst -o cache/beamer-solarized.pdf

FAQ
====

模板如何制作？
--------------

1. 输出默认模板 :code:`pandoc -D latex >latex-cjk.tex`.

2. 根据 `xeCJK 文档 <http://mirrors.ctan.org/macros/xetex/latex/xecjk/xeCJK.pdf>`_, 编辑 \*-cjk.tex.

   将

   .. code:: latex

    $if(CJKmainfont)$
      \ifXeTeX
        \usepackage{xeCJK}
        \setCJKmainfont[$for(CJKoptions)$$CJKoptions$$sep$,$endfor$]{$CJKmainfont$}
      \fi
    $endif$

   替换为

   .. code:: latex

    $if(xeCJK)$
      \ifXeTeX
        \usepackage[$for(xeCJK)$$xeCJK$$sep$,$endfor$]{xeCJK}
      \fi
    $endif$
    $if(ctex)$
        \usepackage[$for(ctex)$$ctex$$sep$,$endfor$]{ctex}
    $endif$
    $if(CJKmainfont)$
        \setCJKmainfont[$for(CJKmainfontoptions)$$CJKmainfontoptions$$sep$,$endfor$]{$CJKmainfont$}
    $endif$
    $if(CJKsansfont)$
        \setCJKsansfont[$for(CJKsansfontoptions)$$CJKsansfontoptions$$sep$,$endfor$]{$CJKsansfont$}
    $endif$
    $if(CJKmonofont)$
        \setCJKmonofont[$for(CJKmonofontoptions)$$CJKmonofontoptions$$sep$,$endfor$]{$CJKmonofont$}
    $endif$
    $if(inputfile)$
        \input{$inputfile$}
    $endif$

3. 在 `/etc/rst2arb.conf` 或 `~/.rst2arb.conf` 中，设定常用字体。

   默认示例：
    
   西文字体,

   .. code:: bash

    mainfont:'Times New Roman', or 'DejaVu Serif'
    sansfont:Verdana, or Arial
    monofont:Monaco, or 'Courier New'

   中文字体:

   .. code:: bash

    xeCJK:CJKspace=true,CheckSingle=true,PlainEquation=true,PunctStyle=CCT
    ctex:UTF8,heading=true

    CJKmainfont:SimSun
    CJKmainfontoptions:BoldFont=SimHei,ItalicFont=KaiTi,AutoFakeSlant,FallBack='WenQuanYi Micro Hei'

    CJKsansfont:SimHei
    CJKsansfontoptions:AutoFakeBold,AutoFakeSlant,FallBack='Microsoft YaHei'

    CJKmonofont:'WenQuanYi Micro Hei Mono'
    CJKmonofontoptions:AutoFakeBold,AutoFakeSlant,FallBack='WenQuanYi Zen Hei Mono'

4. 指定 `inputfile`, 添加额外设定。一个示例： `myinput.tex`

   .. code:: bash

    -V inputfile:./myinput.tex

beamer 的 theme colortheme 可设定值有那些？
-------------------------------------------

.. code:: bash

    cd /usr/share/texmf-dist/tex/latex
    find . -name 'beamertheme*.sty' | sed 's|^.*/beamertheme||;s|\.sty$||'
    find . -name 'beamercolortheme*.sty' | sed 's|^.*/beamercolortheme||;s|\.sty$||'

TODO
====

* 添加一些其他模板
