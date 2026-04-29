#!/bin/bash
# hellcheck disable=SC2015 # if echo fails we have bigger problems
# hellcheck disable=SC2046 # intentional golfing
# hellcheck disable=SC2210 # files named 1 or 2 confuses shellcheck
# hellcheck disable=SC1004 # backslash+linefeed is processed again later
# hellcheck disable=SC2196 # yeah, yeah .. egrep is non-standard and deprecated

function check {
  echo -ne "$*\t"
}

function ok {
  echo -e "[ \e[38;5;32msuccess\e[0m ]"
}

function nok {
  echo -e "[ \e[38;5;31mfailure\e[0m ]"
  exit 1
}

function warn {
  echo -e "[ \e[38;5;33mwarning\e[0m ]"
}

function format {
  awk -F'\t' '{ printf "%-60s %s\n",$1,$2 }'
}

function slowcat {
[[ -z "${3}" ]] && echo usage: "$0" file chunksize waittime && return 1
  local c=0
  local b
  b=$(wc -c <"${1}")
    while [ ${c} -lt "${b}" ]; do
    dd if="${1}" bs=1 count="${2}" skip=${c} 2>/dev/null
    (( c = c + ${2} ))
    sleep "${3}"
  done
}

function patchbuttons {
  # TODO
  return 0
}

function index {
  echo "<HTML><HEAD><TITLE>LINKS</TITLE></HEAD><BODY><ul>" >index.html
  echo "</ul></BODY></HTML>" >>index.html
}

wd="$(pwd)"
# For details on this custom qemu build, see
# https://github.com/dugoh/gha-oldqemu
# In short it is 0.11 patched to 
# - build in todays Action runner
# - run headless
qemu_bin=https://dugoh.github.io/gha-oldqemu/qemu.tar.bz2
# For details on the 386BSD 0.1 + patchkits install, see
# https://github.com/dugoh/gha
# In short it builds a QCOW2 image from first principles
qdisk=https://dugoh.github.io/gha/
# v86 emulates an x86-compatible CPU in the browser
v86repo=https://github.com/copy/v86.git
v86pin=b0794c9f574a490edaa1db6160c45b0d348201ef

(




cd /tmp || exit 1
check download custom qemu;            wget -q -O - "${qemu_bin}"                       \
                                         |bunzip2 -c                                    \
                                         |tar -xf -                                     >/dev/null 2>&1 && ok || nok
cd qemu || exit 1
check install custom qemu;             sudo make install                                >/dev/null 2>&1 && ok || nok
cd "${wd}" || exit 1
check test qemu;                       qemu --help                                      >/dev/null 2>&1 && ok || nok
check setting qemu capabilities;       sudo setcap                                      \
                                         CAP_NET_ADMIN,CAP_NET_RAW=eip                  \
                                         /usr/local/bin/qemu                            >/dev/null 2>&1 && ok || nok

                                         




check fetch v86 repo;                  git clone "${v86repo}"                           >/dev/null 2>&1 && ok || nok
cd v86 || exit 1
check check out known good commit;     git checkout "${v86pin}"                         >/dev/null 2>&1 && ok || nok
check patch in 386BSD;                 patchbuttons                                     >/dev/null 2>&1 && ok || nok
check avoid filename collisions;       mv index.html ogindex.html                       >/dev/null 2>&1 && ok || nok
check make the debug version;          make                                             >/dev/null 2>&1 && ok || nok
check make the rest of it;             make all                                         >/dev/null 2>&1 && ok || nok
check make capstone;                   make build/capstone-x86.min.js                   >/dev/null 2>&1 && ok || nok
check make libwabt;                    make build/libwabt.cjs                           >/dev/null 2>&1 && ok || nok
check make xterm;                      make build/xterm.js                              >/dev/null 2>&1 && ok || nok
check patch split script;              sed -i -e 's/) = sys.argv/) = args/' \
                                         tools/split-image.py                           >/dev/null 2>&1 && ok || nok

mkdir images || exit 1
cd images || exit 1
check getting qemu disk image;         wget -q -O - ${qdisk}/qdisk.part-a{a..c}         \
                                         |bunzip2 >qdisk.img                            2>/dev/null     && ok || nok
check convert disk;                    qemu-img convert \
                                         -f qcow2 -O raw qdisk.img disk.img             >/dev/null 2>&1 && ok || nok

check split disk;                      ../tools/split-image.py --zstd \
                                         28m disk.img 386bsd/disk-%d-%d.img             >/dev/null 2>&1 && ok || nok
#rm *disk.img || exit 1



)|format

find ./ >&2


