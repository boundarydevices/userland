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
# Revision 1.36  2008-07-29 00:14:03  ericn
# only spawn /sbin/getty on ttyS0
#
# Revision 1.35  2008-07-25 04:50:48  ericn
# updated libstdc++, libpthread, libnss references
#
# Revision 1.34  2008-07-24 16:59:35  ericn
# deprecate libc-(version).so for libc.so.6
#
# Revision 1.33  2007-10-09 00:56:16  ericn
# -defer name of ld-linux file to rules/glibc.make (it's cross-compiler-specific)
#
# Revision 1.32  2007/07/27 21:49:42  ericn
# -.profile, not etc/bashrc. Include /usr/local/lib and /usr/local/bin
#
# Revision 1.31  2006/02/05 18:56:48  ericn
# -pull password handling here (from tinylogin)
#
# Revision 1.30  2006/09/21 23:44:42  ericn
# -add /proc/bus/usb to fstab
#
# Revision 1.29  2006/09/21 22:37:56  ericn
# -use GLIBC_VER instead of 2.3.5
#
# Revision 1.28  2006/08/17 15:48:21  ericn
# -fix glibc dependencies
#
# Revision 1.27  2006/08/17 12:55:33  ericn
# -move glibc rules into rules/glibc.mak
#
# Revision 1.26  2006/07/30 15:06:03  ericn
# -more fixes for nss libs
#
# Revision 1.25  2006/07/29 21:39:37  ericn
# -add libnsl.so (from glibc)
#
# Revision 1.24  2006/06/22 13:50:26  ericn
# -moved stock libraries from rules/glib
#
# Revision 1.23  2005/12/28 00:32:05  ericn
# -fix line ends
#
# Revision 1.22  2005/12/17 18:34:59  ericn
# -use ROOTDIR symbol, move glib library targets to rules/glib.make
#
# Revision 1.21  2005/12/10 14:28:04  ericn
# -fix kernel path for modules_install, ordering of libstdc++
#
# Revision 1.20  2005/11/26 16:19:27  ericn
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
include rules/glibc.make

CROSSSTRIP := $(CONFIG_GNU_TARGET)-strip
CROSS_PATH := $(CONFIG_TOOLCHAINPATH)/bin:$$PATH

DIRS := $(ROOTDIR)/bin $(ROOTDIR)/etc $(ROOTDIR)/lib $(ROOTDIR)/proc $(ROOTDIR)/sysfs $(ROOTDIR)/tmp $(ROOTDIR)/tmp/mmc

TARGETS := $(ROOTDIR)/.profile \
           $(ROOTDIR)/etc/fstab \
           $(ROOTDIR)/etc/group \
           $(ROOTDIR)/etc/hosts \
           $(ROOTDIR)/etc/inittab \
           $(ROOTDIR)/etc/modules.conf \
           $(ROOTDIR)/etc/nsswitch.conf \
           $(ROOTDIR)/etc/passwd \
           $(ROOTDIR)/etc/resolv.conf \
           $(ROOTDIR)/etc/ld.so.conf \
           $(ROOTDIR)/etc/ld.so.cache \
           $(ROOTDIR)/bin/jsMenu \
           $(ROOTDIR)/etc/init.d/rcS \
           $(ROOTDIR)/lib/libc.so.6 \
           $(ROOTDIR)/lib/libgcc_s.so.1 \
           $(ROOTDIR)/lib/libstdc++.so \
           $(ROOTDIR)/lib/libstdc++.so.6 \
           $(ROOTDIR)/lib/libstdc++.so.6.0.8 \
           $(ROOTDIR)/lib/libutil-$(GLIBC_VER).so \
           $(ROOTDIR)/lib/libutil.so.1 \
           $(ROOTDIR)/lib/libnsl.so.1 \
           $(ROOTDIR)/lib/libnss_dns-$(GLIBC_VER).so \
           $(ROOTDIR)/lib/libnss_dns.so.2 \
           $(ROOTDIR)/lib/libnss_files-$(GLIBC_VER).so \
           $(ROOTDIR)/lib/libnss_files.so.2 \
           $(ROOTDIR)/lib/libcrypt-$(GLIBC_VER).so \
           $(ROOTDIR)/lib/libcrypt.so.1 \
           $(ROOTDIR)/lib/libm-$(GLIBC_VER).so \
           $(ROOTDIR)/lib/libm.so.6 \
           $(ROOTDIR)/lib/libpthread-$(GLIBC_VER).so \
           $(ROOTDIR)/lib/libpthread.so.0 \
           $(ROOTDIR)/lib/ld-$(GLIBC_VER).so \
           $(ROOTDIR)/lib/$(LD_LINUX) \
           $(ROOTDIR)/lib/libdl.so.2 \
           $(ROOTDIR)/lib/libdl-$(GLIBC_VER).so \
           $(ROOTDIR)/lib/modules \
           $(ROOTDIR)/linuxrc \
           $(ROOTDIR)/proc \
           $(ROOTDIR)/sysfs \
           $(ROOTDIR)/tmp \
           $(ROOTDIR)/tmp/mmc \
           $(ROOTDIR)/var
ifdef BUSYBOX_UDHCPC
TARGETS += $(ROOTDIR)/usr/share/udhcpc/default.script
endif

CROSS_LIB_LINK = $(subst //,/,$(ROOTDIR)/$(CROSS_LIB_DIR))

$(DIRS):
	mkdir -p $@

$(ROOTDIR)/lib/modules:
	PATH=$(CROSS_PATH) make -C $(CONFIG_KERNELPATH) INSTALL_MOD_PATH=$(ROOTDIR) ARCH=arm CROSS_COMPILE=$(CONFIG_CROSSPREFIX)- modules_install

$(CROSS_LIB_LINK)/lib:
	mkdir -p $(CROSS_LIB_LINK)
	cd $(CROSS_LIB_LINK) && ln -sf /lib

$(CROSS_LIB_LINK)/etc:
	mkdir -p $(CROSS_LIB_LINK)
	cd $(CROSS_LIB_LINK) && ln -sf /etc

$(ROOTDIR)/.profile:  $(ROOTDIR)
	echo "#!/bin/sh" > $@
	echo "# CURLTMPSIZE should be smaller than sizeof ramdisk from " >> $@
	echo "# mke2fs call by size of the largest file to be downloaded" >> $@
	echo "export CURLTMPSIZE=4000000" >> $@
	echo "export LD_LIBRARY_PATH=/mmc:/lib:/usr/lib:/usr/local/lib" >> $@
	echo "export PATH=/mmc:/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin" >> $@

$(ROOTDIR)/etc/hosts: /etc/hosts
	cp -f $< $@ 

$(ROOTDIR)/etc/inittab: $(ROOTDIR)/etc
	echo "::sysinit:/etc/init.d/rcS" > $@
	echo "#tty1::askfirst:-/sbin/getty 115200 /dev/ttyS1" >> $@
	echo "#tty2::askfirst:-/sbin/getty 115200 /dev/ttyS2" >> $@
	echo "::respawn:/sbin/getty 115200 /dev/ttyS0" >> $@
	echo "::ctrlaltdel:/sbin/reboot" >> $@
	echo "::shutdown:/sbin/swapoff -a" >> $@
	echo "::shutdown:/bin/umount -a -r" >> $@
	echo "::restart:/sbin/init" >> $@
	chmod a+x $@

$(ROOTDIR)/etc/modules.conf: $(ROOTDIR)/etc
	echo "alias wlan0 prism2_cs" > $@

$(ROOTDIR)/etc/nsswitch.conf: $(ROOTDIR)/etc
	echo "hosts:      files dns" > $@
	echo "passwd:     files" >> $@
	echo "group:      files" >> $@

$(ROOTDIR)/etc/resolv.conf: $(ROOTDIR)/etc
	echo "# name servers go here" >$@

CRYPT_SALT = dP
PASSWORD_STRING = $(shell perl -e 'print crypt($(CONFIG_ROOTPASSWORD), "$(CRYPT_SALT)"),"\n"')

$(ROOTDIR)/etc/passwd: $(ROOTDIR)/etc
	@echo "root:$(PASSWORD_STRING):0:0:Linux User,,,:/:/bin/sh" > $@
ifdef CONFIG_OPENSSH
	@echo "sshd:x:1:1:sshd:/:/bin/false" >> $(ROOTDIR)/etc/passwd
endif

$(ROOTDIR)/etc/group: $(ROOTDIR)/etc
	@echo "0:x:0:root" > $@
ifdef CONFIG_OPENSSH
	@echo "1:x:1:sshd" >> $@
endif

$(ROOTDIR)/etc/ld.so.conf: $(ROOTDIR)/etc
	echo -e "" > $@

$(ROOTDIR)/linuxrc: $(ROOTDIR)/bin/busybox
	cd $(ROOTDIR) && ln -s ./bin/busybox linuxrc

$(ROOTDIR)/etc/ld.so.cache: $(ROOTDIR)/etc $(ROOTDIR)/etc/modules.conf $(ROOTDIR)/etc/ld.so.conf
	mkdir -p $(ROOTDIR)/lib
	mkdir -p $(ROOTDIR)/usr/lib
	cd $(ROOTDIR)/etc && /sbin/ldconfig -r ../ -v

$(ROOTDIR)/etc/fstab: $(ROOTDIR)/etc
ifdef KERNEL_DEVPTS_FS
	echo "none /dev/pts devpts gid=5,mode=0620 0 0" > $@
endif  
ifdef KERNEL_USB_DEVICEFS
	echo "none /proc/bus/usb usbdevfs noauto 0 0" >>$@
endif
ifdef KERNEL_MMC
	echo "none /tmp/mmc vfat gid=5,mode=0620 0 0" >> $@
endif   
	touch $@

ifdef BUSYBOX_UDHCPC
$(ROOTDIR)/usr/share/udhcpc/default.script: $(BUSYBOX_DIR)/examples/udhcp/sample.script
	mkdir -p $(ROOTDIR)/usr/share/udhcpc
	cp -fv $? $@ && chmod a+x $@
	cp -fv $(BUSYBOX_DIR)/examples/udhcp/sample.bound $(ROOTDIR)/usr/share/udhcpc/
	cp -fv $(BUSYBOX_DIR)/examples/udhcp/sample.deconfig $(ROOTDIR)/usr/share/udhcpc/
	cp -fv $(BUSYBOX_DIR)/examples/udhcp/sample.renew $(ROOTDIR)/usr/share/udhcpc/
	cp -fv $(BUSYBOX_DIR)/examples/udhcp/sample.nak $(ROOTDIR)/usr/share/udhcpc/
endif

#
# Javascript startup menu
#
$(ROOTDIR)/bin/jsMenu: 
	echo "#!/bin/sh" >$@
	echo "rm -f /tmp/ctrlc" >>$@
	echo "while ! [ -f /tmp/ctrlc ] ; do /bin/jsExec file:///js/mainMenu.js; done" >>$@
	chmod a+x $@

#
# startup script
#
$(ROOTDIR)/etc/init.d: $(ROOTDIR)/etc
	mkdir -p $@

$(ROOTDIR)/etc/init.d/rcS: $(ROOTDIR)/bin/jsMenu $(ROOTDIR)/etc/init.d
	echo "#!/bin/sh" >$@
ifdef KERNEL_PROC_FS   
	echo "mount -t proc /proc /proc" >>$@
endif   
ifdef KERNEL_USB_DEVICEFS
	echo "mount -t usbfs none /proc/bus/usb" >>$@
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

$(ROOTDIR)/var:
	ln -s -f /tmp/var $@

base-root: $(DIRS) $(CROSS_LIB_LINK)/etc $(CROSS_LIB_LINK)/lib $(TARGETS)

