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
# Revision 1.10  2004-06-21 13:57:13  ericn
# -Added path to toolchain for strip commands
#
# Revision 1.9  2004/06/20 19:28:59  ericn
# -fixed strip
#
# Revision 1.8  2004/06/20 15:18:52  ericn
# -fixed ld-xyz and libdl-xyz (I'm dyslexic, I guess)
#
# Revision 1.7  2004/06/19 23:30:35  ericn
# -added fstab
#
# Revision 1.6  2004/06/18 14:44:51  ericn
# -make libc/libdl happy
#
# Revision 1.5  2004/06/18 14:00:53  ericn
# -remove symlink to ld-2.2.3.so
#
# Revision 1.4  2004/06/18 04:16:27  ericn
# -build sub-dirs
#
# Revision 1.3  2004/06/09 03:55:37  ericn
# -added root/proc, root/tmp, and libpthread
#
# Revision 1.2  2004/06/06 17:56:14  ericn
# -updates
#
# Revision 1.1  2004/06/06 14:58:14  ericn
# -Initial import, 1st pass
#
#
#
.PHONY base-root:

all: base-root

include .config

CROSSSTRIP := $(CONFIG_GNU_TARGET)-strip
CROSS_PATH := $(CONFIG_TOOLCHAINPATH)/bin:$$PATH

DIRS := root/bin root/etc root/lib root/proc root/tmp 

TARGETS := root/etc/bashrc \
           root/etc/fstab \
           root/etc/hosts \
           root/etc/inittab \
           root/etc/modules.conf \
           root/etc/nsswitch.conf \
           root/etc/resolv.conf \
           root/etc/ld.so.conf \
           root/etc/ld.so.cache \
           root/bin/jsMenu \
           root/etc/init.d/rcS \
           root/lib/libc.so.6 \
           root/lib/libm.so.6 \
           root/lib/libpthread.so \
           root/lib/ld-2.2.3.so \
           root/lib/libdl.so.2 \
           root/lib/ld-linux.so.2 \
           root/linuxrc \
           root/proc \
           root/tmp 

CROSS_LIB_LINK = $(subst //,/,root/$(CROSS_LIB_DIR))

$(DIRS):
	mkdir -p $@

$(CROSS_LIB_LINK)/lib:
	mkdir -p $(CROSS_LIB_LINK)
	cd $(CROSS_LIB_LINK) && ln -s /lib

root/etc/bashrc:
	echo "#!/bin/sh" > $@
	echo "# CURLTMPSIZE should be smaller than sizeof ramdisk from " >> $@
	echo "# mke2fs call by size of the largest file to be downloaded" >> $@
	echo "export CURLTMPSIZE=4000000" >> $@
	echo "export LD_LIBRARY_PATH=/lib:/usr/lib" >> $@

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

root/lib/libc.so.6: $(CROSS_LIB_DIR)/lib/libc.so.6
	cp -d $(CROSS_LIB_DIR)/lib/libc-*.so* root/lib/
	cp -d $(CROSS_LIB_DIR)/lib/libc.so.6 root/lib/

root/lib/libm.so.6: $(CROSS_LIB_DIR)/lib/libm.so.6
	cp -d $(CROSS_LIB_DIR)/lib/libm.so* root/lib/
	cp -d $(CROSS_LIB_DIR)/lib/libm-*.so* root/lib/
	$(CROSS_PATH) $(CROSSSTRIP) root/lib/libm-2.2.3.so

root/lib/libpthread.so: $(CROSS_LIB_DIR)/lib/libpthread.so
	cp -d $(CROSS_LIB_DIR)/lib/libpthr*.so* root/lib/
	$(CROSS_PATH) $(CROSSSTRIP) root/lib/libpthread-*.so

root/lib/ld-2.2.3.so: $(CROSS_LIB_DIR)/lib/ld-2.2.3.so
	cp -f $< $@

root/lib/ld-linux.so.2: root/lib/ld-2.2.3.so
	cd root/lib/ && ln -s ld-2.2.3.so ld-linux.so.2

root/lib/libdl.so.2: $(CROSS_LIB_DIR)/lib/libdl.so.2
	cp -f $< $@

root/linuxrc: root/bin/busybox
	cd root && ln -s ./bin/busybox linuxrc

root/etc/ld.so.cache: root/etc/modules.conf root/etc/ld.so.conf
	mkdir -p root/lib
	mkdir -p root/usr/lib
	cd root/etc && /sbin/ldconfig -r ../ -v

root/etc/fstab:
	echo "none /dev/pts devpts gid=5,mode=0620 0 0" > $@
	echo "none /proc/bus/usb usbdevfs noauto 0 0" >>$@

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

base-root: $(DIRS) $(CROSS_LIB_LINK)/lib $(TARGETS)

