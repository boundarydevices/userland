# -*-makefile-*-
# $Id: DirectFB-examples.make,v 1.2 2007-07-27 22:10:28 ericn Exp $
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
ifeq (y, $(CONFIG_DIRECTFB_EXAMPLES))
PACKAGES += directfb_examples
endif

#
# Paths and names 
#
DIRECTFB_EXAMPLES = DirectFB-examples-2007-07-26-04-25-15-UTC
DIRECTFB_EXAMPLES_URL = http://boundarydevices.com/archives/$(DIRECTFB_EXAMPLES).tar.gz
DIRECTFB_EXAMPLES_SOURCE = $(CONFIG_ARCHIVEPATH)/$(DIRECTFB_EXAMPLES).tar.gz
DIRECTFB_EXAMPLES_DIR = $(BUILDDIR)/$(DIRECTFB_EXAMPLES)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

directfb_examples_get: $(STATEDIR)/directfb_examples.get

$(STATEDIR)/directfb_examples.get: $(DIRECTFB_EXAMPLES_SOURCE)
	@$(call targetinfo, $@)
	touch $@

$(DIRECTFB_EXAMPLES_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(DIRECTFB_EXAMPLES_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

directfb_examples_extract: $(STATEDIR)/directfb_examples.extract

$(STATEDIR)/directfb_examples.extract: $(STATEDIR)/directfb_examples.get
	@$(call targetinfo, $@)
	@$(call clean, $(DIRECTFB_EXAMPLES_DIR))
	@cd $(BUILDDIR) && zcat $(DIRECTFB_EXAMPLES_SOURCE) | tar -xvf -
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

directfb_examples_prepare: $(STATEDIR)/directfb_examples.prepare $(STATEDIR)/JPEG.install

directfb_examples_prepare_deps = \
	$(STATEDIR)/directfb_examples.extract

DIRECTFB_EXAMPLES_PATH	=  PATH=$(CROSS_PATH)
DIRECTFB_EXAMPLES_AUTOCONF = --host=$(CONFIG_GNU_TARGET)

CONFIG_DIRECTFB_EXAMPLES_SHARED = 1
ifdef CONFIG_DIRECTFB_EXAMPLES_SHARED
   DIRECTFB_EXAMPLES_AUTOCONF 	+=  --enable-shared=yes
else
   DIRECTFB_EXAMPLES_AUTOCONF 	+=  --enable-shared=no
   DIRECTFB_EXAMPLES_AUTOCONF 	+=  --enable-static=yes
endif


$(STATEDIR)/directfb_examples.prepare: $(directfb_examples_prepare_deps)
	@$(call targetinfo, $@)
	cd $(DIRECTFB_EXAMPLES_DIR) && aclocal && autoconf && automake --add-missing
	cd $(DIRECTFB_EXAMPLES_DIR) && \
		$(DIRECTFB_EXAMPLES_PATH) \
      $(CROSS_ENV) \
      CFLAGS=-I$(INSTALLPATH)/include \
      CPPFLAGS=-I$(INSTALLPATH)/include \
      LDFLAGS=-L$(INSTALLPATH)/lib \
      LIBS=" -lz -lm " \
      ./configure $(DIRECTFB_EXAMPLES_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

directfb_examples_compile: $(STATEDIR)/directfb_examples.compile

$(STATEDIR)/directfb_examples.compile: $(STATEDIR)/directfb_examples.prepare 
	@$(call targetinfo, $@)
	cd $(DIRECTFB_EXAMPLES_DIR) && $(DIRECTFB_EXAMPLES_PATH) $(CROSS_ENV) make
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

directfb_examples_install: $(STATEDIR)/directfb_examples.install

$(STATEDIR)/directfb_examples.install: $(STATEDIR)/directfb_examples.compile
	@$(call targetinfo, $@)
	cd $(DIRECTFB_EXAMPLES_DIR) && \
        DESTDIR=$(INSTALLPATH) \
        make install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

directfb_examples_targetinstall: $(STATEDIR)/directfb_examples.targetinstall

$(STATEDIR)/directfb_examples.targetinstall: $(STATEDIR)/directfb_examples.install
	@$(call targetinfo, $@)
	cd $(DIRECTFB_EXAMPLES_DIR) && \
        DESTDIR=$(ROOTDIR) \
        make install
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

directfb_examples_clean: 
	rm -rf $(STATEDIR)/directfb_examples.* $(DIRECTFB_EXAMPLES_DIR)

# vim: syntax=make
