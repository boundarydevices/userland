# -*-makefile-*-
# $Id: bdScript.make,v 1.12 2004-09-26 16:11:00 ericn Exp $
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
ifdef CONFIG_BDSCRIPT
PACKAGES += bdScript
endif

#
# Paths and names
#
BDSCRIPT_VERSION	= 2.0.0

ifdef CONFIG_BDSCRIPT_CVS
   BDSCRIPT		= bdScript
else
   BDSCRIPT		= bdScript-$(BDSCRIPT_VERSION)
endif

BDSCRIPT_SUFFIX	= tar.bz2
BDSCRIPT_URL		= http://boundarydevices.com/$(BDSCRIPT).$(BDSCRIPT_SUFFIX)
BDSCRIPT_SOURCE	= $(CONFIG_ARCHIVEPATH)/$(BDSCRIPT).$(BDSCRIPT_SUFFIX)
BDSCRIPT_DIR		= $(BUILDDIR)/$(BDSCRIPT)

BDSCRIPT_SCRIPT_URL     = http://boundarydevices.com/jsFiles.tar.gz
BDSCRIPT_SCRIPT_SOURCE	= $(CONFIG_ARCHIVEPATH)/jsFiles.tar.gz
BDSCRIPT_SCRIPT_DIR		= $(BUILDDIR)/jsFiles

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

ifdef CONFIG_BDSCRIPT_CVS
   bdScript_get: $(STATEDIR)/bdScript.get

   $(STATEDIR)/bdScript.get:
		@$(call targetinfo, $@)
		cd $(BUILDDIR) && cvs checkout bdScript
		cd $(BUILDDIR) && cvs checkout sampleScripts
ifdef CONFIG_BDSCRIPT_BIGDEMO
		cd $(BUILDDIR) && cvs checkout ticketing
		cd $(BUILDDIR) && cvs checkout myPalDemo
else
ifdef CONFIG_SUITEDEMO
		cd $(BUILDDIR) && cvs checkout suiteDemo
else
		echo "No application selected"
endif      
endif      
		touch $@

else
   bdScript_get: $(STATEDIR)/bdScript.get

   bdScript_get_deps = $(BDSCRIPT_SOURCE) 

ifdef CONFIG_BDSCRIPT_BIGDEMO   
   bdScript_get_deps += $(BDSCRIPT_SCRIPT_SOURCE)
endif

   $(STATEDIR)/bdScript.get: $(bdScript_get_deps)
		@$(call targetinfo, $@)
		touch $@

   $(BDSCRIPT_SOURCE):
		@$(call targetinfo, $@)
		cd $(CONFIG_ARCHIVEPATH) && wget $(BDSCRIPT_URL)
   $(BDSCRIPT_SCRIPT_SOURCE):
		@$(call targetinfo, $@)
		cd $(CONFIG_ARCHIVEPATH) && wget $(BDSCRIPT_SCRIPT_URL)
   
endif

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

bdScript_extract: $(STATEDIR)/bdScript.extract

bdScript_extract_deps = $(STATEDIR)/bdScript.get

ifdef CONFIG_BDSCRIPT_CVS
   $(STATEDIR)/bdScript.extract: $(bdScript_extract_deps)
		@$(call targetinfo, $@)
		touch $@
else
   $(STATEDIR)/bdScript.extract: $(bdScript_extract_deps)
		@$(call targetinfo, $@)
		@$(call clean, $(BDSCRIPT_DIR))
		@cd $(BUILDDIR) && gzcat $(BDSCRIPT_SOURCE) | tar -xvf -
		touch $@
endif

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

bdScript_prepare: $(STATEDIR)/bdScript.prepare

#
# dependencies
#
bdScript_prepare_deps = \
	$(STATEDIR)/bdScript.extract 

BDSCRIPT_PATH	=  PATH=$(CROSS_PATH)
BDSCRIPT_ENV 	=  $(CROSS_ENV)
#BDSCRIPT_ENV	+=

#
# no autoconf (yet)
#

$(STATEDIR)/bdScript.prepare: $(bdScript_prepare_deps)
	@$(call targetinfo, $@)
	grep -e "CONFIG_" $(TOPDIR)/.config \
   | sed -e 's/# //'          \
         -e 's/^/#define /'   \
         -e 's/=y/ 1/'        \
         -e 's/is not set/0/' \
         -e 's/=\(.*\)/ \1/' \
         >$(BDSCRIPT_DIR)/config.h
	grep -e "CONFIG_\|KERNEL_" $(TOPDIR)/.kernelconfig \
   | sed -e 's/# //'          \
         -e 's/^/#define /'   \
         -e 's/=y/ 1/'        \
         -e 's/is not set/0/' \
         -e 's/=\(.*\)/ \1/' \
         >>$(BDSCRIPT_DIR)/config.h
	grep -e "CONFIG_" $(TOPDIR)/.config \
         >$(BDSCRIPT_DIR)/config.mk
	cat $(TOPDIR)/.kernelconfig \
        >>$(BDSCRIPT_DIR)/config.mk
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

bdScript_compile: $(STATEDIR)/bdScript.compile

bdScript_compile_deps = $(STATEDIR)/bdScript.prepare
bdScript_compile_deps += $(STATEDIR)/curl.install
bdScript_compile_deps += $(STATEDIR)/js.install
bdScript_compile_deps += $(STATEDIR)/libflash.install
bdScript_compile_deps += $(STATEDIR)/freetype.install
bdScript_compile_deps += $(STATEDIR)/libungif.install
bdScript_compile_deps += $(STATEDIR)/libpng125.install
bdScript_compile_deps += $(STATEDIR)/mpeg2dec.install
bdScript_compile_deps += $(STATEDIR)/openssl.install
bdScript_compile_deps += $(STATEDIR)/linux-wlan-ng.install
bdScript_compile_deps += $(STATEDIR)/mad.install
bdScript_compile_deps += $(STATEDIR)/libusb.install

$(STATEDIR)/bdScript.compile: $(bdScript_compile_deps)
	@$(call targetinfo, $@)
	echo "install root is $(INSTALLPATH)"
	INSTALL_ROOT=$(INSTALLPATH) TOOLCHAINROOT=$(CROSS_LIB_DIR) $(BDSCRIPT_PATH) make -C $(BDSCRIPT_DIR) all
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

bdScript_install: $(STATEDIR)/bdScript.install

$(STATEDIR)/bdScript.install: $(STATEDIR)/bdScript.compile
	@$(call targetinfo, $@)
	INSTALL_ROOT=$(INSTALLPATH) $(BDSCRIPT_PATH) make -C $(BDSCRIPT_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

bdScript_targetinstall: $(STATEDIR)/bdScript.targetinstall

bdScript_targetinstall_deps = $(STATEDIR)/bdScript.compile

$(STATEDIR)/bdScript.targetinstall: $(bdScript_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(ROOTDIR)/bin
	cp $(BDSCRIPT_DIR)/jsExec $(ROOTDIR)/bin
	cp $(BDSCRIPT_DIR)/flashVar $(ROOTDIR)/bin
	cp $(BDSCRIPT_DIR)/wget $(ROOTDIR)/bin && chmod a+x $(ROOTDIR)/bin/wget
	mkdir -p $(ROOTDIR)/js
	mkdir -p $(ROOTDIR)/js/images
	mkdir -p $(ROOTDIR)/js/fonts
	cp $(BUILDDIR)/sampleScripts/network $(ROOTDIR)/js/ && chmod a+x $(ROOTDIR)/js/network
	cd $(ROOTDIR)/bin && ln -sf ../js/network
	cp $(BUILDDIR)/sampleScripts/wlan.js $(ROOTDIR)/js/
	cp $(BUILDDIR)/sampleScripts/network.js $(ROOTDIR)/js/
	cp $(BUILDDIR)/sampleScripts/dump.js $(ROOTDIR)/js/
	cp $(BUILDDIR)/sampleScripts/dhcp $(ROOTDIR)/js/ && chmod a+x $(ROOTDIR)/js/dhcp
ifdef CONFIG_BDSCRIPT_BIGDEMO
	cp -rv $(BUILDDIR)/ticketing/* $(ROOTDIR)/js/
	cp -rv $(BUILDDIR)/myPalDemo/* $(ROOTDIR)/js/
	cp -rv $(BUILDDIR)/sampleScripts/* $(ROOTDIR)/js/
else
ifdef CONFIG_SUITEDEMO
	cp -rv $(BUILDDIR)/suiteDemo/* $(ROOTDIR)/js/
else
endif      
endif      
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

bdScript_clean:
	rm -rf $(BUILDDIR)/ticketing
	rm -rf $(BUILDDIR)/myPalDemo
	rm -rf $(BUILDDIR)/sampleScripts
	rm -rf $(BUILDDIR)/suiteDemo
	rm -rf $(STATEDIR)/bdScript.*
	rm -rf $(BDSCRIPT_DIR)
	rm -f $(ROOTDIR)/bin/jsExec
	rm -f $(ROOTDIR)/bin/network   
	rm -f $(ROOTDIR)/bin/jsMenu
	rm -f $(ROOTDIR)/bin/flashVar
	rm -f $(ROOTDIR)/bin/wget
	rm -rf $(ROOTDIR)/js

# vim: syntax=make
