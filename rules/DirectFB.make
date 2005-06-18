# -*-makefile-*-
# $Id: DirectFB.make,v 1.1 2005-06-18 16:24:03 ericn Exp $
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
ifeq (y, $(CONFIG_DIRECTFB))
PACKAGES += zlib
endif

#
# Paths and names 
#
DIRECTFB = DirectFB-0.9.22
DIRECTFB_URL = http://www.directfb.org/downloads/Core/$(DIRECTFB).tar.gz
DIRECTFB_SOURCE = $(CONFIG_ARCHIVEPATH)/$(DIRECTFB).tar.gz
DIRECTFB_DIR = $(BUILDDIR)/$(DIRECTFB)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

directfb_get: $(STATEDIR)/directfb.get

$(STATEDIR)/directfb.get: $(DIRECTFB_SOURCE)
	@$(call targetinfo, $@)
	touch $@

$(DIRECTFB_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(DIRECTFB_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

directfb_extract: $(STATEDIR)/directfb.extract

$(STATEDIR)/directfb.extract: $(STATEDIR)/directfb.get
	@$(call targetinfo, $@)
	@$(call clean, $(DIRECTFB_DIR))
	@cd $(BUILDDIR) && gzcat $(DIRECTFB_SOURCE) | tar -xvf -
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

directfb_prepare: $(STATEDIR)/directfb.prepare

directfb_prepare_deps = \
	$(STATEDIR)/directfb.extract

DIRECTFB_PATH	=  PATH=$(CROSS_PATH)
DIRECTFB_AUTOCONF = --host=$(CONFIG_GNU_TARGET) \
	--prefix=$(CROSS_LIB_DIR)

ifdef CONFIG_DIRECTFB_SHARED
   DIRECTFB_AUTOCONF 	+=  --enable-shared=yes
else
   DIRECTFB_AUTOCONF 	+=  --enable-shared=no
   DIRECTFB_AUTOCONF 	+=  --enable-static=yes
endif

DIRECTFB_AUTOCONF 	+=  --without-x
DIRECTFB_AUTOCONF 	+=  --enable-text=no
DIRECTFB_AUTOCONF 	+=  --enable-sdl=no
DIRECTFB_AUTOCONF 	+=  --enable-mmx=no
DIRECTFB_AUTOCONF 	+=  --enable-sse=no
DIRECTFB_AUTOCONF 	+=  --enable-sdl=no
DIRECTFB_AUTOCONF 	+=  --enable-sysfs=no
DIRECTFB_AUTOCONF 	+=  --enable-png=yes
DIRECTFB_AUTOCONF 	+=  --enable-video4linux=no
DIRECTFB_AUTOCONF 	+=  --with-gfxdrivers=none
DIRECTFB_AUTOCONF 	+=  --with-inputdrivers=none

$(STATEDIR)/directfb.prepare: $(directfb_prepare_deps)
	@$(call targetinfo, $@)
	cd $(DIRECTFB_DIR) && \
		$(DIRECTFB_PATH) \
      $(CROSS_ENV) \
      ./configure $(DIRECTFB_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

directfb_compile: $(STATEDIR)/directfb.compile

$(STATEDIR)/directfb.compile: $(STATEDIR)/directfb.prepare 
	@$(call targetinfo, $@)
	cd $(DIRECTFB_DIR) && $(DIRECTFB_PATH) make
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

directfb_install: $(STATEDIR)/directfb.install

$(STATEDIR)/directfb.install: $(STATEDIR)/directfb.compile
	@$(call targetinfo, $@)
	install -d $(INSTALLPATH)/include
	cd $(DIRECTFB_DIR) && $(DIRECTFB_PATH) make install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

directfb_targetinstall: $(STATEDIR)/directfb.targetinstall

$(STATEDIR)/directfb.targetinstall: $(STATEDIR)/directfb.install
	@$(call targetinfo, $@)
	@mkdir -p $(ROOTDIR)/usr/lib
ifdef CONFIG_DIRECTFB_SHARED
	@cp -d $(DIRECTFB_DIR)/libz.so* $(ROOTDIR)/usr/lib/
	@$(DIRECTFB_PATH) $(CROSSSTRIP) -R .note -R .comment $(ROOTDIR)/usr/lib/libz.so*
endif
	@cp -d $(DIRECTFB_DIR)/libz.a $(ROOTDIR)/usr/lib/
	@$(DIRECTFB_PATH) $(CROSSSTRIP) -R .note -R .comment $(ROOTDIR)/usr/lib/libz.a
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

directfb_clean: 
	rm -rf $(STATEDIR)/directfb.* $(DIRECTFB_DIR)

# vim: syntax=make
