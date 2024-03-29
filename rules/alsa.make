# -*-makefile-*-
# $Id: alsa.make,v 1.7 2008-07-30 19:21:06 ericn Exp $
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
ifeq (y, $(CONFIG_ALSA))
PACKAGES += alsa
endif

#
# Paths and names 
#
ALSA			= alsa-lib-1.0.13
ALSA_URL 	= http://gd.tuwien.ac.at/opsys/linux/alsa/lib/$(ALSA).tar.bz2
ALSA_SOURCE	= $(CONFIG_ARCHIVEPATH)/$(ALSA).tar.bz2
ALSA_DIR		= $(BUILDDIR)/$(ALSA)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

alsa_get: $(STATEDIR)/alsa.get

$(STATEDIR)/alsa.get: $(ALSA_SOURCE)
	@$(call targetinfo, $@)
	touch $@

$(ALSA_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(ALSA_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

alsa_extract: $(STATEDIR)/alsa.extract

$(STATEDIR)/alsa.extract: $(STATEDIR)/alsa.get
	@$(call targetinfo, $@)
	@$(call clean, $(ALSA_DIR))
	@cd $(BUILDDIR) && bzcat $(ALSA_SOURCE) | tar -xvf -
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

alsa_prepare: $(STATEDIR)/alsa.prepare

alsa_prepare_deps = \
	$(STATEDIR)/alsa.extract

ALSA_PATH = PATH=$(CROSS_PATH)

ALSA_AUTOCONF = \
	--host=$(CONFIG_GNU_HOST) \
   --enable-shared=yes \
   --enable-static=yes \
   --disable-sdl \
   --prefix=/

$(STATEDIR)/alsa.prepare: $(alsa_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ALSA_DIR)/config.cache)
	cd $(ALSA_DIR) && \
		$(ALSA_PATH) \
      $(CROSS_ENV) \
		./configure $(ALSA_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

alsa_compile: $(STATEDIR)/alsa.compile

$(STATEDIR)/alsa.compile: $(STATEDIR)/alsa.prepare 
	@$(call targetinfo, $@)
	cd $(ALSA_DIR) && $(ALSA_PATH) make
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

alsa_install: $(STATEDIR)/alsa.install

$(STATEDIR)/alsa.install: $(STATEDIR)/alsa.compile
	@$(call targetinfo, $@)
	install -d $(INSTALLPATH)/include
	cd $(ALSA_DIR) && $(ALSA_PATH) && DESTDIR=$(INSTALLPATH) make install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

alsa_targetinstall: $(STATEDIR)/alsa.targetinstall

$(STATEDIR)/alsa.targetinstall: $(STATEDIR)/alsa.install
	@$(call targetinfo, $@)
	install -d $(INSTALLPATH)/include
	cd $(ALSA_DIR) && $(ALSA_PATH) && DESTDIR=$(ROOTDIR) make install-strip
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

alsa_clean: 
	rm -rf $(STATEDIR)/alsa.* $(ALSA_DIR)

# vim: syntax=make
