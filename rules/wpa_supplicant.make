# -*-makefile-*-
# $Id: wpa_supplicant.make,v 1.4 2007-07-20 23:56:37 ericn Exp $
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
ifeq (y, $(CONFIG_WPA_SUPPLICANT))
PACKAGES += wpa_supplicant
endif

ECHO?=`which echo`

#
# Paths and names 
#
#WPA_SUPPLICANT			= wpa_supplicant-0.5.7
WPA_SUPPLICANT			= wpa_supplicant-0.5.8
WPA_SUPPLICANT_URL 	= http://hostap.epitest.fi/releases/$(WPA_SUPPLICANT).tar.gz
WPA_SUPPLICANT_SOURCE	= $(CONFIG_ARCHIVEPATH)/$(WPA_SUPPLICANT).tar.gz
WPA_SUPPLICANT_DIR		= $(BUILDDIR)/$(WPA_SUPPLICANT)
WPA_SUPPLICANT_CONFIG = $(CONFIG_ARCHIVEPATH)/wpas_config_20070128
WPA_SUPPLICANT_CONFIG_URL = http://boundarydevices.com/wpas_config_20070128

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

wpa_supplicant_get: $(STATEDIR)/wpa_supplicant.get

$(STATEDIR)/wpa_supplicant.get: $(WPA_SUPPLICANT_SOURCE)
	@$(call targetinfo, $@)
	touch $@

$(WPA_SUPPLICANT_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(WPA_SUPPLICANT_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

wpa_supplicant_extract: $(STATEDIR)/wpa_supplicant.extract

$(WPA_SUPPLICANT_CONFIG):
	@cd $(CONFIG_ARCHIVEPATH) && wget $(WPA_SUPPLICANT_CONFIG_URL)

$(STATEDIR)/wpa_supplicant.extract: $(STATEDIR)/wpa_supplicant.get $(WPA_SUPPLICANT_CONFIG)
	@$(call targetinfo, $@)
	@$(call clean, $(WPA_SUPPLICANT_DIR))
	@cd $(BUILDDIR) && zcat $(WPA_SUPPLICANT_SOURCE) | tar -xvf -
	@cd $(WPA_SUPPLICANT_DIR) && cp -fv $(WPA_SUPPLICANT_CONFIG) .config
	@$(ECHO) -e "\nCC=arm-linux-gcc" >> $(WPA_SUPPLICANT_DIR)/.config
	@$(ECHO) -e CFLAGS += -Os -I$(INSTALLPATH)/include/openssl -I$(INSTALLPATH)/include >> $(WPA_SUPPLICANT_DIR)/.config
	@$(ECHO) -e LIBS += -L$(INSTALLPATH)/lib -lssl >> $(WPA_SUPPLICANT_DIR)/.config
	@$(ECHO) -e LIBS_p += -L$(INSTALLPATH)/lib -lssl >> $(WPA_SUPPLICANT_DIR)/.config
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

wpa_supplicant_prepare: $(STATEDIR)/wpa_supplicant.prepare openssl_install

wpa_supplicant_prepare_deps = \
	$(STATEDIR)/wpa_supplicant.extract

$(STATEDIR)/wpa_supplicant.prepare: $(wpa_supplicant_prepare_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

wpa_supplicant_compile: $(STATEDIR)/wpa_supplicant.compile

$(STATEDIR)/wpa_supplicant.compile: $(STATEDIR)/wpa_supplicant.prepare 
	@$(call targetinfo, $@)
	cd $(WPA_SUPPLICANT_DIR) && $(WPA_SUPPLICANT_PATH) make
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

wpa_supplicant_install: $(STATEDIR)/wpa_supplicant.install

$(STATEDIR)/wpa_supplicant.install: $(STATEDIR)/wpa_supplicant.compile
	@$(call targetinfo, $@)
	install -d $(INSTALLPATH)/include
	for f in wpa_supplicant wpa_passphrase ; do cp -fv $(WPA_SUPPLICANT_DIR)/$$f $(INSTALLPATH)/bin && $(CROSSSTRIP) $(INSTALLPATH)/bin/$$f ; done
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

wpa_supplicant_targetinstall: $(STATEDIR)/wpa_supplicant.targetinstall

$(STATEDIR)/wpa_supplicant.targetinstall: $(STATEDIR)/wpa_supplicant.install
	@$(call targetinfo, $@)
	for f in wpa_supplicant wpa_passphrase ; do cp -fv $(INSTALLPATH)/bin/$$f $(ROOTDIR)/bin ; done
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

wpa_supplicant_clean: 
	rm -rf $(STATEDIR)/wpa_supplicant.* $(WPA_SUPPLICANT_DIR)

# vim: syntax=make
