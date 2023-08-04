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
find latex/ -name '*.sty' -exec install -Dm644 {} ./cache/texmf/tex/{} \;
export TEXMFHOME=./cache/texmf

install -Dm644 rst2arb.conf cache/rst2arb.conf
install -Dm755 rst2arb.py cache/rst2arb
sed -i "s|\(^template.*= \)./\(latex-cjk.tex\)|\1$(pwd)/\2|" cache/rst2arb.conf
sed -i "s|\(SYSTEM_CONF.*=.*\)/etc/\(rst2arb.conf.*\)|\1$(pwd)/\2|" cache/rst2arb
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

cmd='./cache/rst2arb -f ./cache/rst2arb-beamer.conf'

# beamer, theme:m
sed 's/\( theme\):default/\1:m/' ./cache/rst2arb.conf > ./cache/rst2arb-beamer.conf
$cmd -i beamer
$cmd -s b README.rst -o cache/beamer-theme-m.pdf

# beamer, colortheme:solarized
sed 's/\(colortheme\):default/\1:solarized/' ./cache/rst2arb.conf > ./cache/rst2arb-beamer.conf
$cmd -i beamer
$cmd -s b README.rst -o cache/beamer-colortheme-solarized.pdf

# beamer, others
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
