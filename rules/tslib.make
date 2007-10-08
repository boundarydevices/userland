# -*-makefile-*-
# $Id: tslib.make,v 1.3 2007-10-08 21:06:10 ericn Exp $
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
ifeq (y, $(CONFIG_TSLIB))
PACKAGES += tslib
endif

#
# Paths and names 
#
TSLIB		= tslib-1.0
TSLIB_URL 	= http://download.berlios.de/tslib/$(TSLIB).tar.bz2
TSLIB_SOURCE	= $(CONFIG_ARCHIVEPATH)/$(TSLIB).tar.bz2
TSLIB_DIR	= $(BUILDDIR)/$(TSLIB)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

tslib_get: $(STATEDIR)/tslib.get

$(STATEDIR)/tslib.get: $(TSLIB_SOURCE)
	@$(call targetinfo, $@)
	touch $@

$(TSLIB_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(TSLIB_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

tslib_extract: $(STATEDIR)/tslib.extract

$(STATEDIR)/tslib.extract: $(STATEDIR)/tslib.get
	@$(call targetinfo, $@)
	@$(call clean, $(TSLIB_DIR))
	@cd $(BUILDDIR) && bzcat $(TSLIB_SOURCE) | tar -xvf -
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

tslib_prepare: $(STATEDIR)/tslib.prepare

tslib_prepare_deps = \
	$(STATEDIR)/tslib.extract

TSLIB_PATH	=  PATH=$(CROSS_PATH)
TSLIB_AUTOCONF 	= --prefix=$(INSTALLPATH) \
                  --host=$(CONFIG_GNU_HOST)
TSLIB_INCLDIRS = $(subst ",,-I$(INSTALLPATH)/include -I$(CONFIG_TOOLCHAINPATH)$(CONFIG_CROSSPREFIX)/include)
TSLIB_ENV += CFLAGS='$(CFLAGS) $(TSLIB_INCLDIRS) ' ac_cv_func_malloc_0_nonnull=yes
TSLIB_LIBDIRS = $(subst ",,-L$(CONFIG_TOOLCHAINPATH)$(CONFIG_CROSSPREFIX)/lib -L$(INSTALLPATH)/lib)
TSLIB_ENV += LDFLAGS='$(LDFLAGS) $(TSLIB_LIBDIRS) '
TSLIB_AUTOGEN = --prefix=$(INSTALLPATH)/ --host=$(CONFIG_CROSSPREFIX)

$(STATEDIR)/tslib.prepare: $(tslib_prepare_deps)
	@$(call targetinfo, $@)
	cd $(TSLIB_DIR) && \
		$(TSLIB_PATH) \
                $(CROSS_ENV) \
                $(TSLIB_ENV) \
                ./autogen.sh $(TSLIB_AUTOGEN)
	cd $(TSLIB_DIR) && \
		$(TSLIB_PATH) \
                $(TSLIB_ENV) \
                $(CROSS_ENV) \
		./configure $(TSLIB_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

tslib_compile: $(STATEDIR)/tslib.compile

$(STATEDIR)/tslib.compile: $(STATEDIR)/tslib.prepare 
	@$(call targetinfo, $@)
	cd $(TSLIB_DIR) && $(TSLIB_PATH) make
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

tslib_install: $(STATEDIR)/tslib.install

$(STATEDIR)/tslib.install: $(STATEDIR)/tslib.compile
	@$(call targetinfo, $@)
	install -d $(INSTALLPATH)/include
	cd $(TSLIB_DIR) && $(TSLIB_PATH) make install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

tslib_targetinstall: $(STATEDIR)/tslib.targetinstall

$(STATEDIR)/tslib.targetinstall: $(STATEDIR)/tslib.install
	@$(call targetinfo, $@)
	@mkdir -p $(ROOTDIR)/sbin
	#cp -fv $(INSTALLPATH)/sbin/tslib $(ROOTDIR)/sbin && $(CROSSSTRIP) $(ROOTDIR)/sbin/tslib
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

tslib_clean: 
	rm -rf $(STATEDIR)/tslib.* $(TSLIB_DIR)

# vim: syntax=make
