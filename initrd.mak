#
# initrd.mak
#
# This makefile creates a stub of a root file system
# for use when formatting SD cards and such other times
# when a full cramfs is just too much.
#
# It requires rootfs to be built prior to building
# (in particular, busybox, the etc/ directory and
# devices.txt)
#

INITRD_DIR=$(TOPDIR)/initrd
INITRD_START=$(TOPDIR)/initrd/etc/init.d/rcS

include .config
include .kernelconfig
CROSS_LIB_LINK = $(subst //,/,$(INITRD_DIR)/$(CROSS_LIB_DIR))

$(INITRD_DIR):
	@echo "Building RAMDISK in $(INITRD_DIR)"
	@rm -rf $(INITRD_DIR)
	@mkdir -p $(INITRD_DIR)/bin
	@mkdir -p $(INITRD_DIR)/lib
ifdef MODULES   
	make -C ~/cvs/linux-2.6.11.11 INSTALL_MOD_PATH=$(INITRD_DIR) modules_install
	cp ~/zd1211.cvs/src/modules-2.6.11.11/zd1211_mod.ko $(INITRD_DIR)   
endif   
	echo "CROSS_LIB_DIR == " $(CROSS_LIB_DIR)
	echo "ROOTDIR == " $(ROOTDIR)
	@cd $(INITRD_DIR) && ln -s bin sbin
	@cp $(ROOTDIR)/bin/busybox $(INITRD_DIR)/bin
	@echo "Hello\n"
	@cd $(INITRD_DIR) && ln -s bin/busybox linuxrc
	@find $(ROOTDIR)/bin/ -type l -exec cp -rd {} $(INITRD_DIR)/bin/ \;
	@find $(ROOTDIR)/sbin/ -type l -exec cp -rd {} $(INITRD_DIR)/sbin/ \;
	@mkdir -p $(INITRD_DIR)/etc
	@cp $(ROOTDIR)/etc/fstab $(INITRD_DIR)/etc
	@cp $(ROOTDIR)/etc/inittab $(INITRD_DIR)/etc
	@mkdir -p $(INITRD_DIR)/etc/init.d
	@cp $(ROOTDIR)/sbin/mke2fs $(INITRD_DIR)/bin
	@mkdir -p $(INITRD_DIR)/lib
	@cp -rvd $(CROSS_LIB_DIR)/lib/ld-* $(INITRD_DIR)/lib
	@cp -rvd $(CROSS_LIB_DIR)/lib/libc-* $(INITRD_DIR)/lib
	@cp -rvd $(CROSS_LIB_DIR)/lib/libc.so* $(INITRD_DIR)/lib
	@mkdir -p $(INITRD_DIR)/proc
	@mkdir -p $(INITRD_DIR)/tmp
	@mkdir -p $(INITRD_DIR)/usr
	@mkdir -p $(INITRD_DIR)/usr/bin
	@mkdir -p $(INITRD_DIR)/usr/lib
	@mkdir -p $(INITRD_DIR)/var
	@mkdir -p $(CROSS_LIB_LINK)
	@cd $(CROSS_LIB_LINK) && ln -sf /lib
	@cd $(CROSS_LIB_LINK) && ln -sf /bin
	cd $(INITRD_DIR)/etc && /sbin/ldconfig -r ../ -v
	@touch $@

$(INITRD_START): initrd.rcs
	mkdir -p $(INITRD_DIR)/etc/init.d
	cp -fv $? $@
	chmod a+x $@

$(STATEDIR)/initrd.built: $(INITRD_DIR) targetinstall $(INITRD_START) rootfs devices
	touch $@
