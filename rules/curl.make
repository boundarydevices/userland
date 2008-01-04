# -*-makefile-*-
# $Id: curl.make,v 1.8 2008-01-04 22:04:34 ericn Exp $
#
# Copyright (C) 2003 by Boundary Devices
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef CONFIG_CURL
PACKAGES += curl
endif

#
# Paths and names
#
CURL_VERSION	= 7.10.8
CURL		= curl-$(CURL_VERSION)
CURL_SUFFIX		= tar.gz
CURL_URL		= http://curl.haxx.se/download/archeology/$(CURL).$(CURL_SUFFIX)
CURL_SOURCE		= $(CONFIG_ARCHIVEPATH)/$(CURL).$(CURL_SUFFIX)
CURL_DIR		= $(BUILDDIR)/$(CURL)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

curl_get: $(STATEDIR)/curl.get

curl_get_deps = $(CURL_SOURCE)

$(STATEDIR)/curl.get: $(curl_get_deps)
	@$(call targetinfo, $@)
	touch $@

$(CURL_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(CURL_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

curl_extract: $(STATEDIR)/curl.extract

curl_extract_deps = $(STATEDIR)/curl.get

$(STATEDIR)/curl.extract: $(curl_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(CURL_DIR))
	@cd $(BUILDDIR) && zcat $(CURL_SOURCE) | tar -xvf -
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

curl_prepare: $(STATEDIR)/curl.prepare

#
# dependencies
#
curl_prepare_deps = \
   $(STATEDIR)/curl.extract \
   $(STATEDIR)/openssl.install \
   $(STATEDIR)/zlib.install

CURL_PATH	=  PATH=$(CROSS_PATH)
CURL_ENV 	=  $(CROSS_ENV)
#CURL_ENV	+=

#
# autoconf
#
CURL_AUTOCONF = \
	--host=$(CONFIG_GNU_HOST) \
	--prefix=$(INSTALLPATH) \
   --with-random \
   --enable-shared=no \
   --enable-static=yes \
   --exec-prefix=$(INSTALLPATH) \
   --includedir=$(INSTALLPATH)/include \
   --mandir=$(INSTALLPATH)/man \
   --infodir=$(INSTALLPATH)/info \
   --without-zlib \
    CFLAGS="-I$(CROSS_LIB_DIR)/include -I$(INSTALLPATH)/include -g -O2" \
    CPPFLAGS="-I$(CROSS_LIB_DIR)/include -I$(INSTALLPATH)/include -g -O2" \
    LDFLAGS=-L$(INSTALLPATH)/lib

$(STATEDIR)/curl.prepare: $(curl_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(CURL_DIR)/config.cache)
	cd $(CURL_DIR) && \
		$(CURL_PATH) $(CURL_ENV) \
		./configure $(CURL_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

curl_compile: $(STATEDIR)/curl.compile

curl_compile_deps = $(STATEDIR)/curl.prepare

$(STATEDIR)/curl.compile: $(curl_compile_deps)
	@$(call targetinfo, $@)
	$(CURL_PATH) make -C $(CURL_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

curl_install: $(STATEDIR)/curl.install

$(STATEDIR)/curl.install: $(STATEDIR)/curl.compile
	@$(call targetinfo, $@)
	$(CURL_PATH) make -C $(CURL_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

curl_targetinstall: $(STATEDIR)/curl.targetinstall

curl_targetinstall_deps = $(STATEDIR)/curl.compile

$(STATEDIR)/curl.targetinstall: $(curl_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

curl_clean:
	rm -rf $(STATEDIR)/curl.*
	rm -rf $(CURL_DIR)

# vim: syntax=make
