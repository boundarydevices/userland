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

$(MMCDIR): $(STATEDIR)/initrd.built
	@echo "Copying RAMDISK to $(MMCDIR)"
	@rm -rf $(MMCDIR)
	@mkdir -p $(MMCDIR)
	@cp -rfv $(INITRD_DIR)/* $(MMCDIR)
	@rm -f $(STARTSCRIPT)
	@mkdir -p $(MMCDIR)/usr/sbin

ifeq (m,$(KERNEL_ZD1211RW))
   ZD1211MODPROBE = echo "modprobe zd1211rw" >> $(STARTSCRIPT)
else
   ZD1211MODPROBE = 
endif

$(STARTSCRIPT): $(MMCDIR) $(TOPDIR)/mmc.rcs $(MMCDIR)/bin/netstart 
	mkdir -p $(MMCDIR)/etc/init.d
	cp -fv $(TOPDIR)/mmc.rcs $@
	$(ZD1211MODPROBE)
	echo netstart >> $@
	chmod a+x $@

$(MMCDIR)/bin/netstart: $(MMCDIR) $(TOPDIR)/netstart
	cp -fv $(TOPDIR)/netstart $@
	chmod a+x $@

$(STATEDIR)/mmcinitrd.built: $(MMCDIR) targetinstall $(STARTSCRIPT) rootfs devices
	touch $@
