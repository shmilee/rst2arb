#!/usr/bin/env bash
if pandoc -v 2>&1 >/dev/null; then
    common_option="-f rst --template=beamer-cjk.tex --latex-engine=xelatex -t beamer -V cjk=yes -V date=\today"
    if which xelatex 2>&1 >/dev/null; then
        export TEXMFHOME=./texmf
        echo "Theme: m"
        pandoc ${common_option} -V theme=m README.rst -o cache/test-theme-m.pdf
        echo "colorTheme: solarized"
        pandoc  ${common_option} -V colortheme=solarized README.rst -o cache/test-colortheme-solarized.pdf

        if [[ x$1 != xall ]]; then
            exit 0
        fi
        DIR="$(kpsewhich -var-value=TEXMFDIST)/tex/latex"
        echo "----- Themes -----"
        themes="$(find $DIR -name 'beamertheme*.sty' | sed 's|^.*/beamertheme||;s|\.sty$||')"
        for t in $themes; do
            echo "Theme: ${t}"
            pandoc ${common_option} -V theme=$t README.rst -o cache/test-theme-${t}.pdf
        done
        echo "----- colorThemes -----"
        colorthemes="$(find $DIR -name 'beamercolortheme*.sty' | sed 's|^.*/beamercolortheme||;s|\.sty$||')"
        for c in $colorthemes; do
            echo "colorTheme: ${t}"
            pandoc ${common_option} -V colortheme=$c README.rst -o cache/test-colortheme-${c}.pdf
        done
    else
        echo "xelatex not found."
    fi
else \
    echo "pandoc not installed."
fi

