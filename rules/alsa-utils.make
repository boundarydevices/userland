# -*-makefile-*-
# $Id: alsa-utils.make,v 1.1 2005-08-25 14:42:31 ericn Exp $
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
ifeq (y, $(CONFIG_ALSA_UTILS))
PACKAGES += alsa-utils
endif

#
# Paths and names 
#
ALSA_UTILS		= alsa-utils-1.0.9a
ALSA_UTILS_URL 	        = ftp://ftp.alsa-project.org/pub/utils/$(ALSA_UTILS).tar.bz2
ALSA_UTILS_SOURCE	= $(CONFIG_ARCHIVEPATH)/$(ALSA_UTILS).tar.bz2
ALSA_UTILS_DIR		= $(BUILDDIR)/$(ALSA_UTILS)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

alsa-utils_get: $(STATEDIR)/alsa-utils.get

$(STATEDIR)/alsa-utils.get: $(ALSA_UTILS_SOURCE)
	@$(call targetinfo, $@)
	touch $@

$(ALSA_UTILS_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(ALSA_UTILS_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

alsa-utils_extract: $(STATEDIR)/alsa-utils.extract

$(STATEDIR)/alsa-utils.extract: $(STATEDIR)/alsa-utils.get
	@$(call targetinfo, $@)
	@$(call clean, $(ALSA_UTILS_DIR))
	@cd $(BUILDDIR) && bzcat $(ALSA_UTILS_SOURCE) | tar -xvf -
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

alsa-utils_prepare: $(STATEDIR)/alsa-utils.prepare alsa_install ncurses_install

alsa-utils_prepare_deps = \
	$(STATEDIR)/alsa-utils.extract

ALSA_UTILS_PATH = PATH=$(CROSS_PATH)

ALSA_UTILS_AUTOCONF = \
	--host=$(CONFIG_GNU_TARGET) \
	--prefix=$(INSTALLPATH) \
   --disable-sdl \
   --exec-prefix=$(INSTALLPATH) \
   --includedir=$(INSTALLPATH)/include \
   --libdir=$(INSTALLPATH)/lib \
   --libexecdir=$(INSTALLPATH)/lib \
   --mandir=$(INSTALLPATH)/man \
   --with-alsa-inc-prefix=$(INSTALLPATH)/include \
   --with-alsa-prefix=$(INSTALLPATH)/lib \
   --disable-mixer \
   --infodir=$(INSTALLPATH)/info

$(STATEDIR)/alsa-utils.prepare: $(alsa-utils_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(ALSA_UTILS_DIR)/config.cache)
	cd $(ALSA_UTILS_DIR) && aclocal && autoconf && automake --add-missing
	cd $(ALSA_UTILS_DIR) && \
		$(ALSA_UTILS_PATH) \
      $(CROSS_ENV) \
		./configure $(ALSA_UTILS_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

alsa-utils_compile: $(STATEDIR)/alsa-utils.compile

$(STATEDIR)/alsa-utils.compile: $(STATEDIR)/alsa-utils.prepare 
	@$(call targetinfo, $@)
	cd $(ALSA_UTILS_DIR) && $(ALSA_UTILS_PATH) make
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

alsa-utils_install: $(STATEDIR)/alsa-utils.install

$(STATEDIR)/alsa-utils.install: $(STATEDIR)/alsa-utils.compile
	@$(call targetinfo, $@)
	install -d $(INSTALLPATH)/include
	cd $(ALSA_UTILS_DIR) && $(ALSA_UTILS_PATH) make install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

alsa-utils_targetinstall: $(STATEDIR)/alsa-utils.targetinstall

$(STATEDIR)/alsa-utils.targetinstall: $(STATEDIR)/alsa-utils.install
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

alsa-utils_clean: 
	rm -rf $(STATEDIR)/alsa-utils.* $(ALSA_UTILS_DIR)

# vim: syntax=make
