#!/bin/bash

# ./grow.sh clean - removes generated content/ folders
# ./grow.sh start end [inc] - start building with 10*start articles, increment by 10*inc until 10*end articles

function time_zola() {
    out="$(zolabench build | grep -Po "\d+\.?\d*m?s")"
    echo "$out" | grep -Pq "\d+ms"
    if [[ $? == 0 ]]; then
        # ms, not s
        s="$(echo $out | grep -oP "\d+")"
        echo "0.${s}"
    else
        # s
        echo "$out" | grep -oP "\d+\.\d*"
    fi
}

# If themes/static not here, copy from test_site
[ ! -d themes ] && cp -R ../../../../test_site/themes themes
[ ! -d static ] && cp -R ../../../../test_site/static static
[ ! -d templates ] && cp -R ../../../../test_site/templates templates

if [[ $1 = "clean" ]]; then
    cp -R content/cat1 /tmp/cat1
    rm -R content/*
    cp -R /tmp/cat1 content/
    exit 0
fi

if [ $# -eq 0 ]; then
   iter=1
   max=100
else
    if [ $# -lt 2 ]; then
        echo "grow.sh MIN MAX"
        exit 1
    fi
    iter=$1 && max=$2
fi

[[ $# > 2 ]] && inc=$3 || inc=1

echo "start: $((10 * iter)), end: $((10 * $max)), increment: $((10 * $inc))"

if [ ! -d content/cat${iter} ]; then
    echo "Creating missing sections"
    i=2
    while [ $i -lt $iter ]; do
        cp -R content/cat1 content/cat${i}
        ((i++))
    done
fi

# Ensure no additional section is here
if [ -d "content/cat$(expr $iter + 1)" ]; then
    echo "Removing extra sections"
    i=$(expr $iter + 1)
    while [ -d content/cat${i} ]; do
        rm -R content/cat${i}
        ((i++))
    done
fi


while [ $iter -le $max ]; do
    t1="$(time_zola)"
    t2="$(time_zola)"
    t3="$(time_zola)"
    t="$(echo "($t1 + $t2 + $t3) / 3" | bc -l)"
    echo $t
    i=0
    # Increment sections by $inc
    while [ $i -lt $inc ]; do
        ((iter++))
        [ $iter -le $max ] && cp -R content/cat1 content/cat${iter} || break
        ((i++))
    done
done
