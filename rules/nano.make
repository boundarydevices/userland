# -*-makefile-*-
# $Id: nano.make,v 1.1 2007-01-30 00:13:33 ericn Exp $
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
ifeq (y, $(CONFIG_NANO))
PACKAGES += nano
endif

#
# Paths and names 
#
NANO			= nano-lib-1.0.9
NANO_URL 	= http://gd.tuwien.ac.at/opsys/linux/nano/lib/$(NANO).tar.bz2
NANO_SOURCE	= $(CONFIG_ARCHIVEPATH)/$(NANO).tar.bz2
NANO_DIR		= $(BUILDDIR)/$(NANO)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

nano_get: $(STATEDIR)/nano.get

$(STATEDIR)/nano.get: $(NANO_SOURCE)
	@$(call targetinfo, $@)
	touch $@

$(NANO_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(NANO_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

nano_extract: $(STATEDIR)/nano.extract

$(STATEDIR)/nano.extract: $(STATEDIR)/nano.get
	@$(call targetinfo, $@)
	@$(call clean, $(NANO_DIR))
	@cd $(BUILDDIR) && bzcat $(NANO_SOURCE) | tar -xvf -
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

nano_prepare: $(STATEDIR)/nano.prepare

nano_prepare_deps = \
	$(STATEDIR)/nano.extract

NANO_PATH = PATH=$(CROSS_PATH)

NANO_AUTOCONF = \
	--host=$(CONFIG_GNU_TARGET) \
	--prefix=$(INSTALLPATH) \
   --enable-shared=yes \
   --enable-static=yes \
   --disable-sdl \
   --exec-prefix=$(INSTALLPATH) \
   --includedir=$(INSTALLPATH)/include \
   --mandir=$(INSTALLPATH)/man \
   --infodir=$(INSTALLPATH)/info

$(STATEDIR)/nano.prepare: $(nano_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(NANO_DIR)/config.cache)
	cd $(NANO_DIR) && libtoolize --copy --force
	cd $(NANO_DIR) && aclocal && autoconf && automake --add-missing
	cd $(NANO_DIR) && \
		$(NANO_PATH) \
      $(CROSS_ENV) \
		./configure $(NANO_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

nano_compile: $(STATEDIR)/nano.compile

$(STATEDIR)/nano.compile: $(STATEDIR)/nano.prepare 
	@$(call targetinfo, $@)
	cd $(NANO_DIR) && $(NANO_PATH) make
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

nano_install: $(STATEDIR)/nano.install

$(STATEDIR)/nano.install: $(STATEDIR)/nano.compile
	@$(call targetinfo, $@)
	install -d $(INSTALLPATH)/include
	cd $(NANO_DIR) && $(NANO_PATH) make install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

nano_targetinstall: $(STATEDIR)/nano.targetinstall

$(STATEDIR)/nano.targetinstall: $(STATEDIR)/nano.install
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

nano_clean: 
	rm -rf $(STATEDIR)/nano.* $(NANO_DIR)

# vim: syntax=make
