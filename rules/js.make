# -*-makefile-*-
# $Id: js.make,v 1.1 2004-05-31 19:45:32 ericn Exp $
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
ifdef CONFIG_JS
PACKAGES += js
endif

#
# Paths and names
#
JS_VERSION	= 1.5.rc6
JS		= js-$(JS_VERSION)
JS_SUFFIX		= tar.gz
JS_URL		= http://ftp.mozilla.org/pub/mozilla.org/js/js-1.5-rc6.tar.gz
JS_SOURCE		= $(CONFIG_ARCHIVEPATH)/js-1.5-rc6.tar.gz
JS_DIR		= $(BUILDDIR)/js
JS_AUTOCFG_PATCH = $(CONFIG_ARCHIVEPATH)/js-1.5-rc6-autocfg.patch
JS_AUTOCFG_PATCH_URL = http://boundarydevices.com/js-1.5-rc6-autocfg.patch

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

js_get: $(STATEDIR)/js.get

js_get_deps = $(JS_SOURCE) $(JS_AUTOCFG_PATCH)

$(STATEDIR)/js.get: $(js_get_deps)
	@$(call targetinfo, $@)
	touch $@

$(JS_SOURCE):
	@$(call targetinfo, $@)
	cd $(CONFIG_ARCHIVEPATH) && wget $(JS_URL)

$(JS_AUTOCFG_PATCH):
	@$(call targetinfo, $@)
	cd $(CONFIG_ARCHIVEPATH) && wget $(JS_AUTOCFG_PATCH_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

js_extract: $(STATEDIR)/js.extract

js_extract_deps = $(STATEDIR)/js.get

$(STATEDIR)/js.extract: $(js_extract_deps)
	@$(call targetinfo, $@)
	rm -rf $(JS_DIR)
	@cd $(BUILDDIR) && gzcat $(JS_SOURCE) | tar -xvf -
	@patch -d $(BUILDDIR) -p0 < $(JS_AUTOCFG_PATCH)
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

js_prepare: $(STATEDIR)/js.prepare

#
# dependencies
#
js_prepare_deps = \
	$(STATEDIR)/js.extract 

JS_PATH	=  PATH=$(TOPDIR)/scripts/:$(CROSS_PATH)
JS_ENV 	=  $(CROSS_ENV)

LINUXCONFIGFILE = $(JS_DIR)/src/config/Linux_All.mk
CONFIGFILE = $(JS_DIR)/src/config.mk

$(STATEDIR)/js.prepare: $(js_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(JS_DIR)/config.cache)
	@perl -i -p -e 's/CC = gcc/CC = $(CONFIG_GNU_TARGET)-gcc/g' $(LINUXCONFIGFILE)
	@perl -i -p -e 's/CCC = g\+\+/CCC = $(CONFIG_GNU_TARGET)-g\+\+/g' $(LINUXCONFIGFILE)
	@perl -i -p -e 's/RANLIB = echo/RANLIB = $(CONFIG_GNU_TARGET)-ranlib/g' $(LINUXCONFIGFILE)
	@perl -i -p -e 's/CPU_ARCH = .*/CPU_ARCH = $(CONFIG_ARCH)/g' $(LINUXCONFIGFILE)
	@perl -i -p -e 's/shell gcc -v/shell \$$\(CC\) -v/g' $(LINUXCONFIGFILE)
	cp $(JS_DIR)/src/jsautocfg_$(CONFIG_ARCH).h $(JS_DIR)/src/jsautocfg.h
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

js_compile: $(STATEDIR)/js.compile

js_compile_deps = $(STATEDIR)/js.prepare

$(STATEDIR)/js.compile: $(js_compile_deps)
	@$(call targetinfo, $@)
	$(JS_PATH) $(CROSS_ENV) BUILD_OPT=1 PREBUILT_CPUCFG=1 make -C $(JS_DIR)/src -f Makefile.ref all
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

js_install: $(STATEDIR)/js.install

$(STATEDIR)/js.install: $(STATEDIR)/js.compile
	@$(call targetinfo, $@)
	@mkdir -p $(INSTALLPATH)/include/js
	@cp -f -R $(JS_DIR)/src/*.h $(INSTALLPATH)/include/js
	@cp -f -R $(JS_DIR)/src/js.msg $(INSTALLPATH)/include/js
	@cp -f -R $(JS_DIR)/src/Linux_All_OPT.OBJ/*.a $(INSTALLPATH)/lib
	touch $@


# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

js_targetinstall: $(STATEDIR)/js.targetinstall

js_targetinstall_deps = $(STATEDIR)/js.compile

$(STATEDIR)/js.targetinstall: $(js_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

js_clean:
	rm -rf $(STATEDIR)/js.*
	rm -rf $(JS_DIR)

# vim: syntax=make
