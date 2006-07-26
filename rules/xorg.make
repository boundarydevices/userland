# -*-makefile-*-
# $Id: xorg.make,v 1.4 2006-07-26 22:49:09 ericn Exp $
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

$(STATEDIR)/Xproto.prepare: $(STATEDIR)/xorg.extract
	pushd $(XORG_DIR)/Xproto && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd && touch $@
$(STATEDIR)/Xdmcp.prepare: $(STATEDIR)/xorg.extract
	pushd $(XORG_DIR)/Xdmcp && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd && touch $@
$(STATEDIR)/XExtensions.prepare: $(STATEDIR)/xorg.extract
	pushd $(XORG_DIR)/XExtensions && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd && touch $@
$(STATEDIR)/xtrans.prepare: $(STATEDIR)/xorg.extract
	pushd $(XORG_DIR)/xtrans && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd && touch $@
$(STATEDIR)/Xau.prepare: $(STATEDIR)/xorg.extract $(STATEDIR)/Xproto.install
	pushd $(XORG_DIR)/Xau && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd && touch $@
$(STATEDIR)/X11.prepare: $(STATEDIR)/xorg.extract \
        $(STATEDIR)/xtrans.install \
        $(STATEDIR)/Xau.install
	pushd $(XORG_DIR)/X11 && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd && touch $@
$(STATEDIR)/Xext.prepare: $(STATEDIR)/xorg.extract $(STATEDIR)/X11.install
	pushd $(XORG_DIR)/Xext && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd && touch $@
$(STATEDIR)/Randr.prepare: $(STATEDIR)/xorg.extract
	pushd $(XORG_DIR)/Randr && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd && touch $@
$(STATEDIR)/Render.prepare: $(STATEDIR)/xorg.extract
	pushd $(XORG_DIR)/Render && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd && touch $@
$(STATEDIR)/Xrender.prepare: $(STATEDIR)/xorg.extract
	pushd $(XORG_DIR)/Xrender && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd && touch $@
$(STATEDIR)/Xrandr.prepare: $(STATEDIR)/xorg.extract \
        $(STATEDIR)/Randr.install \
        $(STATEDIR)/randrproto.install \
        $(STATEDIR)/Xext.install \
        $(STATEDIR)/xextproto.install \
        $(STATEDIR)/Render.install \
        $(STATEDIR)/renderproto.install
	pushd $(XORG_DIR)/Xrandr && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd && touch $@
$(STATEDIR)/FixesExt.prepare: $(STATEDIR)/xorg.extract 
	pushd $(XORG_DIR)/FixesExt && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd && touch $@
$(STATEDIR)/DamageExt.prepare: $(STATEDIR)/xorg.extract
	pushd $(XORG_DIR)/DamageExt && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd && touch $@
$(STATEDIR)/Xfont.prepare: $(STATEDIR)/xorg.extract $(STATEDIR)/zlib.install
	pushd $(XORG_DIR)/Xfont && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd && touch $@
$(STATEDIR)/ResourceExt.prepare: $(STATEDIR)/xorg.extract
	pushd $(XORG_DIR)/ResourceExt && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd && touch $@
$(STATEDIR)/RecordExt.prepare: $(STATEDIR)/xorg.extract
	pushd $(XORG_DIR)/RecordExt && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd && touch $@
$(STATEDIR)/CompositeExt.prepare: $(STATEDIR)/xorg.extract $(STATEDIR)/XExtensions.install $(STATEDIR)/FixesExt.install
	pushd $(XORG_DIR)/CompositeExt && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd && touch $@
$(STATEDIR)/xkbfile.prepare: $(STATEDIR)/xorg.extract
	pushd $(XORG_DIR)/xkbfile && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd && touch $@ 
$(STATEDIR)/randrproto.prepare: $(STATEDIR)/xorg.extract
	pushd $(XORG_DIR)/randrproto-1.1.2/ && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd && touch $@
$(STATEDIR)/renderproto.prepare: $(STATEDIR)/xorg.extract
	pushd $(XORG_DIR)/renderproto-0.9.2/ && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd && touch $@
$(STATEDIR)/fixesproto.prepare: $(STATEDIR)/xorg.extract
	pushd $(XORG_DIR)/fixesproto-3.0.2/ && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd && touch $@
$(STATEDIR)/damageproto.prepare: $(STATEDIR)/xorg.extract
	pushd $(XORG_DIR)/damageproto-1.0.3/ && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd && touch $@
$(STATEDIR)/xextproto.prepare: $(STATEDIR)/xorg.extract
	pushd $(XORG_DIR)/xextproto-7.0.2/ && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd && touch $@
$(STATEDIR)/compositeproto.prepare: $(STATEDIR)/xorg.extract
	pushd $(XORG_DIR)/compositeproto-0.2.2/ && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd && touch $@
$(STATEDIR)/recordproto.prepare: $(STATEDIR)/xorg.extract
	pushd $(XORG_DIR)/recordproto-X11R7.0-1.13.2/ && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd && touch $@
$(STATEDIR)/resourceproto.prepare: $(STATEDIR)/xorg.extract
	pushd $(XORG_DIR)/resourceproto-X11R7.0-1.0.2/ && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd && touch $@
$(STATEDIR)/xineramaproto.prepare: $(STATEDIR)/xorg.extract
	pushd $(XORG_DIR)/xineramaproto-X11R7.0-1.1.2/ && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd && touch $@
$(STATEDIR)/xserver.prepare: \
        $(STATEDIR)/xorg.extract \
        $(STATEDIR)/Xdmcp.install \
        $(STATEDIR)/fixesproto.install \
        $(STATEDIR)/Xfont.install \
        $(STATEDIR)/resourceproto.install \
        $(STATEDIR)/recordproto.install
	pushd $(XORG_DIR)/xserver && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd && touch $@
	perl -pi -e 's/ephyr//' $(XORG_DIR)/xserver/hw/kdrive/Makefile
$(STATEDIR)/Xfixes.prepare: $(STATEDIR)/xorg.extract
	pushd $(XORG_DIR)/Xfixes && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd && touch $@
$(STATEDIR)/Xcomposite.prepare: $(STATEDIR)/xorg.extract $(STATEDIR)/compositeproto.install
	pushd $(XORG_DIR)/Xcomposite && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd && touch $@
$(STATEDIR)/Xdamage.prepare: $(STATEDIR)/xorg.extract $(STATEDIR)/damageproto.install $(STATEDIR)/DamageExt.install
	pushd $(XORG_DIR)/Xdamage && $(XORG_ENV) ./autogen.sh $(XORG_AUTOGEN)  && popd && touch $@

xorg_prepare_files = $(STATEDIR)/xorg.extract \
                     $(STATEDIR)/CompositeExt.prepare \
                     $(STATEDIR)/DamageExt.prepare \
                     $(STATEDIR)/FixesExt.prepare \
                     $(STATEDIR)/Randr.prepare \
                     $(STATEDIR)/RecordExt.prepare \
                     $(STATEDIR)/Render.prepare \
                     $(STATEDIR)/ResourceExt.prepare \
                     $(STATEDIR)/X11.prepare \
                     $(STATEDIR)/XExtensions.prepare \
                     $(STATEDIR)/Xau.prepare \
                     $(STATEDIR)/Xcomposite.prepare \
                     $(STATEDIR)/Xdamage.prepare \
                     $(STATEDIR)/Xdmcp.prepare \
                     $(STATEDIR)/Xext.prepare \
                     $(STATEDIR)/Xfixes.prepare \
                     $(STATEDIR)/Xfont.prepare \
                     $(STATEDIR)/Xproto.prepare \
                     $(STATEDIR)/Xrandr.prepare \
                     $(STATEDIR)/Xrender.prepare \
                     $(STATEDIR)/compositeproto.prepare \
                     $(STATEDIR)/damageproto.prepare \
                     $(STATEDIR)/fixesproto.prepare \
                     $(STATEDIR)/randrproto.prepare \
                     $(STATEDIR)/recordproto.prepare \
                     $(STATEDIR)/renderproto.prepare \
                     $(STATEDIR)/resourceproto.prepare \
                     $(STATEDIR)/xextproto.prepare \
                     $(STATEDIR)/xineramaproto.prepare \
                     $(STATEDIR)/xkbfile.prepare \
                     $(STATEDIR)/xserver.prepare \
                     $(STATEDIR)/xtrans.prepare
$(STATEDIR)/xorg.prepare: $(xorg_prepare_files)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xorg_compile: $(STATEDIR)/xorg.compile

$(STATEDIR)/Xproto.compile: $(STATEDIR)/Xproto.prepare
	pushd $(XORG_DIR)/Xproto && make && popd && touch $@
$(STATEDIR)/Xdmcp.compile: $(STATEDIR)/Xdmcp.prepare
	pushd $(XORG_DIR)/Xdmcp && make && popd && touch $@
$(STATEDIR)/XExtensions.compile: $(STATEDIR)/XExtensions.prepare
	pushd $(XORG_DIR)/XExtensions && make && popd && touch $@
$(STATEDIR)/xtrans.compile: $(STATEDIR)/xtrans.prepare
	pushd $(XORG_DIR)/xtrans && make && popd && touch $@
$(STATEDIR)/Xau.compile: $(STATEDIR)/Xau.prepare
	pushd $(XORG_DIR)/Xau && make && popd && touch $@
$(STATEDIR)/X11.compile: $(STATEDIR)/X11.prepare
	pushd $(XORG_DIR)/X11 && make && popd && touch $@
$(STATEDIR)/Xext.compile: $(STATEDIR)/Xext.prepare
	pushd $(XORG_DIR)/Xext && make && popd && touch $@
$(STATEDIR)/Randr.compile: $(STATEDIR)/Randr.prepare
	pushd $(XORG_DIR)/Randr && make && popd && touch $@
$(STATEDIR)/Render.compile: $(STATEDIR)/Render.prepare
	pushd $(XORG_DIR)/Render && make && popd && touch $@
$(STATEDIR)/Xrender.compile: $(STATEDIR)/Xrender.prepare
	pushd $(XORG_DIR)/Xrender && make && popd && touch $@
$(STATEDIR)/Xrandr.compile: $(STATEDIR)/Xrandr.prepare $(STATEDIR)/Xrender.install
	pushd $(XORG_DIR)/Xrandr && make && popd && touch $@
$(STATEDIR)/FixesExt.compile: $(STATEDIR)/FixesExt.prepare
	pushd $(XORG_DIR)/FixesExt && make && popd && touch $@
$(STATEDIR)/DamageExt.compile: $(STATEDIR)/DamageExt.prepare
	pushd $(XORG_DIR)/DamageExt && make && popd && touch $@
$(STATEDIR)/Xfont.compile: $(STATEDIR)/Xfont.prepare
	pushd $(XORG_DIR)/Xfont && make && popd && touch $@
$(STATEDIR)/ResourceExt.compile: $(STATEDIR)/ResourceExt.prepare
	pushd $(XORG_DIR)/ResourceExt && make && popd && touch $@
$(STATEDIR)/RecordExt.compile: $(STATEDIR)/RecordExt.prepare
	pushd $(XORG_DIR)/RecordExt && make && popd && touch $@
$(STATEDIR)/CompositeExt.compile: $(STATEDIR)/CompositeExt.prepare
	pushd $(XORG_DIR)/CompositeExt && make && popd && touch $@
$(STATEDIR)/xkbfile.compile: $(STATEDIR)/xkbfile.prepare
	pushd $(XORG_DIR)/xkbfile && make && popd && touch $@ 
$(STATEDIR)/randrproto.compile: $(STATEDIR)/randrproto.prepare
	pushd $(XORG_DIR)/randrproto-1.1.2/ && make && popd && touch $@
$(STATEDIR)/renderproto.compile: $(STATEDIR)/renderproto.prepare
	pushd $(XORG_DIR)/renderproto-0.9.2/ && make && popd && touch $@
$(STATEDIR)/fixesproto.compile: $(STATEDIR)/fixesproto.prepare
	pushd $(XORG_DIR)/fixesproto-3.0.2/ && make && popd && touch $@
$(STATEDIR)/damageproto.compile: $(STATEDIR)/damageproto.prepare
	pushd $(XORG_DIR)/damageproto-1.0.3/ && make && popd && touch $@
$(STATEDIR)/xextproto.compile: $(STATEDIR)/xextproto.prepare
	pushd $(XORG_DIR)/xextproto-7.0.2/ && make && popd && touch $@
$(STATEDIR)/compositeproto.compile: $(STATEDIR)/compositeproto.prepare
	pushd $(XORG_DIR)/compositeproto-0.2.2/ && make && popd && touch $@
$(STATEDIR)/recordproto.compile: $(STATEDIR)/recordproto.prepare
	pushd $(XORG_DIR)/recordproto-X11R7.0-1.13.2/ && make && popd && touch $@
$(STATEDIR)/resourceproto.compile: $(STATEDIR)/resourceproto.prepare
	pushd $(XORG_DIR)/resourceproto-X11R7.0-1.0.2/ && make && popd && touch $@
$(STATEDIR)/xineramaproto.compile: $(STATEDIR)/xineramaproto.prepare
	pushd $(XORG_DIR)/xineramaproto-X11R7.0-1.1.2/ && make && popd && touch $@
$(STATEDIR)/xserver.compile: $(STATEDIR)/xserver.prepare
	pushd $(XORG_DIR)/xserver && make && popd && touch $@
$(STATEDIR)/Xfixes.compile: $(STATEDIR)/Xfixes.prepare
	pushd $(XORG_DIR)/Xfixes && make && popd && touch $@
$(STATEDIR)/Xcomposite.compile: $(STATEDIR)/Xcomposite.prepare $(STATEDIR)/Xfixes.install
	pushd $(XORG_DIR)/Xcomposite && make && popd && touch $@
$(STATEDIR)/Xdamage.compile: $(STATEDIR)/Xdamage.prepare
	pushd $(XORG_DIR)/Xdamage && make && popd && touch $@

xorg_compile_files = $(STATEDIR)/xorg.extract \
                     $(STATEDIR)/CompositeExt.compile \
                     $(STATEDIR)/DamageExt.compile \
                     $(STATEDIR)/FixesExt.compile \
                     $(STATEDIR)/Randr.compile \
                     $(STATEDIR)/RecordExt.compile \
                     $(STATEDIR)/Render.compile \
                     $(STATEDIR)/ResourceExt.compile \
                     $(STATEDIR)/X11.compile \
                     $(STATEDIR)/XExtensions.compile \
                     $(STATEDIR)/Xau.compile \
                     $(STATEDIR)/Xcomposite.compile \
                     $(STATEDIR)/Xdamage.compile \
                     $(STATEDIR)/Xdmcp.compile \
                     $(STATEDIR)/Xext.compile \
                     $(STATEDIR)/Xfixes.compile \
                     $(STATEDIR)/Xfont.compile \
                     $(STATEDIR)/Xproto.compile \
                     $(STATEDIR)/Xrandr.compile \
                     $(STATEDIR)/Xrender.compile \
                     $(STATEDIR)/compositeproto.compile \
                     $(STATEDIR)/damageproto.compile \
                     $(STATEDIR)/fixesproto.compile \
                     $(STATEDIR)/randrproto.compile \
                     $(STATEDIR)/recordproto.compile \
                     $(STATEDIR)/renderproto.compile \
                     $(STATEDIR)/resourceproto.compile \
                     $(STATEDIR)/xextproto.compile \
                     $(STATEDIR)/xineramaproto.compile \
                     $(STATEDIR)/xkbfile.compile \
                     $(STATEDIR)/xserver.compile \
                     $(STATEDIR)/xtrans.compile

$(STATEDIR)/xorg.compile: $(STATEDIR)/xorg.prepare $(xorg_compile_files)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xorg_install: $(STATEDIR)/xorg.install

$(STATEDIR)/Xproto.install: $(STATEDIR)/Xproto.compile
	pushd $(XORG_DIR)/Xproto && make install && popd && touch $@
$(STATEDIR)/Xdmcp.install: $(STATEDIR)/Xdmcp.compile
	pushd $(XORG_DIR)/Xdmcp && make install && popd && touch $@
$(STATEDIR)/XExtensions.install: $(STATEDIR)/XExtensions.compile
	pushd $(XORG_DIR)/XExtensions && make install && popd && touch $@
$(STATEDIR)/xtrans.install: $(STATEDIR)/xtrans.compile
	pushd $(XORG_DIR)/xtrans && make install && popd && touch $@
$(STATEDIR)/Xau.install: $(STATEDIR)/Xau.compile
	pushd $(XORG_DIR)/Xau && make install && popd && touch $@
$(STATEDIR)/X11.install: $(STATEDIR)/X11.compile
	pushd $(XORG_DIR)/X11 && make install && popd && touch $@
	perl -pi.orig -e 's/-lX11/-rpath-link \x24{libdir} -lX11/' $(INSTALLPATH)/lib/pkgconfig/x11.pc
$(STATEDIR)/Xext.install: $(STATEDIR)/Xext.compile
	pushd $(XORG_DIR)/Xext && make install && popd && touch $@
$(STATEDIR)/Randr.install: $(STATEDIR)/Randr.compile
	pushd $(XORG_DIR)/Randr && make install && popd && touch $@
$(STATEDIR)/Render.install: $(STATEDIR)/Render.compile
	pushd $(XORG_DIR)/Render && make install && popd && touch $@
$(STATEDIR)/Xrender.install: $(STATEDIR)/Xrender.compile
	pushd $(XORG_DIR)/Xrender && make install && popd && touch $@
$(STATEDIR)/Xrandr.install: $(STATEDIR)/Xrandr.compile
	pushd $(XORG_DIR)/Xrandr && make install && popd && touch $@
$(STATEDIR)/FixesExt.install: $(STATEDIR)/FixesExt.compile
	pushd $(XORG_DIR)/FixesExt && make install && popd && touch $@
$(STATEDIR)/DamageExt.install: $(STATEDIR)/DamageExt.compile
	pushd $(XORG_DIR)/DamageExt && make install && popd && touch $@
$(STATEDIR)/Xfont.install: $(STATEDIR)/Xfont.compile
	pushd $(XORG_DIR)/Xfont && make install && popd && touch $@
$(STATEDIR)/ResourceExt.install: $(STATEDIR)/ResourceExt.compile
	pushd $(XORG_DIR)/ResourceExt && make install && popd && touch $@
$(STATEDIR)/RecordExt.install: $(STATEDIR)/RecordExt.compile
	pushd $(XORG_DIR)/RecordExt && make install && popd && touch $@
$(STATEDIR)/CompositeExt.install: $(STATEDIR)/CompositeExt.compile
	pushd $(XORG_DIR)/CompositeExt && make install && popd && touch $@
$(STATEDIR)/xkbfile.install: $(STATEDIR)/xkbfile.compile
	pushd $(XORG_DIR)/xkbfile && make install && popd && touch $@ 
$(STATEDIR)/randrproto.install: $(STATEDIR)/randrproto.compile
	pushd $(XORG_DIR)/randrproto-1.1.2/ && make install && popd && touch $@
$(STATEDIR)/renderproto.install: $(STATEDIR)/renderproto.compile
	pushd $(XORG_DIR)/renderproto-0.9.2/ && make install && popd && touch $@
$(STATEDIR)/fixesproto.install: $(STATEDIR)/fixesproto.compile
	pushd $(XORG_DIR)/fixesproto-3.0.2/ && make install && popd && touch $@
$(STATEDIR)/damageproto.install: $(STATEDIR)/damageproto.compile
	pushd $(XORG_DIR)/damageproto-1.0.3/ && make install && popd && touch $@
$(STATEDIR)/xextproto.install: $(STATEDIR)/xextproto.compile
	pushd $(XORG_DIR)/xextproto-7.0.2/ && make install && popd && touch $@
$(STATEDIR)/compositeproto.install: $(STATEDIR)/compositeproto.compile
	pushd $(XORG_DIR)/compositeproto-0.2.2/ && make install && popd && touch $@
$(STATEDIR)/recordproto.install: $(STATEDIR)/recordproto.compile
	pushd $(XORG_DIR)/recordproto-X11R7.0-1.13.2/ && make install && popd && touch $@
$(STATEDIR)/resourceproto.install: $(STATEDIR)/resourceproto.compile
	pushd $(XORG_DIR)/resourceproto-X11R7.0-1.0.2/ && make install && popd && touch $@
$(STATEDIR)/xineramaproto.install: $(STATEDIR)/xineramaproto.compile
	pushd $(XORG_DIR)/xineramaproto-X11R7.0-1.1.2/ && make install && popd && touch $@
$(STATEDIR)/xserver.install: $(STATEDIR)/xserver.compile
	pushd $(XORG_DIR)/xserver && make install && popd && touch $@
$(STATEDIR)/Xfixes.install: $(STATEDIR)/Xfixes.compile
	pushd $(XORG_DIR)/Xfixes && make install && popd && touch $@
$(STATEDIR)/Xcomposite.install: $(STATEDIR)/Xcomposite.compile
	pushd $(XORG_DIR)/Xcomposite && make install && popd && touch $@
$(STATEDIR)/Xdamage.install: $(STATEDIR)/Xdamage.compile
	pushd $(XORG_DIR)/Xdamage && make install && popd && touch $@

xorg_install_files = $(STATEDIR)/xorg.extract \
                     $(STATEDIR)/CompositeExt.install \
                     $(STATEDIR)/DamageExt.install \
                     $(STATEDIR)/FixesExt.install \
                     $(STATEDIR)/Randr.install \
                     $(STATEDIR)/RecordExt.install \
                     $(STATEDIR)/Render.install \
                     $(STATEDIR)/ResourceExt.install \
                     $(STATEDIR)/X11.install \
                     $(STATEDIR)/XExtensions.install \
                     $(STATEDIR)/Xau.install \
                     $(STATEDIR)/Xcomposite.install \
                     $(STATEDIR)/Xdamage.install \
                     $(STATEDIR)/Xdmcp.install \
                     $(STATEDIR)/Xext.install \
                     $(STATEDIR)/Xfixes.install \
                     $(STATEDIR)/Xfont.install \
                     $(STATEDIR)/Xproto.install \
                     $(STATEDIR)/Xrandr.install \
                     $(STATEDIR)/Xrender.install \
                     $(STATEDIR)/compositeproto.install \
                     $(STATEDIR)/damageproto.install \
                     $(STATEDIR)/fixesproto.install \
                     $(STATEDIR)/randrproto.install \
                     $(STATEDIR)/recordproto.install \
                     $(STATEDIR)/renderproto.install \
                     $(STATEDIR)/resourceproto.install \
                     $(STATEDIR)/xextproto.install \
                     $(STATEDIR)/xineramaproto.install \
                     $(STATEDIR)/xkbfile.install \
                     $(STATEDIR)/xserver.install \
                     $(STATEDIR)/xtrans.install
#
# because of dependencies, all install targets are called in the compile step
#
$(STATEDIR)/xorg.install: $(STATEDIR)/xorg.compile $(xorg_install_files)
	@$(call targetinfo, $@)
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
	rm -rf $(xorg_prepare_files)
	rm -rf $(xorg_compile_files)
	rm -rf $(xorg_install_files)

# vim: syntax=make
