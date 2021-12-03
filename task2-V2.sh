#!/bin/bash
file=
f=
login=

# LOOP FOR THE ARGUMENTS
for arg in "$@"
do
    if [[ -n $f ]]
    then
        file=$arg
        f=
    elif [[ "${arg:0:1}" == "-" && -z $f ]]
    then
        case $arg in
        -f) f=1
            ;;
        *) echo "$arg is invalid option" >&2
            exit 2
            ;;
        esac
    else
    login=$arg
    fi
done

# CHECK IF LOGIN EXIST
if [[ -z $login ]]
then
    if [[ -f $file ]]
    then
        login=$USER
    else
        login="${@: -1}"
    fi
fi

# CHECKING FOR THE FILES
if [[ $file ]]
then
    if [[ $login = $file ]]
    then
    file=/etc/passwd
    fi
    if [[ ! -f "$file" ]]
    then
        echo "$file Does not exist!" >&2 
        exit 2
    fi
else
    file=/etc/passwd
fi

# PRINT THE RESULT
if [[ $file && $login ]]
then
    if [[ $file = "/etc/passwd" ]]
    then
        result=`cat $file | grep -wE ^$login: | cut -d: -f6`
        echo "$result"
    else 
        result=`cat $file | grep -wE ^$login:`
        echo "$result"
    fi
fi