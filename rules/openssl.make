# -*-makefile-*-
# $Id: openssl.make,v 1.4 2004-06-10 03:24:05 ericn Exp $
#
# Copyright (C) 2002 by Jochen Striepe for Pengutronix e.K., Hildesheim, Germany
#               2003 by Pengutronix e.K., Hildesheim, Germany
#
# See CREDITS for details about who has contributed to this project. 
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef CONFIG_OPENSSL
PACKAGES += openssl
endif

#
# Paths and names 
#
OPENSSL			= openssl-0.9.7c
OPENSSL_URL 		= http://www.openssl.org/source/$(OPENSSL).tar.gz
OPENSSL_SOURCE		= $(CONFIG_ARCHIVEPATH)/$(OPENSSL).tar.gz
OPENSSL_DIR 		= $(BUILDDIR)/$(OPENSSL)

THUD = linux-elf-arm

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

openssl_get: $(STATEDIR)/openssl.get

$(STATEDIR)/openssl.get: $(OPENSSL_SOURCE)
	@$(call targetinfo, $@)
	touch $@

$(OPENSSL_SOURCE):
	@$(call targetinfo, $@)
	cd $(CONFIG_ARCHIVEPATH) && wget $(OPENSSL_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

openssl_extract: $(STATEDIR)/openssl.extract

$(STATEDIR)/openssl.extract: $(STATEDIR)/openssl.get
	@$(call targetinfo, $@)
	@$(call clean, $(OPENSSL_DIR))
	cd $(BUILDDIR) && gzcat $(OPENSSL_SOURCE) | tar -xvf -
	perl -p -i -e 's/-m486//' $(OPENSSL_DIR)/Configure
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

openssl_prepare: $(STATEDIR)/openssl.prepare

openssl_prepare_deps =  \
	$(STATEDIR)/openssl.extract 

OPENSSL_PATH	= PATH=$(CROSS_PATH)
OPENSSL_MAKEVARS = \
	$(CROSS_ENV_CC) \
	$(CROSS_ENV_RANLIB) \
	AR='$(CONFIG_GNU_TARGET)-ar r' \
	MANDIR=/man

OPENSSL_AUTOCONF = \
	--prefix=$(INSTALLPATH) \
	-ldl \
	--openssldir=/etc/ssl 

ifdef CONFIG_OPENSSL_SHARED
   OPENSSL_AUTOCONF	+= shared
else
   OPENSSL_AUTOCONF	+= no-shared
endif

$(STATEDIR)/openssl.prepare: $(openssl_prepare_deps)
	@$(call targetinfo, $@)
	cd $(OPENSSL_DIR) && \
		$(OPENSSL_PATH) \
		./Configure $(OPENSSL_AUTOCONF) $(THUD)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

openssl_compile: $(STATEDIR)/openssl.compile

$(STATEDIR)/openssl.compile: $(STATEDIR)/openssl.prepare 
	@$(call targetinfo, $@)
#
# generate openssl.pc with correct path inside
#
	$(OPENSSL_PATH) make -C $(OPENSSL_DIR) INSTALLTOP=$(INSTALLPATH) openssl.pc
	$(OPENSSL_PATH) make -C $(OPENSSL_DIR) $(OPENSSL_MAKEVARS)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

openssl_install: $(STATEDIR)/openssl.install

$(STATEDIR)/openssl.install: $(STATEDIR)/openssl.compile
	@$(call targetinfo, $@)
#
# broken Makfile, generates dir with wrong permissions...
# chmod 755 fixed that
#
	@mkdir -p $(INSTALLPATH)/lib/pkgconfig
	@chmod 755 $(INSTALLPATH)/lib/pkgconfig
	$(OPENSSL_PATH) make -C $(OPENSSL_DIR) install $(OPENSSL_MAKEVARS) \
		INSTALL_PREFIX=$(INSTALLPATH) INSTALLTOP=''
	@chmod 755 $(INSTALLPATH)/lib/pkgconfig
#
# FIXME:
# 	OPENSSL=${D}/usr/bin/openssl /usr/bin/perl tools/c_rehash ${D}/etc/ssl/certs
#
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

openssl_targetinstall: $(STATEDIR)/openssl.targetinstall

openssl_targetinstall_deps = \
	$(STATEDIR)/openssl.install

$(STATEDIR)/openssl.targetinstall: $(openssl_targetinstall_deps)
	@$(call targetinfo, $@)
ifdef CONFIG_OPENSSL_SHARED
	@mkdir -p $(ROOTDIR)/usr/lib
	@cp -d -f $(OPENSSL_DIR)/libssl.so* $(ROOTDIR)/lib/
	@$(OPENSSL_PATH) $(CROSSSTRIP) -S -R .note -R .comment $(ROOTDIR)/lib/libssl.so*

	@cp -d -f $(OPENSSL_DIR)/libcrypto.so* $(ROOTDIR)/lib/
	@$(OPENSSL_PATH) $(CROSSSTRIP) -S -R .note -R .comment $(ROOTDIR)/lib/libcrypto.so*
endif
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

openssl_clean: 
	rm -rf $(STATEDIR)/openssl.* $(OPENSSL_DIR)

# vim: syntax=make
