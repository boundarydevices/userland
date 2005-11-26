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
# Revision 1.20  2005-11-26 16:19:27  ericn
# -create ttyFB0
#
# Revision 1.19  2005/11/22 02:19:24  ericn
# -don't need root privilege to copy libpthread
#
# Revision 1.18  2005/11/07 01:02:24  ericn
# -install ld-2.3.5.so
#
# Revision 1.17  2005/08/24 03:29:50  ericn
# -include parsed Busybox config file, install udhcpc samples
#
# Revision 1.16  2005/08/21 18:31:14  ericn
# -mount /tmp/mmc, kernel 2.6 devs
#
# Revision 1.15  2005/07/23 16:31:41  ericn
# -add dns/nss libs
#
# Revision 1.14  2005/06/19 17:29:32  ericn
# -added packets
#
# Revision 1.13  2004/06/28 02:58:22  ericn
# -add USB device fs, devpts configs for fstab
#
# Revision 1.12  2004/06/26 13:57:52  ericn
# -fixed CROSSSTRIP
#
# Revision 1.11  2004/06/24 13:54:18  ericn
# -add /etc link (for ldconfig)
#
# Revision 1.10  2004/06/21 13:57:13  ericn
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
include .kernelconfig
include .bbconfig
include rules/busybox.make

CROSSSTRIP := $(CONFIG_GNU_TARGET)-strip
CROSS_PATH := $(CONFIG_TOOLCHAINPATH)/bin:$$PATH
ROOTTARGET := $(shell pwd)/root

DIRS := root/bin root/etc root/lib root/proc root/sysfs root/tmp root/tmp/mmc

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
           root/lib/libgcc_s.so.1 \
           root/lib/libstdc++.so \
           root/lib/libstdc++.so.6 \
           root/lib/libstdc++.so.6.0.3 \
           root/lib/libutil.so.1 \
           root/lib/libnsl.so.1 \
           root/lib/libnss_dns.so.2 \
           root/lib/libnss_files.so.2 \
           root/lib/libcrypt.so.1 \
           root/lib/libm.so.6 \
           root/lib/libpthread.so.0 \
           root/lib/ld-2.3.5.so \
           root/lib/libdl.so.2 \
           root/lib/ld-linux.so.2 \
           root/lib/modules \
           root/linuxrc \
           root/proc \
           root/sysfs \
           root/tmp \
           root/tmp/mmc \
           root/var
ifdef BUSYBOX_UDHCPC
TARGETS += root/usr/share/udhcpc/default.script
endif

CROSS_LIB_LINK = $(subst //,/,root/$(CROSS_LIB_DIR))

$(DIRS):
	mkdir -p $@

root/lib/modules:
	make -C ~/cvs/linux-2.6.11.11 INSTALL_MOD_PATH=$(ROOTTARGET) modules_install

$(CROSS_LIB_LINK)/lib:
	mkdir -p $(CROSS_LIB_LINK)
	cd $(CROSS_LIB_LINK) && ln -sf /lib

$(CROSS_LIB_LINK)/etc:
	mkdir -p $(CROSS_LIB_LINK)
	cd $(CROSS_LIB_LINK) && ln -sf /etc

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

root/lib/libgcc_s.so.1 \
root/lib/libstdc++.so \
root/lib/libstdc++.so.6 \
root/lib/libstdc++.so.6.0.3:
	cp -d $(CROSS_LIB_DIR)/lib/$(shell basename $@) $@ && chmod a+rw $@

root/lib/libutil.so.1: $(CROSS_LIB_DIR)/lib/libutil.so.1
	cp $< $@
	PATH=$(CROSS_PATH) $(CROSSSTRIP) $@

root/lib/libnsl.so.1: $(CROSS_LIB_DIR)/lib/libnsl.so.1
	cp $< $@
	PATH=$(CROSS_PATH) $(CROSSSTRIP) $@

root/lib/libnss_dns.so.2: $(CROSS_LIB_DIR)/lib/libnss_dns.so.2
	cp $< $@
	PATH=$(CROSS_PATH) $(CROSSSTRIP) $@

root/lib/libnss_files.so.2: $(CROSS_LIB_DIR)/lib/libnss_files.so.2
	cp $< $@
	PATH=$(CROSS_PATH) $(CROSSSTRIP) $@

root/lib/libcrypt.so.1: $(CROSS_LIB_DIR)/lib/libcrypt.so.1
	cp $< $@
	PATH=$(CROSS_PATH) $(CROSSSTRIP) $@

root/lib/libm.so.6: $(CROSS_LIB_DIR)/lib/libm.so.6
	cp -d $(CROSS_LIB_DIR)/lib/libm.so* root/lib/
	cp -d $(CROSS_LIB_DIR)/lib/libm-*.so* root/lib/
	PATH=$(CROSS_PATH) $(CROSSSTRIP) root/lib/libm-2.2.3.so

root/lib/libpthread.so.0: $(CROSS_LIB_DIR)/lib/libpthread.so.0
	cp -d $(CROSS_LIB_DIR)/lib/libpthread-0.10.so root/lib/ && chmod a+rw root/lib/libpthread-0.10.so
	cp -d $(CROSS_LIB_DIR)/lib/libpthread.so.0 root/lib/ && chmod a+rw root/lib/libpthread.so.0
	PATH=$(CROSS_PATH) $(CROSSSTRIP) root/lib/libpthread-*.so

root/lib/ld-2.3.5.so: $(CROSS_LIB_DIR)/lib/ld-2.3.5.so
	cp -f $< $@

root/lib/ld-linux.so.2: root/lib/ld-2.3.5.so
	cd root/lib/ && ln -s ld-2.3.5.so ld-linux.so.2

root/lib/libdl.so.2: $(CROSS_LIB_DIR)/lib/libdl.so.2
	cp -f $< $@

root/linuxrc: root/bin/busybox
	cd root && ln -s ./bin/busybox linuxrc

root/etc/ld.so.cache: root/etc/modules.conf root/etc/ld.so.conf
	mkdir -p root/lib
	mkdir -p root/usr/lib
	cd root/etc && /sbin/ldconfig -r ../ -v

root/etc/fstab:
ifdef KERNEL_DEVPTS_FS
	echo "none /dev/pts devpts gid=5,mode=0620 0 0" > $@
endif   
ifdef KERNEL_USB_DEVICEFS
	echo "none /proc/bus/usb usbdevfs noauto 0 0" >>$@
endif
ifdef KERNEL_MMC
	echo "none /tmp/mmc vfat gid=5,mode=0620 0 0" > $@
endif   
	touch $@

ifdef BUSYBOX_UDHCPC
root/usr/share/udhcpc/default.script: $(BUSYBOX_DIR)/examples/udhcp/sample.script
	mkdir -p root/usr/share/udhcpc
	cp -fv $? $@ && chmod a+x $@
	cp -fv $(BUSYBOX_DIR)/examples/udhcp/sample.bound root/usr/share/udhcpc/
	cp -fv $(BUSYBOX_DIR)/examples/udhcp/sample.deconfig root/usr/share/udhcpc/
	cp -fv $(BUSYBOX_DIR)/examples/udhcp/sample.renew root/usr/share/udhcpc/
	cp -fv $(BUSYBOX_DIR)/examples/udhcp/sample.nak root/usr/share/udhcpc/
endif

#
# Javascript startup menu
#
root/bin/jsMenu: 
	echo "#!/bin/sh" >$@
	echo "rm -f /tmp/ctrlc" >>$@
	echo "while ! [ -f /tmp/ctrlc ] ; do /bin/jsExec file:///js/mainMenu.js; done" >>$@
	chmod a+x $@

#
# startup script
#
root/etc/init.d:
	mkdir -p $@

root/etc/init.d/rcS: root/bin/jsMenu root/etc/init.d
	echo "#!/bin/sh" >$@
ifdef KERNEL_PROC_FS   
	echo "mount -t proc /proc /proc" >>$@
endif   
ifdef KERNEL_SYSFS   
	echo "mount -t sysfs /sysfs /sysfs" >>$@
endif   
ifdef KERNEL_DEVFS_FS
	echo "ln -sfn /dev/fb/0 /dev/fb0" >>$@
endif
	echo "echo -e -n '\033[?25l' >/dev/ttyFB0" >>$@
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
	echo "mkdir /tmp/mmc" >>$@
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
ifdef KERNEL_PCMCIA_PXA
	echo "echo \"\"" >>$@
	echo "echo \"==== : starting cardmgr ====\"" >>$@
	echo "echo \"\"" >>$@
	echo "cardmgr \$$V -q -o -c /etc/pcmcia -m /lib/modules/2.4.19-rmk7-pxa2 -s /tmp/stab -p /tmp/pid || fail" >> $@
endif
	echo "echo \"\"" >>$@
	echo "" >>$@
	echo "mount -t vfat  /dev/mmc/blk0/part1 /tmp/mmc" >>$@
	echo "network start all" >>$@
	echo "ifconfig lo 127.0.0.1 netmask 255.0.0.0" >>$@
	echo "mount /dev/pts" >>$@
	echo "/bin/sshd -f /etc/sshd_config" >>$@
	echo "if [ \"\$$DEBUG\" != \"\" ] ; then" >>$@
	echo "#/bin/sh < /dev/console" >>$@
	echo "fi" >>$@
	echo "/bin/jsMenu" >>$@
	chmod a+x $@

root/var:
	ln -s -f /tmp/var $@

base-root: $(DIRS) $(CROSS_LIB_LINK)/etc $(CROSS_LIB_LINK)/lib $(TARGETS)

