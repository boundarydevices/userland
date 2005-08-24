#
# mmcinitrd.mak
#
# This makefile creates a stub of a root file system
# that mounts /dev/mmcblk0 as /tmp/mmc (type vfat).
#
# It requires rootfs to be built prior to building
# (in particular, busybox, the etc/ directory and
# devices.txt)
#

MMCDIR=$(TOPDIR)/mmc.initrd
STARTSCRIPT=$(TOPDIR)/mmc.initrd/etc/init.d/rcS

include .config
include .kernelconfig
CROSS_LIB_LINK = $(subst //,/,$(MMCDIR)/$(CROSS_LIB_DIR))

$(MMCDIR):
	@echo "Building RAMDISK in $(MMCDIR)"
	@rm -rf $(MMCDIR)
	@mkdir -p $(MMCDIR)
	@mkdir -p $(MMCDIR)/bin
ifdef MODULES   
	make -C ~/cvs/linux-2.6.11.11 INSTALL_MOD_PATH=$(MMCDIR) modules_install
	cp ~/zd1211.cvs/src/modules-2.6.11.11/zd1211_mod.ko $(MMCDIR)   
endif   
	@cd $(MMCDIR) && ln -s bin sbin
	@cp $(ROOTDIR)/bin/busybox $(MMCDIR)/bin
	@echo "Hello\n"
	@cd $(MMCDIR) && ln -s bin/busybox linuxrc
	@find root/bin/ -type l -exec cp -rd {} mmc.initrd/bin/ \;
	@find root/sbin/ -type l -exec cp -rd {} mmc.initrd/sbin/ \;
	@mkdir -p $(MMCDIR)/etc
	@cp $(ROOTDIR)/etc/fstab $(MMCDIR)/etc
	@cp $(ROOTDIR)/etc/inittab $(MMCDIR)/etc
	@mkdir -p $(MMCDIR)/etc/init.d
	@cp $(ROOTDIR)/sbin/mke2fs $(MMCDIR)/bin
	@mkdir -p $(MMCDIR)/lib
	@cp -rvd $(ROOTDIR)/lib/ld-* $(MMCDIR)/lib
	@cp -rvd $(ROOTDIR)/lib/libc-* $(MMCDIR)/lib
	@cp -rvd $(ROOTDIR)/lib/libc.* $(MMCDIR)/lib
	@cp -rvd build/bdScript/serialTest $(MMCDIR)/bin
	@rm -f $(MMCDIR)/bin/wget
	@cp -rv build/bdScript/wget $(MMCDIR)/bin
	@mkdir -p $(MMCDIR)/proc
	@mkdir -p $(MMCDIR)/tmp
	@mkdir -p $(MMCDIR)/usr
	@mkdir -p $(MMCDIR)/usr/bin
	@mkdir -p $(MMCDIR)/usr/lib
	@mkdir -p $(MMCDIR)/var
	@mkdir -p $(CROSS_LIB_LINK)
	@cd $(CROSS_LIB_LINK) && ln -sf /lib
	@cd $(CROSS_LIB_LINK) && ln -sf /bin
	cd $(MMCDIR)/etc && /sbin/ldconfig -r ../ -v
	@touch $@

$(STARTSCRIPT): mmc.rcs
	cp -fv $? $@
	chmod a+x $@

$(STATEDIR)/mmcinitrd.built: $(MMCDIR) targetinstall $(STARTSCRIPT) rootfs devices
	touch $@
