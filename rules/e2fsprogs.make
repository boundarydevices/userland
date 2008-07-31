# -*-makefile-*-
# $Id: e2fsprogs.make,v 1.6 2008-07-31 17:31:35 ericn Exp $
#
# Copyright (C) 2002, 2003 by Pengutronix e.K., Hildesheim, Germany
#
# See CREDITS for details about who has contributed to this project. 
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef CONFIG_E2FSPROGS
PACKAGES += e2fsprogs
endif

#
# Paths and names 
#
E2FSPROGS_VERSION		= 1.41.0
E2FSPROGS			= e2fsprogs-$(E2FSPROGS_VERSION)
E2FSPROGS_SUFFIX		= tar.gz
E2FSPROGS_URL			= http://easynews.dl.sourceforge.net/sourceforge/e2fsprogs/$(E2FSPROGS).$(E2FSPROGS_SUFFIX)
E2FSPROGS_SOURCE		= $(CONFIG_ARCHIVEPATH)/$(E2FSPROGS).$(E2FSPROGS_SUFFIX)
E2FSPROGS_DIR			= $(BUILDDIR)/$(E2FSPROGS)
E2FSPROGS_BUILD_DIR		= $(BUILDDIR)/$(E2FSPROGS)-build

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

e2fsprogs_get: $(STATEDIR)/e2fsprogs.get

$(STATEDIR)/e2fsprogs.get: $(E2FSPROGS_SOURCE)
	@$(call targetinfo, $@)
	touch $@

$(E2FSPROGS_SOURCE):
	@$(call targetinfo, $@)
	echo "retrieving $(E2FSPROGS_URL)"
	cd $(CONFIG_ARCHIVEPATH) && wget $(E2FSPROGS_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

e2fsprogs_extract: $(STATEDIR)/e2fsprogs.extract

$(STATEDIR)/e2fsprogs.extract: $(STATEDIR)/e2fsprogs.get
	@$(call targetinfo, $@)
	@$(call clean, $(E2FSPROGS_DIR))
	@cd $(BUILDDIR) && zcat $(E2FSPROGS_SOURCE) | tar -xvf -
	chmod a+rw $(E2FSPROGS_DIR)/po
	chmod a+rw $(E2FSPROGS_DIR)/po/*.po
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

e2fsprogs_prepare: $(STATEDIR)/e2fsprogs.prepare

E2FSPROGS_AUTOCONF	=  --prefix=/usr
E2FSPROGS_AUTOCONF	+= --enable-fsck
E2FSPROGS_AUTOCONF	+= --host=$(CONFIG_GNU_HOST)
E2FSPROGS_AUTOCONF	+= --with-cc=$(CONFIG_GNU_TARGET)-gcc
E2FSPROGS_AUTOCONF	+= --with-ccopts=-msoft-float
E2FSPROGS_AUTOCONF	+= --with-linker=$(CONFIG_GNU_TARGET)-ld
E2FSPROGS_PATH		=  PATH=$(CROSS_PATH)
E2FSPROGS_ENV		=  $(CROSS_ENV) 
E2FSPROGS_ENV		+= BUILD_CC=$(HOSTCC)

e2fsprogs_prepare_deps = \
	$(STATEDIR)/e2fsprogs.extract

$(STATEDIR)/e2fsprogs.prepare: $(e2fsprogs_prepare_deps)
	@$(call targetinfo, $@)
	mkdir -p $(E2FSPROGS_BUILD_DIR) && \
	cd $(E2FSPROGS_BUILD_DIR) && \
		$(E2FSPROGS_PATH) $(E2FSPROGS_ENV) \
		$(E2FSPROGS_DIR)/configure $(E2FSPROGS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

e2fsprogs_compile: $(STATEDIR)/e2fsprogs.compile

e2fsprogs_compile_deps = $(STATEDIR)/e2fsprogs.prepare

$(STATEDIR)/e2fsprogs.compile: $(e2fsprogs_compile_deps) 
	@$(call targetinfo, $@)
#
# in the util dir are tools that are compiled for the host system
# these tools are needed later in the compile progress
#
# it's not good to pass target CFLAGS to the host compiler :)
# so override these
#
	$(E2FSPROGS_PATH) make -C $(E2FSPROGS_BUILD_DIR)/util
	$(E2FSPROGS_PATH) make -C $(E2FSPROGS_BUILD_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

e2fsprogs_install: $(STATEDIR)/e2fsprogs.install

$(STATEDIR)/e2fsprogs.install:
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

e2fsprogs_targetinstall: $(STATEDIR)/e2fsprogs.targetinstall

$(STATEDIR)/e2fsprogs.targetinstall: $(STATEDIR)/e2fsprogs.compile
	@$(call targetinfo, $@)
	mkdir -p $(ROOTDIR)/sbin
ifdef CONFIG_E2FSPROGS_MKFS
	install $(E2FSPROGS_BUILD_DIR)/misc/mke2fs $(ROOTDIR)/sbin/mke2fs
	$(E2FSPROGS_PATH) $(CROSSSTRIP) -R .note -R .comment $(ROOTDIR)/sbin/mke2fs
endif
ifdef CONFIG_E2FSPROGS_E2FSCK
	install $(E2FSPROGS_BUILD_DIR)/e2fsck/e2fsck.shared $(ROOTDIR)/sbin/e2fsck
	$(E2FSPROGS_PATH) $(CROSSSTRIP) -R .note -R .comment $(ROOTDIR)/sbin/e2fsck
endif
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

e2fsprogs_clean: 
	rm -rf $(STATEDIR)/e2fsprogs.* $(E2FSPROGS_DIR) $(E2FSPROGS_BUILD_DIR)

# vim: syntax=make
