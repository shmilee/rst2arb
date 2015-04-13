#!/usr/bin/env bash

usage () {
    cat <<EOF
Usage: $0 [options] <ReST files>

Options:
  -a          convert to article
  -r          convert to report
  -b          convert to beamer
  -s          output TeX source too
  -c <theme>  set beamer colortheme
  -t <theme>  set beamer theme
  -l          list available themes
  -h          show this information

Options passed to pandoc:
  -V KEY[:VALUE] set variable in template of Tex

default values(no space) for all:
  cjkfont:'cjkfont1'
default values for article and report:
  geometry:'left=2cm,right=2cm,top=2.5cm,bottom=2.5cm'
default values for beamer:
  colortheme:'default'
  theme:'default'

Output FileName:
  InputName-article.pdf | InputName-report.pdf | InputName-beamer.pdf
Example:
a.rst --> a-beamer.pdf (a-beamer.tex)
EOF
}

# list "${@:3}", $1 beginning number, $2 the number of items in a row
list () {
    local n=($(seq -w $1 $((${#@}+$1-3)))) i=0 _f
    for _f in ${@:3}; do
        (($i%$2==0)) && echo -e -n ""
        echo -e -n "${n[$i]}) $_f;\t"
        (( $i%$2 == $(($2-1)) )) && echo
        ((i++))
    done
    (($i%$2==0)) || echo
}

list_all () {
    DIR="$(kpsewhich -var-value=TEXMFDIST)/tex/latex"
    themes=($(find $DIR -name 'beamertheme*.sty' | sed 's|^.*/beamertheme||;s|\.sty$||'|sort))
    colorthemes=($(find $DIR -name 'beamercolortheme*.sty' | sed 's|^.*/beamercolortheme||;s|\.sty$||'))
    echo " ----- Beamer Themes -----"
    list 1 3 ${themes[@]}
    echo
    echo " -----Beamer ColorThemes -----"
    list 1 2 ${colorthemes[@]}
}

# Options
OPT_SHORT="abc:hlrst:V:"
if ! OPT_TEMP="$(getopt -q -o $OPT_SHORT -- "$@")";then
    usage;exit 1
fi
eval set -- "$OPT_TEMP"
unset OPT_SHORT OPT_TEMP

OPER=''
V_OPTION=''
SRC='no'
while true; do
    case $1 in
        -a)  OPER+='A ' ;;
        -r)  OPER+='R ' ;;
        -b)  OPER+='B ' ;;
        -s)  SRC='yes' ;;
        -c)  shift; COLOR_THEME=$1 ;;
        -t)  shift; THEME=$1 ;;
        -V)  shift; V_OPTION+="-V $1 " ;;
        -l)  list_all; exit 0 ;;
        -h)  usage; exit 0 ;;
        --)  OPT_IND=0; shift; break ;;
        *)   usage; exit 1 ;;
    esac
    shift
done

# -V default values
if ! echo $V_OPTION | grep -E 'cjkfont[:=]' 2>&1 >/dev/null; then
    V_OPTION+="-V cjkfont:cjkfont1 "
fi
if ! echo $V_OPTION | grep -E 'geometry[:=]' 2>&1 >/dev/null; then
    V_OPTION+="-V geometry:left=2cm,right=2cm,top=2.5cm,bottom=2.5cm "
fi
COLOR_THEME=${COLOR_THEME:-default}
THEME=${THEME:-default}

# Convert
TEMPLATE_PATH=##TPATH##
default_option="-f rst --latex-engine=xelatex"
ar_option="$default_option -N --toc --template=${TEMPLATE_PATH}/latex-cjk.tex"

a_option="$ar_option -V documentclass:article $V_OPTION"
r_option="$ar_option -V documentclass:report $V_OPTION"
b_option="$default_option --template=${TEMPLATE_PATH}/beamer-cjk.tex -t beamer \
    $V_OPTION -V colortheme:$COLOR_THEME -V theme:$THEME"

if [[ $# == 0 ]]; then
    echo "No Input rst file!"
    exit 1
fi
for FILE in $@; do
    if [ ! -f "$FILE" ];then
        echo "==> File not found: $FILE !"
        exit 2
    fi
    echo "==> Converting $FILE to ..."
    OUT="$(basename ${FILE})"
    OUT=${OUT%.rst}
    for oper in $OPER; do
        case $oper in
            A)
                echo " -> Article ..."
                pandoc $a_option "$FILE" -o "${OUT}-article.pdf"
                if [[ $SRC == yes ]]; then
                    echo " -> TeX for article ..."
                    pandoc $a_option "$FILE" -o "${OUT}-article.tex"
                fi
                ;;
            R)
                echo " -> Report ..."
                pandoc $r_option "$FILE" -o "${OUT}-report.pdf"
                if [[ $SRC == yes ]]; then
                    echo " -> TeX for report ..."
                    pandoc $r_option "$FILE" -o "${OUT}-report.tex"
                fi
                ;;
            B)
                echo " -> Beamer ..."
                pandoc $b_option "$FILE" -o "${OUT}-beamer.pdf"
                if [[ $SRC == yes ]]; then
                    echo " -> TeX for beamer ..."
                    pandoc $b_option "$FILE" -o "${OUT}-beamer.tex"
                fi
                ;;
            *)
                msg "Unknown option."
                ;;
        esac
    done
    echo
done
