# -*-makefile-*-
# $Id: zlib.make,v 1.1 2004-05-31 19:45:32 ericn Exp $
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
ifeq (y, $(CONFIG_ZLIB))
PACKAGES += zlib
endif

#
# Paths and names 
#
ZLIB			= zlib-1.1.4
ZLIB_URL 	= ftp://ftp.info-zip.org/pub/infozip/zlib/$(ZLIB).tar.gz
ZLIB_SOURCE	= $(CONFIG_ARCHIVEPATH)/$(ZLIB).tar.gz
ZLIB_DIR		= $(BUILDDIR)/$(ZLIB)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

zlib_get: $(STATEDIR)/zlib.get

$(STATEDIR)/zlib.get: $(ZLIB_SOURCE)
	@$(call targetinfo, $@)
	touch $@

$(ZLIB_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(ZLIB_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

zlib_extract: $(STATEDIR)/zlib.extract

$(STATEDIR)/zlib.extract: $(STATEDIR)/zlib.get
	@$(call targetinfo, $@)
	@$(call clean, $(ZLIB_DIR))
	@cd $(BUILDDIR) && gzcat $(ZLIB_SOURCE) | tar -xvf -
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

zlib_prepare: $(STATEDIR)/zlib.prepare

zlib_prepare_deps = \
	$(STATEDIR)/zlib.extract

ZLIB_PATH	=  PATH=$(CROSS_PATH)
ZLIB_AUTOCONF 	= --prefix=$(INSTALLPATH) 

ifdef CONFIG_ZLIB_SHARED
   ZLIB_AUTOCONF 	+=  --shared
else
endif

$(STATEDIR)/zlib.prepare: $(zlib_prepare_deps)
	@$(call targetinfo, $@)
	cd $(ZLIB_DIR) && \
		$(ZLIB_PATH) \
		./configure $(ZLIB_AUTOCONF)
	perl -i -p -e 's/=ar/=$(CONFIG_GNU_TARGET)-ar/g' $(ZLIB_DIR)/Makefile
	perl -i -p -e 's/=gcc/=$(CONFIG_GNU_TARGET)-gcc/g' $(ZLIB_DIR)/Makefile
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

zlib_compile: $(STATEDIR)/zlib.compile

$(STATEDIR)/zlib.compile: $(STATEDIR)/zlib.prepare 
	@$(call targetinfo, $@)
	cd $(ZLIB_DIR) && $(ZLIB_PATH) make
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

zlib_install: $(STATEDIR)/zlib.install

$(STATEDIR)/zlib.install: $(STATEDIR)/zlib.compile
	@$(call targetinfo, $@)
	install -d $(INSTALLPATH)/include
	cd $(ZLIB_DIR) && $(ZLIB_PATH) make install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

zlib_targetinstall: $(STATEDIR)/zlib.targetinstall

$(STATEDIR)/zlib.targetinstall: $(STATEDIR)/zlib.install
	@$(call targetinfo, $@)
	mkdir -p $(ROOTDIR)/usr/lib
ifdef CONFIG_ZLIB_SHARED
	cp -d $(ZLIB_DIR)/libz.so* $(ROOTDIR)/usr/lib/
	$(CROSSSTRIP) -R .note -R .comment $(ROOTDIR)/usr/lib/libz.so*
endif
	cp -d $(ZLIB_DIR)/libz.a $(ROOTDIR)/usr/lib/
	$(CROSSSTRIP) -R .note -R .comment $(ROOTDIR)/usr/lib/libz.a
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

zlib_clean: 
	rm -rf $(STATEDIR)/zlib.* $(ZLIB_DIR)

# vim: syntax=make
