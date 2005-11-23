# -*-makefile-*-
# $Id: libio.make,v 1.2 2005-11-23 14:49:43 ericn Exp $
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
PACKAGES += libio
endif

#
# Paths and names 
#
LIBIO		= libio-0.1
LIBIO_URL 	        = http://www.monkey.org/~provos/$(LIBIO).tar.gz
LIBIO_SOURCE	        = $(CONFIG_ARCHIVEPATH)/$(LIBIO).tar.gz
LIBIO_DIR		= $(BUILDDIR)/libio
LIBIO_PATCH	        = $(CONFIG_ARCHIVEPATH)/$(LIBIO).patch
LIBIO_PATCH_URL	        = http://boundarydevices.com/$(LIBIO).patch

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libio_get: $(STATEDIR)/libio.get

$(STATEDIR)/libio.get: $(LIBIO_SOURCE)
	@$(call targetinfo, $@)
	touch $@

$(LIBIO_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(LIBIO_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libio_extract: $(STATEDIR)/libio.extract

$(LIBIO_PATCH):
	@cd $(CONFIG_ARCHIVEPATH) && wget $(LIBIO_PATCH_URL)
        
$(STATEDIR)/libio.extract: $(STATEDIR)/libio.get $(LIBIO_PATCH)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBIO_DIR))
	@cd $(BUILDDIR) && zcat $(LIBIO_SOURCE) | tar -xvf -
	@cd $(BUILDDIR) && patch -p0 < $(LIBIO_PATCH)
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libio_prepare: $(STATEDIR)/libio.prepare alsa_install ncurses_install

libio_prepare_deps = \
	$(STATEDIR)/libio.extract

LIBIO_PATH = PATH=$(CROSS_PATH)

LIBIO_AUTOCONF = \
	--host=$(CONFIG_GNU_TARGET) \
	--prefix=$(INSTALLPATH) \
	--enable-shared=no \
   --exec-prefix=$(INSTALLPATH) \
   --includedir=$(INSTALLPATH)/include \
   --libdir=$(INSTALLPATH)/lib \
   --libexecdir=$(INSTALLPATH)/lib \
   --mandir=$(INSTALLPATH)/man \
   --infodir=$(INSTALLPATH)/info

$(STATEDIR)/libio.prepare: $(libio_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBIO_DIR)/config.cache)
	cd $(LIBIO_DIR) && \
		$(LIBIO_PATH) \
      $(CROSS_ENV) \
		./configure $(LIBIO_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libio_compile: $(STATEDIR)/libio.compile

$(STATEDIR)/libio.compile: $(STATEDIR)/libio.prepare 
	@$(call targetinfo, $@)
	cd $(LIBIO_DIR) && $(LIBIO_PATH) make
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libio_install: $(STATEDIR)/libio.install

$(STATEDIR)/libio.install: $(STATEDIR)/libio.compile
	@$(call targetinfo, $@)
	install -d $(INSTALLPATH)/include
	cd $(LIBIO_DIR) && $(LIBIO_PATH) make install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libio_targetinstall: $(STATEDIR)/libio.targetinstall

$(STATEDIR)/libio.targetinstall: $(STATEDIR)/libio.install
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libio_clean: 
	rm -rf $(STATEDIR)/libio.* $(LIBIO_DIR)

# vim: syntax=make
