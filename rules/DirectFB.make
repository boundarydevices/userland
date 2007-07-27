# -*-makefile-*-
# $Id: DirectFB.make,v 1.8 2007-07-27 22:10:48 ericn Exp $
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
PACKAGES += directfb
endif

ECHO?=`which echo`

#
# Paths and names 
#
DIRECTFB = DirectFB-1.0.0
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
	@cd $(BUILDDIR) && zcat $(DIRECTFB_SOURCE) | tar -xvf -
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

directfb_prepare: $(STATEDIR)/directfb.prepare $(STATEDIR)/JPEG.install

directfb_prepare_deps = \
	$(STATEDIR)/directfb.extract

DIRECTFB_PATH	=  PATH=$(CROSS_PATH)
DIRECTFB_AUTOCONF = --host=$(CONFIG_GNU_TARGET)

CONFIG_DIRECTFB_SHARED = 1
ifdef CONFIG_DIRECTFB_SHARED
   DIRECTFB_AUTOCONF 	+=  --enable-shared=yes
else
   DIRECTFB_AUTOCONF 	+=  --enable-shared=no
   DIRECTFB_AUTOCONF 	+=  --enable-static=yes
endif

DIRECTFB_AUTOCONF 	+=  --without-x
DIRECTFB_AUTOCONF 	+=  --enable-text=yes
DIRECTFB_AUTOCONF 	+=  --enable-sdl=no
DIRECTFB_AUTOCONF 	+=  --enable-mmx=no
DIRECTFB_AUTOCONF 	+=  --enable-sse=no
DIRECTFB_AUTOCONF 	+=  --enable-sdl=no
DIRECTFB_AUTOCONF 	+=  --enable-sysfs=no
DIRECTFB_AUTOCONF 	+=  --enable-png=yes
DIRECTFB_AUTOCONF 	+=  --enable-zlib=yes
DIRECTFB_AUTOCONF 	+=  --enable-video4linux=no
DIRECTFB_AUTOCONF 	+=  --with-gfxdrivers=none
DIRECTFB_AUTOCONF 	+=  --with-inputdrivers=linuxinput,tslib

$(STATEDIR)/directfb.prepare: $(directfb_prepare_deps)
	@$(call targetinfo, $@)
	cd $(DIRECTFB_DIR) && \
		$(DIRECTFB_PATH) \
      $(CROSS_ENV) \
      CFLAGS=-I$(INSTALLPATH)/include \
      CPPFLAGS=-I$(INSTALLPATH)/include \
      LDFLAGS=-L$(INSTALLPATH)/lib \
      LIBS=" -lz -lm " \
      ./configure $(DIRECTFB_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

directfb_compile: $(STATEDIR)/directfb.compile

$(STATEDIR)/directfb.compile: $(STATEDIR)/directfb.prepare 
	@$(call targetinfo, $@)
	cd $(DIRECTFB_DIR) && $(DIRECTFB_PATH) $(CROSS_ENV) make
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

directfb_install: $(STATEDIR)/directfb.install

$(STATEDIR)/directfb.install: $(STATEDIR)/directfb.compile
	@$(call targetinfo, $@)
	cd $(DIRECTFB_DIR) && \
        DESTDIR=$(INSTALLPATH) \
        $(DIRECTFB_PATH) make install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

directfb_targetinstall: $(STATEDIR)/directfb.targetinstall

$(STATEDIR)/directfb.targetinstall: $(STATEDIR)/directfb.install $(ROOTDIR)/etc
	@$(call targetinfo, $@)
	cd $(DIRECTFB_DIR) && \
        DESTDIR=$(ROOTDIR) \
        $(DIRECTFB_PATH) make install
	$(ECHO) -e "system=fbdev" > $(ROOTDIR)/etc/directfbrc
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

directfb_clean: 
	rm -rf $(STATEDIR)/directfb.* $(DIRECTFB_DIR)

# vim: syntax=make
