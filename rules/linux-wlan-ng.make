# -*-makefile-*-
# $Id: linux-wlan-ng.make,v 1.1 2004-05-31 19:45:32 ericn Exp $
#
# Copyright (C) 2003 by Boundary Devices
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef CONFIG_LINUX_WLAN_NG
PACKAGES += linux-wlan-ng
endif

#
# Paths and names
#
LINUX-WLAN-NG_VERSION	= 0.1.16-pre8
LINUX-WLAN-NG		= linux-wlan-ng-$(LINUX-WLAN-NG_VERSION)
LINUX-WLAN-NG_SUFFIX		= tar.gz
LINUX-WLAN-NG_URL		= ftp://ftp.linux-wlan.org/pub/linux-wlan-ng/older/$(LINUX-WLAN-NG).$(LINUX-WLAN-NG_SUFFIX)
LINUX-WLAN-NG_SOURCE		= $(CONFIG_ARCHIVEPATH)/$(LINUX-WLAN-NG).$(LINUX-WLAN-NG_SUFFIX)
LINUX-WLAN-NG_DIR		= $(BUILDDIR)/$(LINUX-WLAN-NG)

LINUX-WLAN-NG_PATCH_URL		= http://boundarydevices.com/$(LINUX-WLAN-NG).diff
LINUX-WLAN-NG_PATCH		= $(CONFIG_ARCHIVEPATH)/$(LINUX-WLAN-NG).diff

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

linux-wlan-ng_get: $(STATEDIR)/linux-wlan-ng.get

linux-wlan-ng_get_deps = $(LINUX-WLAN-NG_SOURCE) $(LINUX-WLAN-NG_PATCH)

$(STATEDIR)/linux-wlan-ng.get: $(linux-wlan-ng_get_deps)
	@$(call targetinfo, $@)
	touch $@

$(LINUX-WLAN-NG_PATCH):
	@$(call targetinfo, $@)
	cd $(CONFIG_ARCHIVEPATH) && wget $(LINUX-WLAN-NG_PATCH_URL)

$(LINUX-WLAN-NG_SOURCE):
	@$(call targetinfo, $@)
	cd $(CONFIG_ARCHIVEPATH) && wget $(LINUX-WLAN-NG_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

linux-wlan-ng_extract: $(STATEDIR)/linux-wlan-ng.extract

linux-wlan-ng_extract_deps = $(STATEDIR)/linux-wlan-ng.get
linux-wlan-ng_extract_deps = $(STATEDIR)/pcmcia-cs.prepare

$(STATEDIR)/linux-wlan-ng.extract: $(linux-wlan-ng_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LINUX-WLAN-NG_DIR))
	cd $(BUILDDIR) && gzcat $(LINUX-WLAN-NG_SOURCE) | tar -xvf -
	cd $(BUILDDIR) && patch -p0 <$(LINUX-WLAN-NG_PATCH)
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

linux-wlan-ng_prepare: $(STATEDIR)/linux-wlan-ng.prepare

#
# dependencies
#
linux-wlan-ng_prepare_deps = \
	$(STATEDIR)/linux-wlan-ng.extract \
   $(STATEDIR)/pcmcia-cs.install 

LINUX-WLAN-NG_PATH	= PATH=$(CROSS_PATH)
LINUX-WLAN-NG_ENV 	= $(CROSS_ENV)
#LINUX-WLAN-NG_ENV	  += PCMCIAPATH=$(PCMCIA-CS_DIR)

#
# autoconf
#
LINUX-WLAN-NG_AUTOCONF = 

$(STATEDIR)/linux-wlan-ng.prepare: $(linux-wlan-ng_prepare_deps)
	@$(call targetinfo, $@)
	cd $(LINUX-WLAN-NG_DIR) && \
	echo "kernel dir = $(KERNEL_DIR)"
	echo "root dir = $(ROOTDIR)"
	echo "kernel ver = $(KERNEL_VERSION)"
	echo "pcmcia dir = $(PCMCIA-CS_DIR)"
	echo "host_cc = $(HOSTCC)"
	cd $(LINUX-WLAN-NG_DIR) && \
	echo -e 'y\nn\nn\nn\n$(CONFIG_KERNELPATH)\n$(ROOTDIR)\n/etc/pcmcia\n/lib/modules/2.4.19-rmk7-pxa2\n\nn\n' \
		>configresponse
#	sed 's/CC/HOST_CC/g' $(LINUX-WLAN-NG_DIR)/scripts/Makefile >$(LINUX-WLAN-NG_DIR)/scripts/Makefile.patched
#	mv $(LINUX-WLAN-NG_DIR)/scripts/Makefile $(LINUX-WLAN-NG_DIR)/scripts/Makefile.orig
#	mv $(LINUX-WLAN-NG_DIR)/scripts/Makefile.patched $(LINUX-WLAN-NG_DIR)/scripts/Makefile
	cd $(LINUX-WLAN-NG_DIR) && \
	$(LINUX-WLAN-NG_PATH) \
	$(LINUX-WLAN-NG_ENV) \
   KERNEL_SOURCE=$(KERNEL_DIR) \
	CC=gcc \
	./Configure \
	--arch=$(CONFIG_ARCH)  \
	--kcc=$(CONFIG_GNU_TARGET)-gcc \
	--ucc=$(CONFIG_GNU_TARGET)-gcc \
	--ld=$(CONFIG_GNU_TARGET)-ld \
	--kernel=$(KERNEL_DIR) \
	--target=$(CONFIG_PREFIX) \
	--notrust --nocardbus \
	--sysv \
	--srctree \
	--rcdir=/etc/rc.d <configresponse || exit 1      
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

linux-wlan-ng_compile: $(STATEDIR)/linux-wlan-ng.compile

linux-wlan-ng_compile_deps = $(STATEDIR)/linux-wlan-ng.prepare

$(STATEDIR)/linux-wlan-ng.compile: $(linux-wlan-ng_compile_deps)
	@$(call targetinfo, $@)
	$(LINUX-WLAN-NG_PATH) \
   $(LINUX-WLAN-NG_ENV) \
   make -C $(LINUX-WLAN-NG_DIR) all
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

linux-wlan-ng_install: $(STATEDIR)/linux-wlan-ng.install

$(STATEDIR)/linux-wlan-ng.install: $(STATEDIR)/linux-wlan-ng.compile
	@$(call targetinfo, $@)
	$(LINUX-WLAN-NG_PATH) make -C $(LINUX-WLAN-NG_DIR)/src install
	@mkdir -p $(CROSS_LIB_DIR)/include/wlan
	@cp -f -R $(LINUX-WLAN-NG_DIR)/src/include/wlan/* $(CROSS_LIB_DIR)/include/wlan
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

linux-wlan-ng_targetinstall: $(STATEDIR)/linux-wlan-ng.targetinstall

linux-wlan-ng_targetinstall_deps = $(STATEDIR)/linux-wlan-ng.compile

$(STATEDIR)/linux-wlan-ng.targetinstall: $(linux-wlan-ng_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

linux-wlan-ng_clean:
	rm -rf $(STATEDIR)/linux-wlan-ng.*
	rm -rf $(LINUX-WLAN-NG_DIR)

# vim: syntax=make
