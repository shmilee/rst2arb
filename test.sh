#!/usr/bin/env bash
if ! pandoc -v 2>&1 >/dev/null; then
    echo "pandoc not installed."
    return 1
fi
if ! which xelatex 2>&1 >/dev/null; then
    echo "xelatex not found."
    return 1
fi

DIR="$(kpsewhich -var-value=TEXMFDIST)/tex/latex"

make install DESTDIR=./cache BIN_DIR= ETC_DIR= template_PATH=. TEXMFDIST=texmf
sed -i "s|\(SYSTEM_CONF = '\).*/\(rst2arb.conf.*\)|\1$(pwd)/\2|" ./cache/rst2arb
export TEXMFHOME=./cache/texmf
cmd='./cache/rst2arb -f ./cache/rst2arb.conf'

# article
$cmd -i article
$cmd -s a README.rst -o cache/article.pdf

# report
$cmd -i report
$cmd -s r README.rst -o cache/report.pdf

# beamer
$cmd -i beamer
$cmd -s b README.rst -o cache/beamer-default.pdf

# article-eisvogel
$cmd -i article-eisvogel
$cmd -s ae README.rst -o cache/article-eisvogel.pdf


cmd='./cache/rst2arb -f ./cache/rst2arb-beamer.conf'

# beamer, colortheme:solarized
sed 's/\(colortheme\):default/\1:solarized/' ./cache/rst2arb.conf > ./cache/rst2arb-beamer.conf
$cmd -i beamer
$cmd -s b README.rst -o cache/beamer-colortheme-solarized.pdf

# beamer, system theme & colortheme
if [[ x$1 == xall ]]; then
    themes=($(find $DIR -name 'beamertheme*.sty' | sed 's|^.*/beamertheme||;s|\.sty$||'))
    colorthemes=($(find $DIR -name 'beamercolortheme*.sty' | sed 's|^.*/beamercolortheme||;s|\.sty$||'))
    for t in ${themes[@]}; do
        sed "s/\( theme\):default/\1:${t}/" ./cache/rst2arb.conf > ./cache/rst2arb-beamer.conf
        $cmd -i beamer
        $cmd -s b README.rst -o cache/beamer-theme-${t}.pdf
    done
    for c in ${colorthemes[@]}; do
        sed "s/\(colortheme\):default/\1:${c}/" ./cache/rst2arb.conf > ./cache/rst2arb-beamer.conf
        $cmd -i beamer
        $cmd -s b README.rst -o cache/beamer-colortheme-${c}.pdf
    done
fi
