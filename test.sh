#!/usr/bin/env bash
if pandoc -v 2>&1 >/dev/null; then
    if which xelatex 2>&1 >/dev/null; then
        DIR="$(kpsewhich -var-value=TEXMFDIST)/tex/latex"
        export TEXMFHOME=./texmf
        _option="-f rst --latex-engine=xelatex -V cjkfont=cjkfont1 -V date=\today"

        _op1=" -N --toc --template=latex-cjk.tex -V geometry:left=2cm,right=2cm,top=2.5cm,bottom=2.5cm"
        echo "-- article --"
        pandoc ${_option} ${_op1} -V documentclass=article README.rst -o cache/test-article.pdf
        echo "-- report --"
	    pandoc ${_option} ${_op1} -V documentclass=report README.rst -o cache/test-report.pdf
        echo
        
        echo "---------- beamer ----------"
        _op2="--template=beamer-cjk.tex -t beamer"
        themes=(m)
        colorthemes=(solarized)
        if [[ x$1 == xall ]]; then
            themes+=($(find $DIR -name 'beamertheme*.sty' | sed 's|^.*/beamertheme||;s|\.sty$||'))
            colorthemes+=($(find $DIR -name 'beamercolortheme*.sty' | sed 's|^.*/beamercolortheme||;s|\.sty$||'))
        fi
        for t in ${themes[@]}; do
            echo "Theme: ${t}"
            pandoc ${_option} ${_op2} -V theme=$t README.rst -o cache/test-theme-${t}.pdf
        done
        for c in ${colorthemes[@]}; do
            echo "colorTheme: ${c}"
            pandoc ${_option} ${_op2} -V colortheme=$c README.rst -o cache/test-colortheme-${c}.pdf
        done
        echo "----------"
    else
        echo "xelatex not found."
    fi
else \
    echo "pandoc not installed."
fi

