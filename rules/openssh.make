# -*-makefile-*-
# $Id: openssh.make,v 1.2 2004-06-10 03:24:05 ericn Exp $
#
# Copyright (C) 2002, 2003 by Pengutronix e.K., Hildesheim, Germany
#
# See CREDITS for details about who has contributed to this project. 
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef CONFIG_OPENSSH
PACKAGES += openssh
endif

#
# We depend on this package
#
ifdef CONFIG_OPENSSH
PACKAGES += openssl
endif

#
# Paths and names 
#
OPENSSH			= openssh-3.7.1p2
OPENSSH_URL 		= ftp://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/$(OPENSSH).tar.gz
OPENSSH_SOURCE		= $(CONFIG_ARCHIVEPATH)/$(OPENSSH).tar.gz
OPENSSH_DIR 		= $(BUILDDIR)/$(OPENSSH)
OPENSSH_PATCH_SOURCE = $(CONFIG_ARCHIVEPATH)/openssh-3.7.1p2.patch
OPENSSH_PATCH_URL    = http://www.pengutronix.de/software/ptxdist/patches-cvs/openssh-3.7.1p2/generic/generic-configure-ac.patch

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

openssh_get: $(STATEDIR)/openssh.get

openssh_get_deps = $(OPENSSH_SOURCE) $(OPENSSH_PATCH_SOURCE)

$(STATEDIR)/openssh.get: $(openssh_get_deps)
	@$(call targetinfo, openssh.get)
	touch $@

$(OPENSSH_SOURCE):
	@$(call targetinfo, $(OPENSSH_SOURCE))
	cd $(CONFIG_ARCHIVEPATH) && wget $(OPENSSH_URL)

$(OPENSSH_PATCH_SOURCE):
	@$(call targetinfo, $(OPENSSH_PATCH_SOURCE))
	wget -O $(OPENSSH_PATCH_SOURCE) $(OPENSSH_PATCH_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

openssh_extract: $(STATEDIR)/openssh.extract

#
# we depend on openssl.install, because we need the header files
# to patch configure.ac with the version string of the installed
# openssl packet
#
openssh_extract_deps = \
	$(STATEDIR)/openssl.install \
	$(STATEDIR)/openssh.get

$(STATEDIR)/openssh.extract: $(openssh_extract_deps)
	@$(call targetinfo, openssh.extract)
	@$(call clean, $(OPENSSH_DIR))
	cd $(BUILDDIR) && gzcat $(OPENSSH_SOURCE) | tar -xvf -
	@$(call patchin, $(OPENSSH))

	OPENSSL_VERSION_NUMBER="`sed -n -e 's/.*OPENSSL_VERSION_NUMBER.*0x[0]*\([0-9a-f]*\)L/\1/p' \
		$(INSTALLPATH)/include/openssl/opensslv.h`" \
	OPENSSL_VERSION_TEXT="`sed -n -e 's/.*OPENSSL_VERSION_TEXT.*"\(.*\)"/\1/p' \
		$(INSTALLPATH)/include/openssl/opensslv.h`" && \
	perl -i -p -e "s/ssl_library_ver=\"VERSION\"/ssl_library_ver=\"$$OPENSSL_VERSION_NUMBER ($$OPENSSL_VERSION_TEXT)\"/g" \
		$(OPENSSH_DIR)/configure.ac && \
	perl -i -p -e "s/ssl_header_ver=\"VERSION\"/ssl_header_ver=\"$$OPENSSL_VERSION_NUMBER ($$OPENSSL_VERSION_TEXT)\"/g" \
		$(OPENSSH_DIR)/configure.ac
	cd $(BUILDDIR) && patch -p0 < $(OPENSSH_PATCH_SOURCE)
	cd $(OPENSSH_DIR) && PATH=$(CONFIG_TOOLCHAINPATH)/bin:$$PATH autoconf
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

openssh_prepare: $(STATEDIR)/openssh.prepare

#
# dependencies
#
openssh_prepare_deps = \
	$(STATEDIR)/zlib.install \
	$(STATEDIR)/openssh.extract

OPENSSH_PATH	= PATH=$(CROSS_PATH)
#
# openssh is a little F*CKED up, is won't compile without LD=gcc in environment
# perhaps someone should fix this....
#
# powerpc-linux-ld -o ssh ssh.o readconf.o clientloop.o sshtty.o
# sshconnect.o sshconnect1.o sshconnect2.o -L. -Lopenbsd-compat/ -lssh
# -lopenbsd-compat -lutil -lz -lnsl -lcrypto -lcrypt
# powerpc-linux-ld: warning: cannot find entry symbol _start;
# defaulting to 10001ba8
# ./libssh.a(packet.o): In function `set_newkeys':
# /home/frogger/projects/ptxdist/ptxdist-ppc/build/openssh-3.7.1p2/packet.c:643:
# undefined reference to `__ashldi3'
# /home/frogger/projects/ptxdist/ptxdist-ppc/build/openssh-3.7.1p2/packet.c:643:
# relocation truncated to fit: R_PPC_REL24 __ashldi3
# make[1]: *** [ssh] Error 1
#
OPENSSH_ENV	= \
	$(CROSS_ENV_AR) \
	$(CORSS_ENV_AS) \
	$(CROSS_ENV_CXX) \
	$(CROSS_ENV_CC) \
	$(CROSS_ENV_NM) \
	$(CROSS_ENV_OBJCOPY) \
	$(CROSS_ENV_RANLIB) \
	$(CROSS_ENV_STRIP) \
	LD=$(CONFIG_GNU_TARGET)-gcc

#
# autoconf
#
OPENSSH_AUTOCONF = \
	--host=$(CONFIG_GNU_TARGET) \
	--prefix=$(INSTALLPATH) \
	--libexecdir=/usr/sbin \
	--sysconfdir=/etc/ssh \
	--with-privsep-path=/var/run/sshd \
	--without-pam \
	--with-ipv4-default \
	--with-zlib=$(INSTALLPATH) \
	--disable-etc-default-login \
   --exec-prefix=$(INSTALLPATH) \
   --includedir=$(INSTALLPATH)/include \
   --datadir=$(INSTALLPATH)/share \
   --mandir=$(INSTALLPATH)/man \
   --infodir=$(INSTALLPATH)/info

$(STATEDIR)/openssh.prepare: $(openssh_prepare_deps)
	@$(call targetinfo, openssh.prepare)
	cd $(OPENSSH_DIR) && \
		$(OPENSSH_PATH) $(OPENSSH_ENV) \
		./configure $(OPENSSH_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

openssh_compile: $(STATEDIR)/openssh.compile

$(STATEDIR)/openssh.compile: $(STATEDIR)/openssh.prepare 
	@$(call targetinfo, openssh.compile)
	$(OPENSSH_PATH) make -C $(OPENSSH_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

openssh_install: $(STATEDIR)/openssh.install

$(STATEDIR)/openssh.install: $(STATEDIR)/openssh.compile
	@$(call targetinfo, openssh.install)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

openssh_targetinstall: $(STATEDIR)/openssh.targetinstall

openssh_targetinstall_deps = \
	$(STATEDIR)/openssl.targetinstall \
	$(STATEDIR)/zlib.targetinstall \
	$(STATEDIR)/openssh.compile

$(STATEDIR)/openssh.targetinstall: $(openssh_targetinstall_deps)
	@$(call targetinfo, openssh.targetinstall)

ifdef CONFIG_OPENSSH_SSH
	@install -m 644 -D $(OPENSSH_DIR)/ssh_config.out $(ROOTDIR)/etc/ssh/ssh_config
	@install -m 755 -D $(OPENSSH_DIR)/ssh $(ROOTDIR)/usr/bin/ssh
	@$(OPENSSH_PATH) $(CROSSSTRIP) -R .notes -R .comment $(ROOTDIR)/usr/bin/ssh
endif

ifdef CONFIG_OPENSSH_SSHD
	@install -m 644 -D $(OPENSSH_DIR)/moduli.out $(ROOTDIR)/etc/ssh/moduli
	@install -m 644 -D $(OPENSSH_DIR)/sshd_config.out $(ROOTDIR)/etc/ssh/sshd_config
	@perl -p -i -e "s/#PermitRootLogin yes/PermitRootLogin yes/" \
	@$(ROOTDIR)/etc/ssh/sshd_config
	@install -m 755 -D $(OPENSSH_DIR)/sshd $(ROOTDIR)/usr/sbin/sshd
	@$(OPENSSH_PATH) $(CROSSSTRIP) -R .notes -R .comment $(ROOTDIR)/usr/sbin/sshd
endif

ifdef CONFIG_OPENSSH_SCP
	@install -m 755 -D $(OPENSSH_DIR)/scp $(ROOTDIR)/usr/bin/scp
	@$(OPENSSH_PATH) $(CROSSSTRIP) -R .notes -R .comment $(ROOTDIR)/usr/bin/scp
endif

ifdef CONFIG_OPENSSH_SFTP_SERVER
	@install -m 755 -D $(OPENSSH_DIR)/sftp-server $(ROOTDIR)/usr/sbin/sftp-server
	@$(OPENSSH_PATH) $(CROSSSTRIP) -R .notes -R .comment $(ROOTDIR)/usr/sbin/sftp-server
endif

ifdef CONFIG_OPENSSH_KEYGEN
	# FIXME: if this is the only file in this directory move it
	# to somewhere else (patch, echo << EOF?) [RSC]
#	@install -m 755 -D $(MISCDIR)/openssh-host-keygen.sh $(ROOTDIR)/sbin/openssh-host-keygen.sh
	@install -m 755 -D $(OPENSSH_DIR)/ssh-keygen $(ROOTDIR)/usr/bin/ssh-keygen
	@$(OPENSSH_PATH) $(CROSSSTRIP) -R .notes -R .comment $(ROOTDIR)/usr/bin/ssh-keygen
endif

	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

openssh_clean: 
	rm -rf $(STATEDIR)/openssh* $(OPENSSH_DIR)

# vim: syntax=make
