# -*-makefile-*-
# $Id: wireless_tools.make,v 1.2 2008-12-21 20:19:48 ericn Exp $
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
ifeq (y, $(CONFIG_WIRELESS_TOOLS))
PACKAGES += wireless_tools
endif

#
# Paths and names 
#
WIRELESS_TOOLS			   = wireless_tools.29
WIRELESS_TOOLS_URL 	   = http://www.hpl.hp.com/personal/Jean_Tourrilhes/Linux/$(WIRELESS_TOOLS).tar.gz
WIRELESS_TOOLS_SOURCE	= $(CONFIG_ARCHIVEPATH)/$(WIRELESS_TOOLS).tar.gz
WIRELESS_TOOLS_DIR		= $(BUILDDIR)/$(WIRELESS_TOOLS)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

wireless_tools_get: $(STATEDIR)/wireless_tools.get

$(STATEDIR)/wireless_tools.get: $(WIRELESS_TOOLS_SOURCE)
	@$(call targetinfo, $@)
	touch $@

$(WIRELESS_TOOLS_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(WIRELESS_TOOLS_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

wireless_tools_extract: $(STATEDIR)/wireless_tools.extract

$(STATEDIR)/wireless_tools.extract: $(STATEDIR)/wireless_tools.get
	@$(call targetinfo, $@)
	@$(call clean, $(WIRELESS_TOOLS_DIR))
	@cd $(BUILDDIR) && zcat $(WIRELESS_TOOLS_SOURCE) | tar -xvf -
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

wireless_tools_prepare: $(STATEDIR)/wireless_tools.prepare

wireless_tools_prepare_deps = \
	$(STATEDIR)/wireless_tools.extract

WIRELESS_TOOLS_PATH	=  PATH=$(CROSS_PATH)
WIRELESS_TOOLS_AUTOCONF 	= --prefix=$(INSTALLPATH) 

ifdef CONFIG_WIRELESS_TOOLS_SHARED
   WIRELESS_TOOLS_AUTOCONF 	+=  --shared
else
endif

INSTALLPATH_ESCAPED = $(subst /,\/, $(INSTALLPATH))

$(STATEDIR)/wireless_tools.prepare: $(wireless_tools_prepare_deps)
	@$(call targetinfo, $@)
	perl -i -p -e 's/\/usr\/local/$(INSTALLPATH_ESCAPED)/g' $(WIRELESS_TOOLS_DIR)/Makefile
	perl -i -p -e 's/= ar/= $(CONFIG_GNU_TARGET)-ar/g' $(WIRELESS_TOOLS_DIR)/Makefile
	perl -i -p -e 's/= gcc/= $(CONFIG_GNU_TARGET)-gcc/g' $(WIRELESS_TOOLS_DIR)/Makefile
	perl -i -p -e 's/= ranlib/= $(CONFIG_GNU_TARGET)-ranlib/g' $(WIRELESS_TOOLS_DIR)/Makefile
	perl -i -p -e 's/# BUILD_STRIP/BUILD_STRIP/g' $(WIRELESS_TOOLS_DIR)/Makefile
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

wireless_tools_compile: $(STATEDIR)/wireless_tools.compile

$(STATEDIR)/wireless_tools.compile: $(STATEDIR)/wireless_tools.prepare 
	@$(call targetinfo, $@)
	cd $(WIRELESS_TOOLS_DIR) && $(WIRELESS_TOOLS_PATH) make
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

wireless_tools_install: $(STATEDIR)/wireless_tools.install

$(STATEDIR)/wireless_tools.install: $(STATEDIR)/wireless_tools.compile
	@$(call targetinfo, $@)
	cd $(WIRELESS_TOOLS_DIR) && cp -fv iwconfig iwlist iwpriv iwspy iwgetid iwevent $(INSTALLPATH)/bin
	cd $(WIRELESS_TOOLS_DIR) && cp -fv *.so* $(INSTALLPATH)/lib
	cd $(INSTALLPATH)/lib && ln -sf libiw.so.28 libiw.so
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

wireless_tools_targetinstall: $(STATEDIR)/wireless_tools.targetinstall

$(STATEDIR)/wireless_tools.targetinstall: $(STATEDIR)/wireless_tools.install
	@$(call targetinfo, $@)
	cd $(WIRELESS_TOOLS_DIR) && cp -fv iwconfig iwlist iwpriv iwspy iwgetid iwevent $(ROOTDIR)/bin
	cd $(WIRELESS_TOOLS_DIR) && cp -fv *.so* $(ROOTDIR)/lib
	cd $(ROOTDIR)/lib && ln -sf libiw.so.28 libiw.so
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

wireless_tools_clean: 
	rm -rf $(STATEDIR)/wireless_tools.* $(WIRELESS_TOOLS_DIR)

# vim: syntax=make
