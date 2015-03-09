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

* 安装 `texlive <http://www.latex-project.org/>`_ , `pandoc <http://johnmacfarlane.net/pandoc/>`_ 。

* 文本编辑器: `vim <http://www.vim.org>`_ 不错。  

* 熟悉 `rst <http://docutils.sourceforge.net/docs/user/rst/quickstart.html>`_

使用
========

.. code:: bash

    make pre
    export TEXMFHOME=./texmf

* 生成 article, report：
  
.. code:: bash

    pandoc -f rst --template=latex-cjk.tex --latex-engine=xelatex -N --toc \  
        -V cjkfont=cjkfont1 -V documentclass=[article|report] \
        -V geometry:left=2cm,right=2cm,top=2.5cm,bottom=2.5cm \
        -V date='\today' README.rst -o README.pdf

* 生成 beamer :

.. code:: bash

    pandoc -f rst --template=beamer-cjk.tex --latex-engine=xelatex -t beamer \
        -V cjkfont=cjkfont1 -V theme=m -V colortheme=solarized -V date='\today' \
        README.rst -o README.pdf


* 利用脚本 rst2arb.sh

FAQ
====

模板如何获得？
--------------

1. 输出默认模板 :code:`pandoc -D latex >latex-cjk.tex`, :code:`pandoc -D beamer >beamer-cjk.tex`

2. 编辑 \*-cjk.tex, 在 :code:`\ifxetex` 后添加

.. code:: latex

    % SUPPORT for Chinese
    $if(cjkfont)$
      \usepackage{$cjkfont$}
    $endif$

beamer 的 theme colortheme 可设定值有那些？
-------------------------------------------

.. code:: bash

    cd /usr/share/texmf-dist/tex/latex
    find . -name 'beamertheme*.sty' | sed 's|^.*/beamertheme||;s|\.sty$||'
    find . -name 'beamercolortheme*.sty' | sed 's|^.*/beamercolortheme||;s|\.sty$||'

TODO
====

自定义部分写成 latex Package。
