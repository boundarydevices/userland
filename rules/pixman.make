# -*-makefile-*-
# $Id: pixman.make,v 1.7 2007-10-08 21:06:10 ericn Exp $
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
ifeq (y, $(CONFIG_PIXMAN))
PACKAGES += pixman
endif

#
# Paths and names 
#
PIXMAN = libpixman-0.1.5
PIXMAN_URL = http://cairographics.org/snapshots/$(PIXMAN).tar.gz
PIXMAN_SOURCE = $(CONFIG_ARCHIVEPATH)/$(PIXMAN).tar.gz
PIXMAN_DIR = $(BUILDDIR)/$(PIXMAN)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

pixman_get: $(STATEDIR)/pixman.get

$(STATEDIR)/pixman.get: $(PIXMAN_SOURCE)
	@$(call targetinfo, $@)
	touch $@

$(PIXMAN_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(PIXMAN_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

pixman_extract: $(STATEDIR)/pixman.extract

$(STATEDIR)/pixman.extract: $(STATEDIR)/pixman.get
	@$(call targetinfo, $@)
	@$(call clean, $(PIXMAN_DIR))
	@cd $(BUILDDIR) && zcat $(PIXMAN_SOURCE) | tar -xvf -
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

pixman_prepare: $(STATEDIR)/pixman.prepare

pixman_prepare_deps = \
	$(STATEDIR)/pixman.extract

PIXMAN_PATH	=  PATH=$(CROSS_PATH)
PIXMAN_AUTOCONF = --host=$(CONFIG_GNU_HOST) \
	--prefix=$(INSTALLPATH)

ifdef CONFIG_PIXMAN_SHARED
   PIXMAN_AUTOCONF 	+=  --enable-shared=yes
else
   PIXMAN_AUTOCONF 	+=  --enable-shared=no
   PIXMAN_AUTOCONF 	+=  --enable-static=yes
endif

$(STATEDIR)/pixman.prepare: $(pixman_prepare_deps)
	@$(call targetinfo, $@)
	cd $(PIXMAN_DIR) && \
		$(PIXMAN_PATH) \
      $(CROSS_ENV) \
      ./configure $(PIXMAN_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

pixman_compile: $(STATEDIR)/pixman.compile

$(STATEDIR)/pixman.compile: $(STATEDIR)/pixman.prepare 
	@$(call targetinfo, $@)
	cd $(PIXMAN_DIR) && $(PIXMAN_PATH) make
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

pixman_install: $(STATEDIR)/pixman.install

$(STATEDIR)/pixman.install: $(STATEDIR)/pixman.compile
	@$(call targetinfo, $@)
	install -d $(INSTALLPATH)/include
	cd $(PIXMAN_DIR) && $(PIXMAN_PATH) make install
	cp -rv $(PIXMAN_DIR)/libpixman.pc $(INSTALLPATH)/lib/pkgconfig/
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

pixman_targetinstall: $(STATEDIR)/pixman.targetinstall

$(STATEDIR)/pixman.targetinstall: $(STATEDIR)/pixman.install
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

pixman_clean: 
	rm -rf $(STATEDIR)/pixman.* $(PIXMAN_DIR)

# vim: syntax=make
