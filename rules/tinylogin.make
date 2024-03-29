# -*-makefile-*-
# $Id: tinylogin.make,v 1.12 2008-12-21 20:20:24 ericn Exp $
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
ifdef CONFIG_TINYLOGIN
PACKAGES += tinylogin
endif

#
# Paths and names
#
TINYLOGIN_VERSION	= 1.4
TINYLOGIN		= tinylogin-$(TINYLOGIN_VERSION)
TINYLOGIN_SUFFIX		= tar.gz
TINYLOGIN_URL		= http://tinylogin.busybox.net/downloads//$(TINYLOGIN).$(TINYLOGIN_SUFFIX)
TINYLOGIN_SOURCE		= $(CONFIG_ARCHIVEPATH)/$(TINYLOGIN).$(TINYLOGIN_SUFFIX)
TINYLOGIN_DIR		= $(BUILDDIR)/$(TINYLOGIN)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

tinylogin_get: $(STATEDIR)/tinylogin.get

tinylogin_get_deps = $(TINYLOGIN_SOURCE)

$(STATEDIR)/tinylogin.get: $(tinylogin_get_deps)
	@$(call targetinfo, $@)
	touch $@

$(TINYLOGIN_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(TINYLOGIN_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

tinylogin_extract: $(STATEDIR)/tinylogin.extract

tinylogin_extract_deps = $(STATEDIR)/tinylogin.get

$(STATEDIR)/tinylogin.extract: $(tinylogin_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(TINYLOGIN_DIR))
	@cd $(BUILDDIR) && zcat $(TINYLOGIN_SOURCE) | tar -xvf -
	sed 's/USE_SYSTEM_PWD_GRP = true/USE_SYSTEM_PWD_GRP = false/' <$(TINYLOGIN_DIR)/Makefile >$(TINYLOGIN_DIR)/Makefile.patched
	mv $(TINYLOGIN_DIR)/Makefile $(TINYLOGIN_DIR)/Makefile.orig
	mv $(TINYLOGIN_DIR)/Makefile.patched $(TINYLOGIN_DIR)/Makefile
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

tinylogin_prepare: $(STATEDIR)/tinylogin.prepare

#
# dependencies
#
tinylogin_prepare_deps = \
	$(STATEDIR)/tinylogin.extract 

TINYLOGIN_PATH	=  PATH=$(CROSS_PATH)
TINYLOGIN_ENV 	=  $(CROSS_ENV)
#TINYLOGIN_ENV	+=

#
# autoconf
#
TINYLOGIN_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=$(CROSS_LIB_DIR)

$(STATEDIR)/tinylogin.prepare: $(tinylogin_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(TINYLOGIN_DIR)/config.cache)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

tinylogin_compile: $(STATEDIR)/tinylogin.compile

tinylogin_compile_deps = $(STATEDIR)/tinylogin.prepare

$(STATEDIR)/tinylogin.compile: $(tinylogin_compile_deps)
	@$(call targetinfo, $@)
	$(TINYLOGIN_PATH) \
   $(TINYLOGIN_ENV) make -C $(TINYLOGIN_DIR) CROSS=$(CONFIG_CROSSPREFIX)- all
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

tinylogin_install: $(STATEDIR)/tinylogin.install

$(STATEDIR)/tinylogin.install: $(STATEDIR)/tinylogin.compile
	@$(call targetinfo, $@)
	$(TINYLOGIN_PATH) sudo make -C $(TINYLOGIN_DIR) CROSS=$(CONFIG_CROSSPREFIX) PREFIX=$(INSTALLPATH) install
	sudo chmod a+rw $(INSTALLPATH)/usr/bin
	sudo chmod a+rw $(INSTALLPATH)/usr/bin/*
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

tinylogin_targetinstall: $(STATEDIR)/tinylogin.targetinstall

tinylogin_targetinstall_deps = $(STATEDIR)/tinylogin.compile

CRYPT_SALT = dP
PASSWORD_STRING = $(shell perl -e 'print crypt($(CONFIG_ROOTPASSWORD), "$(CRYPT_SALT)"),"\n"')

$(STATEDIR)/tinylogin.targetinstall: $(tinylogin_targetinstall_deps)
	@$(call targetinfo, $@)
	@$(TINYLOGIN_PATH) sudo make -C $(TINYLOGIN_DIR) CROSS=$(CONFIG_CROSSPREFIX) PREFIX=$(ROOTDIR) install
	sudo chmod a+rw $(ROOTDIR)/usr/bin
	sudo chmod a+rw $(ROOTDIR)/usr/bin/*
	@mkdir -p $(ROOTDIR)/etc
	@echo "root:$(PASSWORD_STRING):0:0:Linux User,,,:/:/bin/sh" > $(ROOTDIR)/etc/passwd
	@echo "audio:x:1000:1000:Audio Pseudo-User,,,:/:/bin/false" >> $(ROOTDIR)/etc/passwd
	@echo "root:x:0" > $(ROOTDIR)/etc/group
	@echo "audio:x:1000" >> $(ROOTDIR)/etc/group
ifdef CONFIG_OPENSSH
	@echo "sshd:x:1:" >> $(ROOTDIR)/etc/group
	@echo "sshd:x:1:1:sshd:/:/bin/false" >> $(ROOTDIR)/etc/passwd
endif
	@touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

tinylogin_clean:
	rm -rf $(STATEDIR)/tinylogin.*
	rm -rf $(TINYLOGIN_DIR)

# vim: syntax=make
