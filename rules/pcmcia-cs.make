# -*-makefile-*-
# $Id: pcmcia-cs.make,v 1.7 2005-11-23 14:49:43 ericn Exp $
#
# Copyright (C) 2003 by Robert Schwebel <r.schwebel@pengutronix.de>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef CONFIG_PCMCIA_TOOLS
PACKAGES += pcmcia-cs
endif

#
# Paths and names
#
PCMCIA-CS_VERSION	= 3.2.7
PCMCIA-CS		= pcmcia-cs-$(PCMCIA-CS_VERSION)
PCMCIA-CS_SUFFIX	= tar.gz
PCMCIA-CS_URL		= http://pcmcia-cs.sourceforge.net/ftp/$(PCMCIA-CS).$(PCMCIA-CS_SUFFIX)
PCMCIA-CS_SOURCE	= $(CONFIG_ARCHIVEPATH)/$(PCMCIA-CS).$(PCMCIA-CS_SUFFIX)
PCMCIA-CS_DIR		= $(BUILDDIR)/$(PCMCIA-CS)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

pcmcia-cs_get: $(STATEDIR)/pcmcia-cs.get

pcmcia-cs_get_deps	=  $(PCMCIA-CS_SOURCE)
pcmcia-cs_get_deps  +=  $(CONFIG_ARCHIVEPATH)/pcmciaConfig

$(STATEDIR)/pcmcia-cs.get: $(pcmcia-cs_get_deps)
	@$(call targetinfo, $@)
	touch $@

$(PCMCIA-CS_SOURCE):
	@$(call targetinfo, $@)
	cd $(CONFIG_ARCHIVEPATH) && wget $(PCMCIA-CS_URL)

$(CONFIG_ARCHIVEPATH)/pcmciaConfig:
	cd $(CONFIG_ARCHIVEPATH) && wget http://boundarydevices.com/pcmciaConfig

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

pcmcia-cs_extract: $(STATEDIR)/pcmcia-cs.extract

pcmcia-cs_extract_deps	=  $(STATEDIR)/pcmcia-cs.get

$(STATEDIR)/pcmcia-cs.extract: $(pcmcia-cs_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(PCMCIA-CS_DIR))
	cd $(BUILDDIR) && zcat $(PCMCIA-CS_SOURCE) | tar -xvf -
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

pcmcia-cs_prepare: $(STATEDIR)/pcmcia-cs.prepare

#
# dependencies
#
pcmcia-cs_prepare_deps =  \
	$(STATEDIR)/pcmcia-cs.extract 

PCMCIA-CS_PATH	=  PATH=$(CONFIG_PREFIX)/$(CONFIG_GNU_TARGET)/bin:$(CROSS_PATH)
PCMCIA-CS_ENV 	=  $(CROSS_ENV)
#PCMCIA-CS_ENV	+=

$(STATEDIR)/pcmcia-cs.prepare: $(pcmcia-cs_prepare_deps)
	@$(call targetinfo, $@)
	cd $(PCMCIA-CS_DIR) && \
		$(PCMCIA-CS_PATH) \
      ./Configure --noprompt \
      --kcc=$(CONFIG_GNU_TARGET)-gcc \
      --ucc=$(CONFIG_GNU_TARGET)-gcc \
      --kernel=$(CONFIG_KERNELPATH) \
      --target=$(INSTALLPATH) \
      --arch=$(CONFIG_ARCH) \
      --uflags=$(CONFIG_TARGET_CFLAGS) \
      --ld=$(CONFIG_GNU_TARGET)-ld \
      --nox11 \
      --current \
      --nocardbus \
      --srctree 
	sed 's/.*modules clients wireless.*//' <$(PCMCIA-CS_DIR)/Makefile > $(PCMCIA-CS_DIR)/Makefile.patched
	mv $(PCMCIA-CS_DIR)/Makefile $(PCMCIA-CS_DIR)/Makefile.orig
	mv $(PCMCIA-CS_DIR)/Makefile.patched $(PCMCIA-CS_DIR)/Makefile
	sed 's/, arm/, xarmnosa1100/g' <$(PCMCIA-CS_DIR)/modules/Makefile \
	   > $(PCMCIA-CS_DIR)/modules/Makefile.patched
	mv $(PCMCIA-CS_DIR)/modules/Makefile $(PCMCIA-CS_DIR)/modules/Makefile.orig
	mv $(PCMCIA-CS_DIR)/modules/Makefile.patched $(PCMCIA-CS_DIR)/modules/Makefile
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

pcmcia-cs_compile: $(STATEDIR)/pcmcia-cs.compile

pcmcia-cs_compile_deps =  $(STATEDIR)/pcmcia-cs.prepare

$(STATEDIR)/pcmcia-cs.compile: $(pcmcia-cs_compile_deps)
	@$(call targetinfo, $@)
	$(PCMCIA-CS_PATH) $(PCMCIA-CS_ENV) make -C $(PCMCIA-CS_DIR) all modules
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

pcmcia-cs_install: $(STATEDIR)/pcmcia-cs.install

$(STATEDIR)/pcmcia-cs.install: $(STATEDIR)/pcmcia-cs.compile
	@$(call targetinfo, $@)
	$(PCMCIA-CS_PATH) $(PCMCIA-CS_ENV) make -C $(PCMCIA-CS_DIR)/cardmgr install
	$(PCMCIA-CS_PATH) $(PCMCIA-CS_ENV) make -C $(PCMCIA-CS_DIR)/etc install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

pcmcia-cs_targetinstall: $(STATEDIR)/pcmcia-cs.targetinstall

pcmcia-cs_targetinstall_deps	=  $(STATEDIR)/pcmcia-cs.compile

$(STATEDIR)/pcmcia-cs.targetinstall: $(pcmcia-cs_targetinstall_deps)
	@$(call targetinfo, $@)
	cp -fv $(PCMCIA-CS_DIR)/cardmgr/cardmgr $(ROOTDIR)/sbin
	cp -fv $(PCMCIA-CS_DIR)/cardmgr/cardctl $(ROOTDIR)/sbin
	$(PCMCIA-CS_PATH) $(CROSSSTRIP) $(ROOTDIR)/sbin/card*
	mkdir -p $(ROOTDIR)/etc/pcmcia
	cp -fv $(PCMCIA-CS_DIR)/etc/config.opts $(ROOTDIR)/etc/pcmcia
	cp $(CONFIG_ARCHIVEPATH)/pcmciaConfig $(ROOTDIR)/etc/pcmcia/config
	echo "#!/bin/sh" > $(ROOTDIR)/etc/pcmcia/network
	chmod a+x $(ROOTDIR)/etc/pcmcia/network
	cd root/bin && ln -sf ../js/network
	chmod a+rw $(ROOTDIR)/etc/pcmcia/*
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

pcmcia-cs_clean:
	rm -rf $(STATEDIR)/pcmcia-cs.*
	rm -rf $(PCMCIA-CS_DIR)

# vim: syntax=make
