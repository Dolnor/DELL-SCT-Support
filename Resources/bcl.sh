#!/bin/bash

function regen {

    if [[ -e $1 && ! -n "$(printf '%s\n' "$2" | sed -E 's/[0-9\+\-]//g')" ]]; then

        echo " ---------------"
        printf " file : $1\n delta: $2\n"
        echo " ---------------"

        i=1; j=0
        printf "                1807, %d, //ac + dc level group\n" $((479 $2))
        printf "                0, "
        while read entry;
        do
            $(echo $entry | grep -q "0x" )
            if [[ $? -eq 0 && $entry != "0x00"  && $entry != "0x0710" ]]; then
                printf "%d, " $((entry $2))
                if let "$i%4 == 0"; then
                    printf "//0x%02x level group\n" $j
                    printf "                "
                    j=$((j+1))
                fi
                i=$((i+1))
            fi
        done < $1
        printf "1808  //0x0f level group\n"
    else
        echo "bad arguments"
    fi

}

function newgen {

if [[ ! -z $1 && ! -z $2 ]]; then
    echo " ---------------"
    printf " start: $1\n delta: $2\n"
    echo " ---------------"

    i=$1; j=0
    printf "                1807, %d, //ac + dc level group\n" $((479+0))
    printf "                0, "
    for (( k=1; $k < 64; k=$((k+1))))
    do
        printf "%d, " $i
        i=$((i+$2))
        if let "$k%4 == 0"; then
            printf "//0x%02x level group\n" $j
            printf "                "
            j=$((j+1))
        fi
    done
    printf "1808  //0x0f level group\n"
else
    echo "bad arguments"
fi
}

function usg {

    printf "cli commands:\n"
    printf "\tgenerate new backlight levels: -n <min level> <step>\n"
    printf "\trecalculate levels from file : -r <file_name> <+/-step>\n"

}

case $1 in
    -n)
        newgen $2 $3;;
    -r)
         regen $2 $3;;
    * )
        usg;;
esac