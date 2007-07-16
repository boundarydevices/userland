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

ifeq (y,$(KERNEL_MODULES))
        MODULES_INSTALL=make -C $(CONFIG_KERNELPATH) INSTALL_MOD_PATH=$(INITRD_DIR) modules_install
else
        MODULES_INSTALL=echo "---------------- modules not configured\n"
endif
 
$(INITRD_DIR):
	@echo "Building RAMDISK in $(INITRD_DIR)"
	@rm -rf $(INITRD_DIR)
	@mkdir -p $(INITRD_DIR)/bin
	@mkdir -p $(INITRD_DIR)/lib
	$(MODULES_INSTALL)
	echo "CROSS_LIB_DIR == " $(CROSS_LIB_DIR)
	echo "ROOTDIR == " $(ROOTDIR)
	@cd $(INITRD_DIR) && ln -s bin sbin
	@cp $(ROOTDIR)/bin/busybox $(INITRD_DIR)/bin
	@echo "Hello\n"
	@cd $(INITRD_DIR) && ln -s bin/busybox linuxrc
	@find $(ROOTDIR)/bin/ -type l -exec cp -rd {} $(INITRD_DIR)/bin/ \;
	@find $(ROOTDIR)/sbin/ -type l -exec cp -rd {} $(INITRD_DIR)/sbin/ \;
	@mkdir -p $(INITRD_DIR)/etc
	@cp $(ROOTDIR)/etc/passwd $(INITRD_DIR)/etc
	@cp $(ROOTDIR)/etc/group $(INITRD_DIR)/etc
	@cp $(ROOTDIR)/etc/fstab $(INITRD_DIR)/etc
	@cp $(ROOTDIR)/etc/inittab $(INITRD_DIR)/etc
	@mkdir -p $(INITRD_DIR)/etc/init.d
	@mkdir -p $(INITRD_DIR)/lib
	@cp -rvd $(CROSS_LIB_DIR)/lib/ld-* $(INITRD_DIR)/lib
	@cp -rvd $(CROSS_LIB_DIR)/lib/libc-* $(INITRD_DIR)/lib
	@cp -rvd $(CROSS_LIB_DIR)/lib/libc.so* $(INITRD_DIR)/lib
	@cp -rvd $(CROSS_LIB_DIR)/lib/libcrypt*.so* $(INITRD_DIR)/lib
	@cp -rvd $(CROSS_LIB_DIR)/lib/libgcc_s.so* $(INITRD_DIR)/lib
	@mkdir -p $(INITRD_DIR)/proc
	@mkdir -p $(INITRD_DIR)/tmp
	@mkdir -p $(INITRD_DIR)/usr
	@mkdir -p $(INITRD_DIR)/usr/bin
	@mkdir -p $(INITRD_DIR)/usr/lib
	@mkdir -p $(INITRD_DIR)/var
	@mkdir -p $(CROSS_LIB_LINK)
	@cd $(CROSS_LIB_LINK) && ln -sf /lib
	@cd $(CROSS_LIB_LINK) && ln -sf /bin
	mkdir $(INITRD_DIR)/lib64 && mkdir $(INITRD_DIR)/usr/lib64
	cd $(INITRD_DIR)/etc && /sbin/ldconfig -r ../ -v
	@touch $@

ifdef CONFIG_E2FSPROGS
$(INITRD_DIR)/sbin/mke2fs: $(INITRD_DIR)
	@cp $(ROOTDIR)/sbin/mke2fs $(INITRD_DIR)/bin

$(INITRD_DIR)/sbin/e2fsck: $(INITRD_DIR)
	@cp $(ROOTDIR)/sbin/e2fsck $(INITRD_DIR)/bin

   E2FSPROGS_INSTALLED =  $(INITRD_DIR)/sbin/mke2fs $(INITRD_DIR)/sbin/e2fsck
else
   E2FSPROGS_INSTALLED =   
endif

$(INITRD_DIR)/bin/busybox: $(ROOTDIR)/bin/busybox $(INITRD_DIR) targetinstall 
	cp -fv $(ROOTDIR)/bin/busybox $@

$(INITRD_DIR)/bin/flashVar: $(ROOTDIR)/bin/flashVar $(INITRD_DIR) targetinstall 
	cp -fv $(ROOTDIR)/bin/flashVar $@

$(INITRD_DIR)/bin/dhcp: $(TOPDIR)/dhcp $(INITRD_DIR)
	cp -fv $(TOPDIR)/dhcp $@

ifdef CONFIG_DOSFSTOOLS
$(INITRD_DIR)/bin/mkdosfs: $(INITRD_DIR)
	@cp $(ROOTDIR)/bin/mkdosfs $(INITRD_DIR)/bin

$(INITRD_DIR)/bin/dosfsck: $(INITRD_DIR) 
	@cp $(ROOTDIR)/bin/dosfsck $(INITRD_DIR)/bin

   DOSFSPROGS_INSTALLED =  $(INITRD_DIR)/bin/mkdosfs $(INITRD_DIR)/bin/dosfsck
else
   DOSFSPROGS_INSTALLED =   
endif

ifdef CONFIG_UDEV
$(INITRD_DIR)/sbin/udevstart: $(INITRD_DIR) $(ROOTDIR)/sbin/udevstart
	mkdir -p $(INITRD_DIR)/sbin
	cp -fv $(ROOTDIR)/sbin/udev* $(INITRD_DIR)/sbin/
$(INITRD_DIR)/etc/udev: $(ROOTDIR)/etc/udev
	mkdir -p $(INITRD_DIR)/etc/udev
	cp -rvf $(ROOTDIR)/etc/udev/* $(INITRD_DIR)/etc/udev/
	cp -f $(TOPDIR)/40-boundary.rules $(INITRD_DIR)/etc/udev/rules.d/
   UDEV_INSTALLED = $(INITRD_DIR)/sbin/udevstart $(INITRD_DIR)/etc/udev
else
   UDEV_INSTALLED = 
endif

ZD1211_FIRMWARE=$(shell ls $(CONFIG_ARCHIVEPATH)/zd1211-firmware1.3.tar.bz2)

$(ZD1211_FIRMWARE):
	cd $(CONFIG_ARCHIVEPATH) && wget http://easynews.dl.sourceforge.net/sourceforge/zd1211/zd1211-firmware1.3.tar.bz2

$(INITRD_DIR)/lib/firmware: $(ZD1211_FIRMWARE)
	mkdir -p $@
	cd $@ && tar jxvf $(ZD1211_FIRMWARE)
	cd $@ && mv zd1211-firmware zd1211

$(INITRD_DIR)/usr/local/lib/firmware:
	mkdir -p $@
$(INITRD_DIR)/lib/udev: 
	mkdir -p $@

$(INITRD_DIR)/lib/udev/firmware.sh: $(UDEV_DIR)/extras/firmware/firmware.sh 
	cp -fv $< $@

$(INITRD_DIR)/bin/wpa_supplicant: $(ROOTDIR)/bin/wpa_supplicant
	cp -fv $< $@

WPA_SUPPLICANT_INSTALLED=$(INITRD_DIR)/bin/wpa_supplicant

ifeq (m,$(KERNEL_ZD1211RW))
   UDEV_INSTALLED += $(INITRD_DIR)/lib/udev $(INITRD_DIR)/lib/udev/firmware.sh \
                     $(INITRD_DIR)/lib/firmware $(INITRD_DIR)/usr/local/lib/firmware \
                     $(WPA_SUPPLICANT_INSTALLED)
endif

ifeq (,$(findstring 2.6.19,$(CONFIG_KERNELPATH)))
        INITRCSFILE = initrd.rcs
else
        INITRCSFILE = initrd-2.6.19.rcs
endif

$(INITRD_START): $(INITRCSFILE) $(INITRD_DIR)
	mkdir -p $(INITRD_DIR)/etc/init.d
	cp -fv $< $@
	chmod a+x $@

$(STATEDIR)/initrd.built: $(INITRD_DIR) \
                          targetinstall \
                          $(INITRD_DIR)/bin/busybox \
                          $(INITRD_DIR)/bin/flashVar \
                          $(INITRD_DIR)/bin/dhcp \
                          $(INITRD_DIR)/lib/firmware \
                          $(INITRD_START) \
                          rootfs \
                          devices \
                          $(E2FSPROGS_INSTALLED) \
                          $(DOSFSPROGS_INSTALLED) \
                          $(UDEV_INSTALLED)
	touch $@
