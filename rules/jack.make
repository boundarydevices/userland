# -*-makefile-*-
# $Id: jack.make,v 1.3 2007-10-08 21:06:10 ericn Exp $
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
PACKAGES += jack
endif

#
# Paths and names 
#
JACK		= jack-audio-connection-kit-0.100.0
JACK_URL 	= http://easynews.dl.sourceforge.net/sourceforge/jackit/$(JACK).tar.gz
JACK_SOURCE	= $(CONFIG_ARCHIVEPATH)/$(JACK).tar.gz
JACK_DIR	= $(BUILDDIR)/$(JACK)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

jack_get: $(STATEDIR)/jack.get

$(STATEDIR)/jack.get: $(JACK_SOURCE)
	@$(call targetinfo, $@)
	touch $@

$(JACK_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(JACK_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

jack_extract: $(STATEDIR)/jack.extract

$(STATEDIR)/jack.extract: $(STATEDIR)/jack.get
	@$(call targetinfo, $@)
	@$(call clean, $(JACK_DIR))
	@cd $(BUILDDIR) && zcat $(JACK_SOURCE) | tar -xvf -
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

jack_prepare: $(STATEDIR)/jack.prepare alsa_install ncurses_install

jack_prepare_deps = \
	$(STATEDIR)/jack.extract

JACK_PATH = PATH=$(CROSS_PATH)

JACK_AUTOCONF = \
	--host=$(CONFIG_GNU_HOST) \
	--prefix=$(INSTALLPATH) \
	--enable-shared=no \
   --exec-prefix=$(INSTALLPATH) \
   --includedir=$(INSTALLPATH)/include \
   --libdir=$(INSTALLPATH)/lib \
   --libexecdir=$(INSTALLPATH)/lib \
   --mandir=$(INSTALLPATH)/man \
   --infodir=$(INSTALLPATH)/info \
   --disable-dependency-tracking

$(STATEDIR)/jack.prepare: $(jack_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(JACK_DIR)/config.cache)
	cd $(JACK_DIR) && $(JACK_PATH) $(CROSS_ENV) \
		aclocal && autoconf && automake --add-missing
	cd $(JACK_DIR) && $(JACK_PATH) $(CROSS_ENV) \
		./configure $(JACK_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

jack_compile: $(STATEDIR)/jack.compile

$(STATEDIR)/jack.compile: $(STATEDIR)/jack.prepare 
	@$(call targetinfo, $@)
	cd $(JACK_DIR) && $(JACK_PATH) make
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

jack_install: $(STATEDIR)/jack.install

$(STATEDIR)/jack.install: $(STATEDIR)/jack.compile
	@$(call targetinfo, $@)
	install -d $(INSTALLPATH)/include
	cd $(JACK_DIR) && $(JACK_PATH) make install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

jack_targetinstall: $(STATEDIR)/jack.targetinstall

$(STATEDIR)/jack.targetinstall: $(STATEDIR)/jack.install
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

jack_clean: 
	rm -rf $(STATEDIR)/jack.* $(JACK_DIR)

# vim: syntax=make
