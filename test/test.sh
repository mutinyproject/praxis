#!/bin/sh
#
# Riot, a from-source package manager for Mutiny Linux.
#
# Copyright (c) 2016 Kylie McClain <kylie@somasis.com>
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE

export topdir="${1:-$PWD}"

if [ -t 1 ];then
    color_bold='\e[1m'
    color_red='\e[1;31m'
    color_green='\e[1;32m'
    color_reset='\e[0m'
fi

test_num=0

expect_out() {
    test_num=$(( test_num + 1 ))
    expecting="${1}"; shift
    output=$(eval "${@}" 2>&1)
    if [ "${output}" = "${expecting}" ];then
        printf "${color_green}ok %s %s${color_reset}\n" "${test_num}" "$*"
    else
        printf "${color_red}not ok %s %s${color_reset}\n" "${test_num}" "$*"
        printf '    %s\n' "Expected:"
        printf '%s\n' "${expected}" | while read line;do
            printf '    %s\n' "${line}"
        done
        printf '# %s\n' "Output:"
        printf '%s\n' "${output}" | while read line;do
            printf '    %s\n' "${line}"
        done
    fi
}

expect_exit() {
    test_num=$(( test_num + 1 ))
    expecting="${1}"; shift
    err=0
    "${@}" || err=$?
    if [ "${err}" -eq "${expecting}" ];then
        printf "${color_green}ok %s %s${color_reset}\n" "${test_num}" "$* - got expected exit of ${expecting}"
    else
        printf "${color_red}not ok %s %s${color_reset}\n" "${test_num}" "$* - expected to exit with ${expecting}, but exited with ${err}"
    fi
}

new_set() {
    printf "${color_bold}# %s${color_reset}\n" "$@"
}

vercmp() {
    ${topdir}/bin/vercmp.sh "$@"
}

me=$(readlink -f "${0}")
total_tests=$(grep -Ec '^expect_(exit|out) ' "${me}")

printf '1..%s\n' "${total_tests}"

new_set "Comparing integer versions"
expect_exit 0       vercmp --newer-than 1 0
expect_out "14"     vercmp --newest 4 3 2 1 0 3 5 3 9 14
expect_exit 0       vercmp --older-than 0 1
expect_out "0"      vercmp --oldest 4 3 2 1 0 3 5 3 9 14

new_set "Comparing simple versions with same amounts of parts"
expect_exit 0       vercmp --newer-than 1.0 0.9
expect_exit 1       vercmp --newer-than 0.9 1.0
expect_out  "1.0"   vercmp --newest 1.0 0.9 0.09 0.01
expect_out  "0.01"  vercmp --oldest 1.0 0.9 0.09 0.01

new_set "Determine newest version in a set"
expect_out "4.0"    vercmp --newest 1.0 2.0 3.0 4.0
expect_out "4.3.0"  vercmp --newest 1.3.0.1 1.3.1 2.9.2 2.9 4.3.0 0.5.0

new_set "Logic tests - ="
expect_exit 0       vercmp --match 1.2  '=1.2.0'
expect_exit 1       vercmp --match 3.2.0 '=3.2.5'

new_set "Logic tests - >="
expect_exit 0       vercmp --match 3.5.3 '>=3.5.2'
expect_exit 0       vercmp --match 3.5.2 '>=3.5.2'
expect_exit 1       vercmp --match 3.5.1 '>=3.5.2'

new_set "Logic tests - <="
expect_exit 0       vercmp --match 3.5.1 '<=3.5.2'
expect_exit 0       vercmp --match 3.5.2 '<=3.5.2'
expect_exit 1       vercmp --match 3.5.3 '<=3.5.2'

new_set "Logic tests - >"
expect_exit 0       vercmp --match 3.5.3 '>3.5.2'
expect_exit 1       vercmp --match 3.5.2 '>3.5.2'

new_set "Logic tests - <"
expect_exit 0       vercmp --match 3.5.1 '<3.5.2'
expect_exit 1       vercmp --match 3.5.2 '<3.5.2'

new_set "Logic tests - multiple operators"
expect_exit 0       vercmp --match 3.5   '>=3.4.0.2&<4'
expect_exit 1       vercmp --match 2.7.1 '<2&>=5.0'

