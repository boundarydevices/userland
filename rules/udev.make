# -*-makefile-*-
# $Id: udev.make,v 1.1 2006-02-05 18:53:30 ericn Exp $
#
# Copyright (C) 2002 by Pengutronix e.K., Hildesheim, Germany
# See CREDITS for details about who has contributed to this project. 
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifeq (y, $(CONFIG_UDEV))
PACKAGES += udev
endif

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------
UDEV_VERSION:=105
UDEV_SOURCE:=$(CONFIG_ARCHIVEPATH)/udev-$(UDEV_VERSION).tar.bz2
UDEV_URL:=ftp://ftp.kernel.org/pub/linux/utils/kernel/hotplug/$(UDEV_SOURCE)
UDEV_DIR:=$(BUILDDIR)/udev-$(UDEV_VERSION)

udev_get: $(STATEDIR)/udev.get

$(STATEDIR)/udev.get: $(UDEV_SOURCE)
	@$(call targetinfo, $@)
	touch $@

$(UDEV_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(UDEV_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

udev_extract: $(STATEDIR)/udev.extract

$(STATEDIR)/udev.extract: $(STATEDIR)/udev.get
	@$(call targetinfo, $@)
	@$(call clean, $(udev_DIR))
	@cd $(BUILDDIR) && bzcat $(UDEV_SOURCE) | tar -xvf -
	touch $@


# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------
udev_prepare: $(STATEDIR)/udev.prepare

$(STATEDIR)/udev.prepare: $(STATEDIR)/udev.extract
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

udev_compile: $(STATEDIR)/udev.compile

# UDEV_ROOT is /dev so we can replace devfs, not /udev for experiments
UDEV_ROOT:=/dev

BR2_UDEV_CFLAGS:= -D_GNU_SOURCE $(CROSS_ENV_CFLAGS)
ifeq ($(BR2_LARGEFILE),)
BR2_UDEV_CFLAGS+=-U_FILE_OFFSET_BITS
endif

$(STATEDIR)/udev.compile: $(STATEDIR)/udev.prepare 
	@$(call targetinfo, $@)
	cd $(UDEV_DIR) && \
		make CROSS_COMPILE=$(CONFIG_GNU_TARGET)- $(CROSS_ENV_CC) LD=$(CONFIG_GNU_TARGET)-gcc \
		CFLAGS="$(BR2_UDEV_CFLAGS)" \
		USE_LOG=false USE_SELINUX=false \
		udevdir=$(UDEV_ROOT) V=1 -C $(UDEV_DIR) 
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

udev_install: $(STATEDIR)/udev.install

$(STATEDIR)/udev.install: $(STATEDIR)/udev.compile
	@$(call targetinfo, $@)
	-mkdir $(INSTALLPATH)/sys
	$(MAKE) CROSS_COMPILE=$(CONFIG_GNU_TARGET)- DESTDIR=$(INSTALLPATH) \
		udevdir=$(UDEV_ROOT) V=1 -C $(UDEV_DIR) install-bin
	cp -fv $(UDEV_DIR)/udevstart $(INSTALLPATH)/sbin/
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

udev_targetinstall: $(STATEDIR)/udev.targetinstall

$(STATEDIR)/udev.targetinstall: $(STATEDIR)/udev.install
	@$(call targetinfo, $@)
	-mkdir $(ROOTDIR)/sys
	$(MAKE) CROSS_COMPILE=$(CONFIG_GNU_TARGET)- DESTDIR=$(ROOTDIR) \
		udevdir=$(UDEV_ROOT) V=1 -C $(UDEV_DIR) install-bin install-config
	cp -fv $(UDEV_DIR)/udevstart $(ROOTDIR)/sbin/
	$(CROSSSTRIP) $(ROOTDIR)/sbin/udev*
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

udev_clean: 
	rm -rf $(STATEDIR)/udev.* $(UDEV_DIR)

