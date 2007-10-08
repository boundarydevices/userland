# -*-makefile-*-
# $Id: xvid.make,v 1.4 2007-10-08 21:06:10 ericn Exp $
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
ifdef CONFIG_LIBXVID
PACKAGES += xvid
endif

#
# Paths and names
#

XVID_VERSION   = 1.1.2
XVID	         = xvidcore-$(XVID_VERSION)
XVID_SUFFIX	   = tar.gz
XVID_URLDIR    = http://downloads.xvid.org/downloads
XVID_URL		   = $(XVID_URLDIR)/$(XVID).$(XVID_SUFFIX)
XVID_SOURCE	   = $(CONFIG_ARCHIVEPATH)/$(XVID).$(XVID_SUFFIX)
XVID_DIR		   = $(BUILDDIR)/$(XVID)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xvid_get: $(STATEDIR)/xvid.get

xvid_get_deps = $(XVID_SOURCE) 

$(STATEDIR)/xvid.get: $(xvid_get_deps)
	@$(call targetinfo, $@)
	touch $@

$(XVID_SOURCE):
	@$(call targetinfo, $@)
	cd $(CONFIG_ARCHIVEPATH) && wget $(XVID_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xvid_extract: $(STATEDIR)/xvid.extract

xvid_extract_deps = $(STATEDIR)/xvid.get

$(STATEDIR)/xvid.extract: $(xvid_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XVID_DIR))
	@cd $(BUILDDIR) && zcat $(XVID_SOURCE) | tar -xvf -
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xvid_prepare: $(STATEDIR)/xvid.prepare

#
# dependencies
#
xvid_prepare_deps = \
	$(STATEDIR)/xvid.extract 

XVID_PATH	=  PATH=$(CROSS_PATH):$(XVID_DIR)/misc/xvid-config
XVID_ENV 	=  $(CROSS_ENV)
#XVID_ENV	+=

#
# autoconf
#
XVID_AUTOCONF = \
	--host=$(CONFIG_GNU_HOST) \
	--prefix=$(CROSS_LIB_DIR) \
   --enable-shared=no \
   --enable-static=yes \
   --exec-prefix=$(INSTALLPATH) \
   --includedir=$(INSTALLPATH)/include

$(STATEDIR)/xvid.prepare: $(xvid_prepare_deps)
	@$(call targetinfo, $@)
	cd $(XVID_DIR)/build/generic && \
		$(XVID_PATH) $(XVID_ENV) \
      ./bootstrap.sh && \
		$(XVID_PATH) $(XVID_ENV) \
		./configure $(XVID_AUTOCONF)
	touch $@

#
#	cd $(XVID_DIR) && ./bootstrap
# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xvid_compile: $(STATEDIR)/xvid.compile

xvid_compile_deps = $(STATEDIR)/xvid.prepare

$(STATEDIR)/xvid.compile: $(xvid_compile_deps)
	@$(call targetinfo, $@)
	$(XVID_PATH) \
   make -C $(XVID_DIR)/build/generic
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xvid_install: $(STATEDIR)/xvid.install

$(STATEDIR)/xvid.install: $(STATEDIR)/xvid.compile
	@$(call targetinfo, $@)
	$(XVID_PATH) make -C $(XVID_DIR)/build/generic install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xvid_targetinstall: $(STATEDIR)/xvid.targetinstall

xvid_targetinstall_deps = $(STATEDIR)/xvid.compile

$(STATEDIR)/xvid.targetinstall: $(xvid_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xvid_clean:
	rm -rf $(STATEDIR)/xvid.*
	rm -rf $(XVID_DIR)

# vim: syntax=make
