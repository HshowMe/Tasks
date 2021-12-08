#!/bin/bash
h=
d=
v=
oset=
sfx=
dir=
mask=()
a=()
for arg in "$@"
do
    if [[ "${arg:0:1}" == "-" ]]
    then
        case $arg in
        -h) echo "$0: Inserting a suffix to the file name"
            echo "Usage: $0 [-h] [-d|-v] [--] (sfx) (dir) (mask1 [mask2...])"
            echo "-h - print help and exit"
            echo "-d - dry run (only print old and new names without renaming)"
            echo "-v - verbose output (print old and new names of renamed files)"
            echo "-- - option and non-optional argument separator (support minus-starting suffixes)"
            echo "dir - directory to find files in (all suitable files in this directory and its subdirectories)"
            echo "mask1, mask2, ... - file name templates"
            exit 0
            ;;
        -v) v=1
            ;;
        -d) d=1
            ;;
        --) break
            ;;
        *) echo "$arg is invalid option...type -h for help!" >&2
            exit 2
            ;;
        esac
    fi
done

for arg in "$@"
do
    if [[ $oset ||  "${arg:0:1}" != "-" ]]
    then
        if [[ -z $sfx ]]
        then
            sfx=$arg
        elif [[ -z $dir ]]
        then
            dir=$arg

        else
            mask+=($arg)
        fi
    elif [[ "$arg" == "-" ]]
    then
        oset=1
    fi
done
if [[ -d $sfx && ! -d $dir ]]
then
    dir=$sfx
    sfx=
fi
if [[ ! $dir || ! -d $dir ]]
then
    echo "Error!! -there is no directory given or this directory does not exist!" >&2
    exit 2
elif [[ -z $sfx ]]
then
    echo "Error!! -there is no sfx given...type -h for help" >&2
    exit 2
elif [[ -z $d && -z $v ]]
then
    echo "Error!! -there is no option given...type -h for help" >&2
    exit 2
fi
echo "dir = $dir"
echo "sfx = $sfx"
echo ${mask[0]}


result=`for m in "${mask[@]}"; do find $dir \( -name "$m" \) -print0 ; done | while read -rd $'\0' file; do echo $file; done `
#echo $result # | tr -s " " "\n"
a+=($result)


for arg in ${a[@]}
do
    name="${arg%.*}"
    ext="${arg#"$name"}"
    newname="$name$sfx$ext"
    if [[ $d ]]
    then
        echo "$arg -> $newname"
    fi
    if [[ $v ]]
    then
        mv -- "$arg" "$newname"
        echo "$arg -> $newname"
    fi
done


