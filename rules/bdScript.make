# -*-makefile-*-
# $Id: bdScript.make,v 1.45 2010-02-20 15:34:59 ericn Exp $
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
BDSCRIPT_VERSION	= 20100220

ifdef CONFIG_BDSCRIPT_GIT
   BDSCRIPT		= bdScript
else
   BDSCRIPT		= bdScript-$(BDSCRIPT_VERSION)
endif

BDSCRIPT_SUFFIX	= tar.bz2
BDSCRIPT_URL		= http://boundarydevices.com/$(BDSCRIPT).$(BDSCRIPT_SUFFIX)
BDSCRIPT_SOURCE	= $(CONFIG_ARCHIVEPATH)/$(BDSCRIPT).$(BDSCRIPT_SUFFIX)
BDSCRIPT_DIR		= $(BUILDDIR)/bdScript

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

ifdef CONFIG_BDSCRIPT_GIT
   bdScript_get: $(STATEDIR)/bdScript.get

   $(STATEDIR)/bdScript.get:
		@$(call targetinfo, $@)
		mkdir -p $(BUILDDIR) $(STATEDIR)
		cd $(BUILDDIR) && git-clone git.boundarydevices.com:/repository/bdScript
		touch $@

else
   bdScript_get: $(STATEDIR)/bdScript.get
   bdScript_get_deps = $(BDSCRIPT_SOURCE) 

   $(STATEDIR)/bdScript.get: $(bdScript_get_deps)
		@$(call targetinfo, $@)
		touch $@

   $(BDSCRIPT_SOURCE):
		@$(call targetinfo, $@)
		cd $(CONFIG_ARCHIVEPATH) && wget $(BDSCRIPT_URL)
endif

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

bdScript_extract: $(STATEDIR)/bdScript.extract

bdScript_extract_deps = $(STATEDIR)/bdScript.get

ifdef CONFIG_BDSCRIPT_GIT
   $(STATEDIR)/bdScript.extract: $(bdScript_extract_deps)
		@$(call targetinfo, $@)
		touch $@
else
   $(STATEDIR)/bdScript.extract: $(bdScript_extract_deps)
		@$(call targetinfo, $@)
		@$(call clean, $(BDSCRIPT_DIR))
		@cd $(BUILDDIR) && bzcat $(BDSCRIPT_SOURCE) | tar -xvf -
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
         >>$(BDSCRIPT_DIR)/config.h ;
	grep -e "CONFIG_" $(TOPDIR)/.config \
         >$(BDSCRIPT_DIR)/config.mk ;
	cat $(TOPDIR)/.kernelconfig \
        >>$(BDSCRIPT_DIR)/config.mk ;
	/bin/echo -e "\n\n#\n#Build directory\n#\nBUILDDIR=$(BUILDDIR)/" \
        >>$(BDSCRIPT_DIR)/config.mk
ifndef CONFIG_BDSCRIPT_GIT
	touch $(BDSCRIPT_DIR)/.git
endif
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
bdScript_compile_deps += $(STATEDIR)/libpng.install
ifdef CONFIG_LIBMPEG2
bdScript_compile_deps += $(STATEDIR)/mpeg2dec.install
endif
bdScript_compile_deps += $(STATEDIR)/openssl.install
ifdef CONFIG_PCMCIA
ifdef CONFIG_LINUX_WLAN_NG
bdScript_compile_deps += $(STATEDIR)/linux-wlan-ng.install
endif
endif
bdScript_compile_deps += $(STATEDIR)/mad.install
bdScript_compile_deps += $(STATEDIR)/libusb.install

$(STATEDIR)/bdScript.compile: $(bdScript_compile_deps)
	@$(call targetinfo, $@)
	echo "install root is $(INSTALLPATH)"
	$(CROSS_ENV) \
        CROSS_COMPILE=$(CONFIG_GNU_TARGET)- \
   INSTALL_ROOT=$(INSTALLPATH) TOOLCHAINROOT=$(CROSS_LIB_DIR) $(BDSCRIPT_PATH) make -C $(BDSCRIPT_DIR) all
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

bdScript_install: $(STATEDIR)/bdScript.install

$(STATEDIR)/bdScript.install: $(STATEDIR)/bdScript.compile
	@$(call targetinfo, $@)
	INSTALL_ROOT=$(INSTALLPATH) CROSS_COMPILE=$(CONFIG_GNU_TARGET)- \
           $(BDSCRIPT_PATH) make -C $(BDSCRIPT_DIR) install
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
	cp $(BDSCRIPT_DIR)/daemonize $(ROOTDIR)/bin
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

bdScript_clean:
	rm -rf $(STATEDIR)/bdScript.*
	rm -rf $(BDSCRIPT_DIR)
	rm -f $(ROOTDIR)/bin/jsExec
	rm -f $(ROOTDIR)/bin/network   
	rm -f $(ROOTDIR)/bin/jsMenu
	rm -f $(ROOTDIR)/bin/flashVar
	rm -rf $(ROOTDIR)/js

# vim: syntax=make
