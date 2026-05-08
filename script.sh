#!/bin/bash
# shellcheck disable=SC2015 # if echo fails we have bigger problems
# !hellcheck disable=SC2046 # intentional golfing
# !hellcheck disable=SC2210 # files named 1 or 2 confuses shellcheck
# !hellcheck disable=SC1004 # backslash+linefeed is processed again later
# !hellcheck disable=SC2196 # yeah, yeah .. egrep is non-standard and deprecated

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
check getting qemu disk image;         wget -q -O - ${qdisk}/qdisk.part-a{a..c}         \
                                         |bunzip2 >qdisk.img                            2>/dev/null     && ok || nok
#check convert disk to raw;             qemu-img convert \
#                                         -f qcow2 -O raw qdisk.img disk.img             >/dev/null 2>&1 && ok || nok


check getting raw second disk;         wget -q -O - ${qdisk}/pdisk.img.bz2 \
                                         |bunzip2 >pdisk.img                            2>/dev/null     && ok || nok
check convert second disk to qcow2;    qemu-img convert \
                                         -f raw -O qcow2 pdisk.img qdisk2.img           >/dev/null 2>&1 && ok || nok



#check split and zstd compress disk;    tools/split-image.py --zstd \
#                                         1M disk.img 386bsd/%d-%d.img                   >/dev/null 2>&1 && ok || nok
)|format

cd "${wd}/v86"

cat >1.cmd <<"__EOF1__"
root

exec /usr/othersrc/public/bash-1.12/bin/bash
ulimit -d 32768
set +H
touch /fastboot
f=/tmp/earlyboot.list
echo "/" >>$f
echo "/bin" >>$f
echo "/etc" >>$f
echo "/sbin" >>$f
echo "/usr" >>$f
echo "/usr/sbin" >>$f
echo "/usr/bin" >>$f
echo "/tmp" >>$f
echo "/dev" >>$f
echo "/var" >>$f
echo "/var/log" >>$f
echo "/var/run" >>$f
echo "/var/crash" >>$f
echo "/var/tmp" >>$f
echo "/var/cron" >>$f
echo "/var/cron/tabs" >>$f
echo "/var/spool/lpd" >>$f
echo "/var/spool/mqueue" >>$f
echo "/var/spool/output" >>$f
echo "/var/spool/uucp" >>$f
echo "/usr/libexec" >>$f
echo "/usr/share" >>$f
echo "/usr/share/zoneinfo" >>$f
echo "/sbin/init" >>$f
echo "/bin/sh" >>$f
echo "/etc/rc" >>$f
echo "/fastboot" >>$f
echo "/bin/stty" >>$f
echo "/bin/[" >>$f
echo "/sbin/swapon" >>$f
echo "/etc/fstab" >>$f
echo "/sbin/umount" >>$f
echo "/sbin/mount" >>$f
echo "/bin/rm" >>$f
echo "/etc/netstart" >>$f
echo "/bin/cat" >>$f
echo "/etc/myname" >>$f
echo "/bin/hostname" >>$f
echo "/sbin/ifconfig" >>$f
echo "/etc/hosts" >>$f
echo "/bin/cp" >>$f
echo "/bin/chmod" >>$f
echo "/usr/sbin/syslogd" >>$f
echo "/etc/services" >>$f
echo "/var/run/syslog.pid" >>$f
echo "/etc/syslog.conf" >>$f
echo "/var/log/messages" >>$f
echo "/var/log/maillog" >>$f
echo "/var/log/lpd-errs" >>$f
echo "/etc/localtime" >>$f
echo "/var/run/utmp" >>$f
echo "/sbin/savecore" >>$f
echo "/386bsd" >>$f
echo "/usr/sbin/kvm_mkdb" >>$f
echo "/var/run//kvm_386bsd.db" >>$f
echo "/usr/sbin/dev_mkdb" >>$f
echo "/var/run//dev.db" >>$f
echo "/usr/libexec/elvispreserve" >>$f
echo "/usr/bin/find" >>$f
echo "/usr/sbin/update" >>$f
echo "/usr/libexec/crond" >>$f
echo "/var/run/crond.pid" >>$f
echo "/sbin/routed" >>$f
echo "/usr/sbin/lpd" >>$f
echo "/var/spool/output/lpd.lock" >>$f
echo "/etc/printcap" >>$f
echo "/etc/exports" >>$f
echo "/usr/sbin/sendmail" >>$f
echo "/etc/spwd.db" >>$f
echo "/usr/share/zoneinfo/GMT" >>$f
echo "/etc/sendmail.cf" >>$f
echo "/usr/sbin/inetd" >>$f
echo "/etc/inetd.conf" >>$f
echo "/etc/rc.local" >>$f
echo "/etc/motd" >>$f
echo "/usr/bin/strings" >>$f
echo "/usr/bin/sed" >>$f
echo "/bin/date" >>$f
echo "/usr/bin/grep" >>$f

echo "/usr/libexec/getty" >>$f
echo "/etc/ttys" >>$f
echo "/etc/gettytab" >>$f

echo "/etc/passwd" >>$f
echo "/etc/master.passwd" >>$f
echo "/usr/share/misc" >>$f
echo "/usr/share/misc/termcap" >>$f
echo "/etc/termcap" >>$f

echo "/usr/bin/login" >>$f
echo "/root" >>$f
echo "/root/.profile" >>$f
echo "/root/.cshrc" >>$f
echo "/root/.login" >>$f
echo "/dev/MAKEDEV" >>$f
echo "/.profile" >>$f
echo "/bin/csh"  >>$f

echo "/bin/sleep" >>$f
echo "/bin/ps" >>$f
echo "/bin/ls" >>$f
echo "/bin/df" >>$f
echo "/usr/bin/more" >>$f

# Batch 2 moved into /tmp/doe to avoid slowcat buffer overrun
echo "# Batch 2: find-based file discovery" >/tmp/doe
# XXX
#echo "cp /tmp/doe /etc/" >>/tmp/doe
echo "find /etc      -type f >>$f" >>/tmp/doe
echo "find /bin      -type f >>$f" >>/tmp/doe
echo "find /sbin     -type f >>$f" >>/tmp/doe
echo "find /usr/bin      -type f >>$f" >>/tmp/doe
echo "find /usr/libexec  -type f >>$f" >>/tmp/doe
echo "find /usr/sbin     -type f >>$f" >>/tmp/doe
echo "find /usr/share    -type f >>$f" >>/tmp/doe
# XXX
#echo "cp $f /etc" >>/tmp/doe
echo "find / -type f | grep -v '^/tmp' | grep -v '^/dev/' | grep -v '^/mnt' >>$f" >>/tmp/doe
echo "awk '!seen[\$0]++' $f >/tmp/earlyboot.uniq && mv /tmp/earlyboot.uniq $f" >>/tmp/doe
echo "" >>/tmp/doe
echo "mount /dev/wd1a /mnt" >>/tmp/doe
echo "rm -rf /mnt/* /mnt/.p*" >>/tmp/doe
echo "sync; sync; sync" >>/tmp/doe
echo "cat $f | cpio -p -d -m -u /mnt" >>/tmp/doe
echo "cd /mnt/dev" >>/tmp/doe
echo "sh MAKEDEV all" >>/tmp/doe
echo "cd /" >>/tmp/doe
echo "sync; sync; sync" >>/tmp/doe
echo "umount /dev/wd1a" >>/tmp/doe
echo "fsck /dev/rwd1a" >>/tmp/doe
echo "fsck /dev/rwd1a" >>/tmp/doe
echo "shutdown -rf now" >>/tmp/doe
chmod +x /tmp/doe; /tmp/doe
__EOF1__

echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo seventh boot
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
touch out
(
  until egrep -q 'login:|console' out ; do
    sleep 5;
  done
  sleep 5
  slowcat ./1.cmd 1 .1
)| TERM=vt100 script -f -c 'qemu          \
                -L /usr/local/share/qemu/ \
                -curses                   \
                -hda qdisk.img            \
                -hdb qdisk2.img           \
                -M isapc                  \
                -net nic                  \
                -no-reboot                \
                -m 64                     \
                -startdate "1994-04-23"'  \
 |tee -a out
echo %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo
mv out out_1.txt
