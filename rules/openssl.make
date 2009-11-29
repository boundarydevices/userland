# -*-makefile-*-
# $Id: openssl.make,v 1.9 2009-11-29 19:47:53 ericn Exp $
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
OPENSSL_VER             = 0.9.8
OPENSSL			= openssl-$(OPENSSL_VER)k
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
	cd $(BUILDDIR) && zcat $(OPENSSL_SOURCE) | tar -xvf -
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

openssl_prepare: $(STATEDIR)/openssl.prepare

openssl_prepare_deps =  \
	$(STATEDIR)/openssl.extract 

OPENSSL_PATH	= PATH=$(CROSS_PATH)
OPENSSL_MAKEVARS = \
	$(CROSS_ENV) \
        INSTALL_PREFIX=$(INSTALLPATH) \
        INSTALLTOP=$(INSTALLPATH)/usr/local/ssl

$(STATEDIR)/openssl.prepare: $(openssl_prepare_deps)
	@$(call targetinfo, $@)
	cd $(OPENSSL_DIR) && \
		$(OPENSSL_PATH) \
		$(OPENSSL_MAKEVARS) \
		./Configure linux-generic32 -DL_ENDIAN -shared
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

openssl_compile: $(STATEDIR)/openssl.compile

$(STATEDIR)/openssl.compile: $(STATEDIR)/openssl.prepare 
	@$(call targetinfo, $@)
	$(OPENSSL_PATH) make -C $(OPENSSL_DIR) all
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------
openssl_install: $(STATEDIR)/openssl.install

$(STATEDIR)/openssl.install: $(STATEDIR)/openssl.compile
	@$(call targetinfo, $@)
	$(OPENSSL_PATH) make -C $(OPENSSL_DIR) \
 		INSTALL_PREFIX=$(INSTALLPATH) INSTALLTOP='/' \
		install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

openssl_targetinstall: $(STATEDIR)/openssl.targetinstall

openssl_targetinstall_deps = \
	$(STATEDIR)/openssl.install \
        $(ROOTDIR)/lib/libcrypto.so.$(OPENSSL_VER)

$(ROOTDIR)/lib/libcrypto.so.$(OPENSSL_VER): $(OPENSSL_DIR)/libcrypto.so.$(OPENSSL_VER)
	mkdir -p $(ROOTDIR)/lib
	@cp -d -f $(OPENSSL_DIR)/libcrypto.so* $(ROOTDIR)/lib/
	@chmod a+rwx $(ROOTDIR)/lib/libcrypto.so*
	@$(OPENSSL_PATH) $(CROSSSTRIP) -S -R .note -R .comment $(ROOTDIR)/lib/libcrypto.so*

$(STATEDIR)/openssl.targetinstall: $(openssl_targetinstall_deps)
	@$(call targetinfo, $@)
ifdef CONFIG_OPENSSL_SHARED
	@mkdir -p $(ROOTDIR)/usr/lib
	@mkdir -p $(ROOTDIR)/lib
	@cp -d -f $(OPENSSL_DIR)/libssl.so* $(ROOTDIR)/lib/
	@$(OPENSSL_PATH) $(CROSSSTRIP) -S -R .note -R .comment $(ROOTDIR)/lib/libssl.so*
endif
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

openssl_clean: 
	rm -rf $(STATEDIR)/openssl.* $(OPENSSL_DIR)

# vim: syntax=make
