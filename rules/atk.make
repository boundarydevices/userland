# -*-makefile-*-
# $Id: atk.make,v 1.3 2007-10-08 21:06:10 ericn Exp $
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
ifeq (y, $(CONFIG_ATK))
PACKAGES += atk
endif

#
# Paths and names 
#
ATK			= atk-1.9.0
ATK_URL 	= ftp://ftp.gtk.org/pub/gtk/v2.6/$(ATK).tar.bz2
ATK_SOURCE	= $(CONFIG_ARCHIVEPATH)/$(ATK).tar.bz2
ATK_DIR		= $(BUILDDIR)/$(ATK)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

atk_get: $(STATEDIR)/atk.get

$(STATEDIR)/atk.get: $(ATK_SOURCE)
	@$(call targetinfo, $@)
	touch $@

$(ATK_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(ATK_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

atk_extract: $(STATEDIR)/atk.extract

$(STATEDIR)/atk.extract: $(STATEDIR)/atk.get
	@$(call targetinfo, $@)
	@$(call clean, $(ATK_DIR))
	@cd $(BUILDDIR) && bzcat $(ATK_SOURCE) | tar -xvf -
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

atk_prepare: $(STATEDIR)/atk.prepare $(STATEDIR)/glib.prepare 

atk_prepare_deps = \
	$(STATEDIR)/atk.extract \
   $(TOPDIR)/$(CONFIG_GNU_TARGET)-pkg-config

ATK_PATH	   =  PATH=$(CROSS_PATH)
ATK_AUTOCONF = --host=$(CONFIG_GNU_HOST) \
	--prefix=$(INSTALLPATH)

ifdef CONFIG_ATK_SHARED
   ATK_AUTOCONF 	+=  --shared
else
endif

$(STATEDIR)/atk.prepare: $(atk_prepare_deps)
	@$(call targetinfo, $@)
	cd $(ATK_DIR) && \
		$(ATK_PATH) \
      $(CROSS_ENV) \
      PKG_CONFIG_PATH=$(INSTALLPATH)/lib/pkgconfig/ \
      PATH=$(INSTALLPATH)/bin:$(PATH) \
      PKG_CONFIG=$(TOPDIR)/$(CONFIG_GNU_TARGET)-pkg-config \
      PKG_CONFIG_PATH=$(INSTALLPATH)/lib/pkgconfig/ \
		./configure $(ATK_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

atk_compile: $(STATEDIR)/atk.compile 

$(STATEDIR)/atk.compile: $(STATEDIR)/atk.prepare $(STATEDIR)/glib.install 
	@$(call targetinfo, $@)
	cd $(ATK_DIR) && $(ATK_PATH) make
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

atk_install: $(STATEDIR)/atk.install

$(STATEDIR)/atk.install: $(STATEDIR)/atk.compile
	@$(call targetinfo, $@)
	install -d $(INSTALLPATH)/include
	cd $(ATK_DIR) && $(ATK_PATH) make install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

atk_targetinstall: $(STATEDIR)/atk.targetinstall

$(STATEDIR)/atk.targetinstall: $(STATEDIR)/atk.install
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

atk_clean: 
	rm -rf $(STATEDIR)/atk.* $(ATK_DIR)

# vim: syntax=make
