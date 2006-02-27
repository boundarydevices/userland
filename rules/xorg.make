# -*-makefile-*-
# $Id: xorg.make,v 1.2 2006-02-27 00:48:12 ericn Exp $
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
ifeq (y, $(CONFIG_XORG))
PACKAGES += xorg
endif

#
# Paths and names 
#
XORG		= x7.0
XORG_DATE	= 20060123
XORG_TARBALL    = $(XORG)-$(XORG_DATE).tar.gz
XORG_URL 	= http://boundarydevices.com/$(XORG_TARBALL)
XORG_SOURCE	= $(CONFIG_ARCHIVEPATH)/$(XORG_TARBALL)
XORG_DIR	= $(BUILDDIR)/$(XORG)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xorg_get: $(STATEDIR)/xorg.get

$(XORG_SOURCE): 
	cd $(CONFIG_ARCHIVEPATH) && wget $(XORG_URL)

$(STATEDIR)/xorg.get: $(XORG_SOURCE)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xorg_extract: $(STATEDIR)/xorg.extract

$(STATEDIR)/xorg.extract: $(STATEDIR)/xorg.get
	@$(call targetinfo, $@)
	@$(call clean, $(XORG_DIR))
	@cd $(BUILDDIR) && tar -zxvf $(XORG_SOURCE)
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xorg_prepare: $(STATEDIR)/xorg.prepare

XORG_ENV = $(CROSS_ENV)
XORG_ENV += PKG_CONFIG_PATH=$(PKG_CONFIG_PATH):$(INSTALLPATH)/lib/pkgconfig:$(XORG_DIR)/Xproto
XORG_INCLDIRS = $(subst ",,-I$(INSTALLPATH)/include -I$(CONFIG_TOOLCHAINPATH)$(CONFIG_CROSSPREFIX)/include)
XORG_ENV += CFLAGS='$(CFLAGS) $(XORG_INCLDIRS) '
XORG_LIBDIRS = $(subst ",,-L$(CONFIG_TOOLCHAINPATH)$(CONFIG_CROSSPREFIX)/lib -L$(INSTALLPATH)/lib)
XORG_ENV += LDFLAGS='$(LDFLAGS) $(XORG_LIBDIRS) '
XORG_AUTOGEN = --prefix=$(INSTALLPATH)/ --host=$(CONFIG_CROSSPREFIX)

$(STATEDIR)/xorg.prepare: $(STATEDIR)/xorg.extract
	@$(call targetinfo, $@)
	pushd $(XORG_DIR)/Xproto && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd
	pushd $(XORG_DIR)/Xdmcp && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd
	pushd $(XORG_DIR)/XExtensions && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd
	pushd $(XORG_DIR)/xtrans && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd
	pushd $(XORG_DIR)/Xau && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd
	pushd $(XORG_DIR)/X11 && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd
	pushd $(XORG_DIR)/Xext && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd
	pushd $(XORG_DIR)/Randr && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd
	pushd $(XORG_DIR)/Render && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd
	pushd $(XORG_DIR)/Xrender && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd
	pushd $(XORG_DIR)/Xrandr && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd
	pushd $(XORG_DIR)/FixesExt && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd
	pushd $(XORG_DIR)/DamageExt && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd
	pushd $(XORG_DIR)/Xfont && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd
	pushd $(XORG_DIR)/ResourceExt && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd
	pushd $(XORG_DIR)/RecordExt && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd
	pushd $(XORG_DIR)/CompositeExt && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd
	pushd $(XORG_DIR)/xkbfile && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd 
	pushd $(XORG_DIR)/randrproto-1.1.2/ && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd
	pushd $(XORG_DIR)/renderproto-0.9.2/ && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd
	pushd $(XORG_DIR)/fixesproto-3.0.2/ && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd
	pushd $(XORG_DIR)/damageproto-1.0.3/ && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd
	pushd $(XORG_DIR)/xextproto-7.0.2/ && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd
	pushd $(XORG_DIR)/compositeproto-0.2.2/ && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd
	pushd $(XORG_DIR)/recordproto-X11R7.0-1.13.2/ && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd
	pushd $(XORG_DIR)/resourceproto-X11R7.0-1.0.2/ && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd
	pushd $(XORG_DIR)/xineramaproto-X11R7.0-1.1.2/ && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd
	pushd $(XORG_DIR)/xserver && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd
	perl -pi -e 's/ephyr//' $(XORG_DIR)/xserver/hw/kdrive/Makefile
	pushd $(XORG_DIR)/Xfixes && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd
	pushd $(XORG_DIR)/Xcomposite && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd
	pushd $(XORG_DIR)/Xdamage && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd
	touch $@


# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xorg_compile: $(STATEDIR)/xorg.compile

$(STATEDIR)/xorg.compile: $(STATEDIR)/xorg.prepare 
	@$(call targetinfo, $@)
	pushd $(XORG_DIR)/Xproto && $(XORG_ENV) make && popd
	pushd $(XORG_DIR)/Xdmcp && $(XORG_ENV) make && popd
	pushd $(XORG_DIR)/XExtensions && $(XORG_ENV) make && popd
	pushd $(XORG_DIR)/xtrans && $(XORG_ENV) make && popd
	pushd $(XORG_DIR)/Xau && $(XORG_ENV) make && popd
	pushd $(XORG_DIR)/X11/src/util && $(XORG_ENV) make && popd
	pushd $(XORG_DIR)/X11/src/util && $(XORG_ENV) make install && popd
	pushd $(XORG_DIR)/X11 && $(XORG_ENV) make && popd
	pushd $(XORG_DIR)/Xext && $(XORG_ENV) make && popd
	pushd $(XORG_DIR)/Randr && $(XORG_ENV) make && popd
	pushd $(XORG_DIR)/Render && $(XORG_ENV) make && popd
	pushd $(XORG_DIR)/Xrender && $(XORG_ENV) make && popd
	pushd $(XORG_DIR)/Xrandr && $(XORG_ENV) make && popd
	pushd $(XORG_DIR)/FixesExt && $(XORG_ENV) make && popd
	pushd $(XORG_DIR)/DamageExt && $(XORG_ENV) make && popd
	pushd $(XORG_DIR)/Xfont && $(XORG_ENV) make && popd
	pushd $(XORG_DIR)/ResourceExt && $(XORG_ENV) make && popd
	pushd $(XORG_DIR)/RecordExt && $(XORG_ENV) make && popd
	pushd $(XORG_DIR)/CompositeExt && $(XORG_ENV) make && popd
	pushd $(XORG_DIR)/xkbfile && $(XORG_ENV) make && popd 
	pushd $(XORG_DIR)/randrproto-1.1.2/ && $(XORG_ENV) make && popd
	pushd $(XORG_DIR)/renderproto-0.9.2/ && $(XORG_ENV) make && popd
	pushd $(XORG_DIR)/fixesproto-3.0.2/ && $(XORG_ENV) make && popd
	pushd $(XORG_DIR)/damageproto-1.0.3/ && $(XORG_ENV) make && popd
	pushd $(XORG_DIR)/xextproto-7.0.2/ && $(XORG_ENV) make && popd
	pushd $(XORG_DIR)/compositeproto-0.2.2/ && $(XORG_ENV) make && popd
	pushd $(XORG_DIR)/recordproto-X11R7.0-1.13.2/ && $(XORG_ENV) make && popd
	pushd $(XORG_DIR)/resourceproto-X11R7.0-1.0.2/ && $(XORG_ENV) make && popd
	pushd $(XORG_DIR)/xineramaproto-X11R7.0-1.1.2/ && $(XORG_ENV) make && popd
	pushd $(XORG_DIR)/xserver && $(XORG_ENV) make && popd
	pushd $(XORG_DIR)/Xfixes && $(XORG_ENV) make && popd
	pushd $(XORG_DIR)/Xcomposite && $(XORG_ENV) make && popd
	pushd $(XORG_DIR)/Xdamage && $(XORG_ENV) make && popd
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xorg_install: $(STATEDIR)/xorg.install

CCPATH = $(TOPDIR)/xorg

$(STATEDIR)/xorg.install: $(STATEDIR)/xorg.compile
	@$(call targetinfo, $@)
	mkdir -p $(CCPATH)
	cd $(CCPATH) && ln -sf $(CONFIG_TOOLCHAINPATH)bin/$(CONFIG_CROSSPREFIX)-gcc gcc 
	cd $(CCPATH) && ln -sf $(CONFIG_TOOLCHAINPATH)bin/$(CONFIG_CROSSPREFIX)-gcc cc 
	cd $(CCPATH) && ln -sf $(CONFIG_TOOLCHAINPATH)bin/$(CONFIG_CROSSPREFIX)-ld ld 
	cd $(CCPATH) && ln -sf $(CONFIG_TOOLCHAINPATH)bin/$(CONFIG_CROSSPREFIX)-ar ar 
	cd $(CCPATH) && ln -sf $(CONFIG_TOOLCHAINPATH)bin/$(CONFIG_CROSSPREFIX)-cpp cpp
	cd $(CCPATH) && ln -sf $(CONFIG_TOOLCHAINPATH)bin/$(CONFIG_CROSSPREFIX)-gcov gcov
	cd $(CCPATH) && ln -sf $(CONFIG_TOOLCHAINPATH)bin/$(CONFIG_CROSSPREFIX)-ranlib ranlib 
	cd $(CCPATH) && ln -sf $(CONFIG_TOOLCHAINPATH)bin/$(CONFIG_CROSSPREFIX)-nm nm 
	cd $(CCPATH) && ln -sf $(CONFIG_TOOLCHAINPATH)bin/$(CONFIG_CROSSPREFIX)-objdump objdump 
	cd $(CCPATH) && ln -sf $(CONFIG_TOOLCHAINPATH)bin/$(CONFIG_CROSSPREFIX)-g++ g++
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xorg_targetinstall: $(STATEDIR)/xorg.targetinstall

$(STATEDIR)/xorg.targetinstall: $(STATEDIR)/xorg.install
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xorg_clean: 
	rm -rf $(STATEDIR)/xorg.*
	rm -rf $(XORG_DIR)

# vim: syntax=make
