#
# root.mak
#
# This makefile creates a bare root filesystem with pieces
# which are not really configurable (or not yet, anyway).
#
# It should be invoked prior to any other xyz_targetinstall targets.
#
# History:
# $Log: rootfs.mak,v $
# Revision 1.1  2004-06-06 14:58:14  ericn
# -Initial import, 1st pass
#
#
#
.PHONY base-root:

all: base-root

TARGETS := root/etc/bashrc \
           root/etc/hosts \
           root/etc/inittab \
           root/etc/modules.conf \
           root/etc/nsswitch.conf \
           root/etc/resolv.conf \
           root/etc/ld.so.conf \
           root/etc/ld.so.cache \
           root/bin/jsMenu \
           root/etc/init.d/rcS

root/etc/bashrc:
	echo "#!/bin/sh" > $@
	echo "# CURLTMPSIZE should be smaller than sizeof ramdisk from " >> $@
	echo "# mke2fs call by size of the largest file to be downloaded" >> $@
	echo "export CURLTMPSIZE=4000000" >> $@

root/etc/hosts: /etc/hosts
	cp -f $< $@ 

root/etc/inittab:
	echo "::sysinit:/etc/init.d/rcS" >> $@
	echo "::wait:/bin/echo Welcome" >> $@
	echo "tty2::askfirst:-/bin/sh" >> $@
	echo "tty3::askfirst:-/bin/sh" >> $@
	echo "tty4::askfirst:-/bin/sh" >> $@
	echo "::respawn:/bin/sh" >> $@
	echo "::ctrlaltdel:/sbin/reboot" >> $@
	echo "::shutdown:/sbin/swapoff -a" >> $@
	echo "::shutdown:/bin/umount -a -r" >> $@
	echo "::restart:/sbin/init" >> $@
	chmod a+x $@

root/etc/modules.conf:
	echo "alias wlan0 prism2_cs" > $@

root/etc/nsswitch.conf:
	echo "hosts:      files dns" > $@

root/etc/resolv.conf:
	echo "# name servers go here" >$@

root/etc/ld.so.conf:
	echo -e "" > $@

root/etc/ld.so.cache: root/etc/modules.conf root/etc/ld.so.conf
	-cd root/etc/fstab/lib && arm-linux-strip *
	cd root/etc && /sbin/ldconfig -r ../ -v

#
# Javascript startup menu
#
root/bin/jsMenu: 
	echo "#!/bin/sh" >$@
	echo "while ! [ -f /tmp/ctrlc ] ; do /bin/jsExec file:///js/mainMenu.js; done" >>$@
	chmod a+x $@

#
# startup script
#
root/etc/init.d:
	mkdir -p $@

root/etc/init.d/rcS: root/bin/jsMenu root/etc/init.d
	echo "#!/bin/sh" >$@
	echo "  mount -t proc /proc /proc" >>$@
	echo "  echo -e -n '\033[?25l' >/dev/tty0" >>$@
	echo "fail()" >>$@
	echo "{" >>$@
	echo "  exec /bin/sh < /dev/console" >>$@
	echo "  exit 1" >>$@
	echo "}" >>$@
	echo "if [ \"\$$DEBUG\" != \"\" ] ; then V=-v ; fi" >>$@
	echo "" >>$@
	echo "echo \"Creating ramdisk \"" >>$@
	echo "/sbin/mke2fs -i 1024 /dev/ram1 8192" >>$@
	echo "mount -n -t ext2 -o rw,suid,dev,exec,async,nocheck /dev/ram1 /tmp" >>$@
	echo "chmod 1777 /tmp" >>$@
	echo "mkdir /tmp/curl" >>$@
	echo "mkdir /tmp/var" >>$@
	echo "mkdir /tmp/var/empty" >>$@
	echo "mkdir /tmp/var/lib" >>$@
	echo "mkdir /tmp/var/lib/nfs" >>$@
	echo "mkdir /tmp/var/local" >>$@
	echo "mkdir /tmp/var/lock" >>$@
	echo "mkdir /tmp/var/lock/subsys" >>$@
	echo "mkdir /tmp/var/log" >>$@
	echo "mkdir /tmp/var/run" >>$@
	echo "chmod 600 /tmp/var/empty" >>$@
	echo "echo \"\"" >>$@
	echo "echo \"==== : starting cardmgr ====\"" >>$@
	echo "echo \"\"" >>$@
	echo "cardmgr \$$V -q -o -c /etc/pcmcia -m /lib/modules/2.4.19-rmk7-pxa2 -s /tmp/stab -p /tmp/pid || fail" >>$@
	echo "echo \"\"" >>$@
	echo "" >>$@
	echo "network start all" >>$@
	echo "ifconfig lo 127.0.0.1 netmask 255.0.0.0" >>$@
	echo "mount /dev/pts" >>$@
	echo "/bin/sshd -f /etc/sshd_config" >>$@
	echo "if [ \"\$$DEBUG\" != \"\" ] ; then" >>$@
	echo "#/bin/sh < /dev/console" >>$@
	echo "fi" >>$@
	echo "/bin/jsMenu" >>$@
	chmod a+x $@

base-root: $(TARGETS)
