# -*-makefile-*-
# $Id: fontconfig.make,v 1.6 2006-08-16 18:40:28 ericn Exp $
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
ifeq (y, $(CONFIG_FONTCONFIG))
PACKAGES += fontconfig
endif

#
# Paths and names 
#
FONTCONFIG = fontconfig-2.3.2
FONTCONFIG_URL = http://www.fontconfig.org/release/$(FONTCONFIG).tar.gz
FONTCONFIG_SOURCE = $(CONFIG_ARCHIVEPATH)/$(FONTCONFIG).tar.gz
FONTCONFIG_DIR = $(BUILDDIR)/$(FONTCONFIG)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

fontconfig_get: $(STATEDIR)/fontconfig.get

$(STATEDIR)/fontconfig.get: $(FONTCONFIG_SOURCE)
	@$(call targetinfo, $@)
	touch $@

$(FONTCONFIG_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(FONTCONFIG_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

fontconfig_extract: $(STATEDIR)/fontconfig.extract

$(STATEDIR)/fontconfig.extract: $(STATEDIR)/fontconfig.get
	@$(call targetinfo, $@)
	@$(call clean, $(FONTCONFIG_DIR))
	@cd $(BUILDDIR) && zcat $(FONTCONFIG_SOURCE) | tar -xvf -
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

fontconfig_prepare: $(STATEDIR)/fontconfig.prepare

fontconfig_prepare_deps = \
	$(STATEDIR)/fontconfig.extract \
   $(STATEDIR)/expat.install \
   $(STATEDIR)/freetype.install

FONTCONFIG_PATH	=  PATH=$(CROSS_PATH)
FONTCONFIG_AUTOCONF = --host=$(CONFIG_GNU_TARGET) \
	--prefix=$(INSTALLPATH)

ifdef CONFIG_FONTCONFIG_SHARED
   FONTCONFIG_AUTOCONF 	+=  --enable-shared=yes
else
   FONTCONFIG_AUTOCONF 	+=  --enable-shared=no
   FONTCONFIG_AUTOCONF 	+=  --enable-static=yes
endif

FONTCONFIG_AUTOCONF += --with-freetype-config=$(INSTALLPATH)/bin/freetype-config --enable-doc=no

FONTCONFIG_AUTOCONF += \
  --with-expat-includes=$(INSTALLPATH)/include \
  --with-expat-lib=$(INSTALLPATH)/lib 

$(STATEDIR)/fontconfig.prepare: $(fontconfig_prepare_deps)
	@$(call targetinfo, $@)
	cd $(FONTCONFIG_DIR) && \
		$(FONTCONFIG_PATH) \
      $(CROSS_ENV) \
      ./configure $(FONTCONFIG_AUTOCONF)
	sed 's/all-am//g' < $(FONTCONFIG_DIR)/doc/Makefile >$(FONTCONFIG_DIR)/doc/Makefile.patched
	sed 's/install: inst/install:/g' < $(FONTCONFIG_DIR)/doc/Makefile.patched >$(FONTCONFIG_DIR)/doc/Makefile.patched2
	mv $(FONTCONFIG_DIR)/doc/Makefile $(FONTCONFIG_DIR)/doc/Makefile.orig
	mv $(FONTCONFIG_DIR)/doc/Makefile.patched2 $(FONTCONFIG_DIR)/doc/Makefile
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

fontconfig_compile: $(STATEDIR)/fontconfig.compile

$(STATEDIR)/fontconfig.compile: $(STATEDIR)/fontconfig.prepare 
	@$(call targetinfo, $@)
	cd $(FONTCONFIG_DIR) && $(FONTCONFIG_PATH) make
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

fontconfig_install: $(STATEDIR)/fontconfig.install

$(STATEDIR)/fontconfig.install: $(STATEDIR)/fontconfig.compile
	@$(call targetinfo, $@)
	install -d $(INSTALLPATH)/include
	cd $(FONTCONFIG_DIR) && $(FONTCONFIG_PATH) make install
	cp -rv $(FONTCONFIG_DIR)/fontconfig.pc $(INSTALLPATH)/lib/pkgconfig/
	perl -pi.orig -e 's/-lfontconfig/-lfontconfig -lexpat/' $(INSTALLPATH)/lib/pkgconfig/fontconfig.pc
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

fontconfig_targetinstall: $(STATEDIR)/fontconfig.targetinstall

$(STATEDIR)/fontconfig.targetinstall: $(STATEDIR)/fontconfig.install
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

fontconfig_clean: 
	rm -rf $(STATEDIR)/fontconfig.* $(FONTCONFIG_DIR)

# vim: syntax=make
