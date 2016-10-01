#!/bin/mksh

topdir="$1"; shift

tests="$*"
if [ -z "${tests}" ];then
    for t in $(echo test-*.sh);do
        t=${t#test-*-}
        t=${t%.sh}
        tests="$tests $t"
    done
fi

export topdir

for t in ${tests};do
    for f in ./test-*-"${t}".sh;do
        t=${f%.sh}
        t=${t##*/test-}
        printf '....: %s' "$t"
        color='\e[1;31m'
        result=FAIL
        if sh ./"${f}" > test-"${t}".output 2>&1;then
            color='\e[1;32m'
            result=PASS
        else
            color='\e[1;31m'
            result=FAIL
        fi
        if cmp -s test-"${t}".expected test-"${t}".output;then
            rm test-"${t}".output
            color='\e[1;32m'
            result=PASS
        else
            color='\e[1;31m'
            result=FAIL
        fi
        printf "\r${color}%s\e[0m: %s\n" "${result}" "$t"
    done
done

