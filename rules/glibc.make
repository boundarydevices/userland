# -*-makefile-*-
# $Id: glibc.make,v 1.10 2008-01-02 18:36:04 ericn Exp $
#
# Copyright (C) 2002, 2003 by Pengutronix e.K., Hildesheim, Germany
#
# See CREDITS for details about who has contributed to this project. 
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

LD_LINUX=ld-linux.so.2
GLIBC_VER=$(subst ",,$(CONFIG_GLIBC_VER))
GLIBC_PATH=$(subst ",,$(CONFIG_GLIBC_PATH))
STDCPP_PATH=$(subst /lib,/usr/lib,$(GLIBC_PATH))

$(ROOTDIR)/lib/ld-$(GLIBC_VER).so: $(GLIBC_PATH)/ld-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && PATH=$(CROSS_PATH) $(CROSSSTRIP) $@

$(ROOTDIR)/lib/libc-$(GLIBC_VER).so: $(GLIBC_PATH)/libc-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && PATH=$(CROSS_PATH) $(CROSSSTRIP) $@

$(ROOTDIR)/lib/libc.so.6: $(GLIBC_PATH)/libc.so.6 $(ROOTDIR)/lib/libc-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && PATH=$(CROSS_PATH) $(CROSSSTRIP) $@
                
$(ROOTDIR)/lib/libgcc_s.so.1: $(GLIBC_PATH)/libgcc_s.so.1
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && PATH=$(CROSS_PATH) $(CROSSSTRIP) $@

$(ROOTDIR)/lib/libstdc++.so: $(STDCPP_PATH)/libstdc++.so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && PATH=$(CROSS_PATH) $(CROSSSTRIP) $@
                
$(ROOTDIR)/lib/libstdc++.so.6: $(STDCPP_PATH)/libstdc++.so.6
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && PATH=$(CROSS_PATH) $(CROSSSTRIP) $@
                
$(ROOTDIR)/lib/libstdc++.so.6.0.3: $(STDCPP_PATH)/libstdc++.so.6.0.3
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && PATH=$(CROSS_PATH) $(CROSSSTRIP) $@
                
$(ROOTDIR)/lib/libutil-$(GLIBC_VER).so: $(GLIBC_PATH)/libutil-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && PATH=$(CROSS_PATH) $(CROSSSTRIP) $@

$(ROOTDIR)/lib/libutil.so.1: $(GLIBC_PATH)/libutil.so.1 $(ROOTDIR)/lib/libutil-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && PATH=$(CROSS_PATH) $(CROSSSTRIP) $@

$(ROOTDIR)/lib/libresolv-$(GLIBC_VER).so: $(GLIBC_PATH)/libresolv-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && PATH=$(CROSS_PATH) $(CROSSSTRIP) $@

$(ROOTDIR)/lib/libnss_dns-$(GLIBC_VER).so: $(GLIBC_PATH)/libnss_dns-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && PATH=$(CROSS_PATH) $(CROSSSTRIP) $@

$(ROOTDIR)/lib/libnss_files-$(GLIBC_VER).so: $(GLIBC_PATH)/libnss_files-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && PATH=$(CROSS_PATH) $(CROSSSTRIP) $@

$(ROOTDIR)/lib/libnss_dns.so.2: $(GLIBC_PATH)/libnss_dns.so.2 $(ROOTDIR)/lib/libnss_dns-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && PATH=$(CROSS_PATH) $(CROSSSTRIP) $@
                
$(ROOTDIR)/lib/libnss_files.so.2: $(GLIBC_PATH)/libnss_files.so.2 $(ROOTDIR)/lib/libnss_files-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && PATH=$(CROSS_PATH) $(CROSSSTRIP) $@
                
$(ROOTDIR)/lib/libcrypt-$(GLIBC_VER).so: $(GLIBC_PATH)/libcrypt-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && PATH=$(CROSS_PATH) $(CROSSSTRIP) $@
                
$(ROOTDIR)/lib/libcrypt.so.1: $(GLIBC_PATH)/libcrypt.so.1 $(ROOTDIR)/lib/libcrypt-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && PATH=$(CROSS_PATH) $(CROSSSTRIP) $@
                
$(ROOTDIR)/lib/libm-$(GLIBC_VER).so: $(GLIBC_PATH)/libm-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && PATH=$(CROSS_PATH) $(CROSSSTRIP) $@
                
$(ROOTDIR)/lib/libm.so.6: $(GLIBC_PATH)/libm.so.6 $(ROOTDIR)/lib/libm-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && PATH=$(CROSS_PATH) $(CROSSSTRIP) $@
                
$(ROOTDIR)/lib/libpthread-0.10.so: $(GLIBC_PATH)/libpthread-0.10.so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && PATH=$(CROSS_PATH) $(CROSSSTRIP) $@

$(ROOTDIR)/lib/libpthread.so.0: $(GLIBC_PATH)/libpthread.so.0 $(ROOTDIR)/lib/libpthread-0.10.so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && PATH=$(CROSS_PATH) $(CROSSSTRIP) $@
                
$(ROOTDIR)/lib/libdl-$(GLIBC_VER).so: $(GLIBC_PATH)/libdl-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && PATH=$(CROSS_PATH) $(CROSSSTRIP) $@

$(ROOTDIR)/lib/libdl.so.2: $(GLIBC_PATH)/libdl.so.2
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && PATH=$(CROSS_PATH) $(CROSSSTRIP) $@
                
$(ROOTDIR)/lib/$(LD_LINUX): $(GLIBC_PATH)/$(LD_LINUX)
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && PATH=$(CROSS_PATH) $(CROSSSTRIP) $@
                
$(ROOTDIR)/lib/libnsl-$(GLIBC_VER).so: $(GLIBC_PATH)/libnsl-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && PATH=$(CROSS_PATH) $(CROSSSTRIP) $@

$(ROOTDIR)/lib/libnsl.so.1: $(ROOTDIR)/lib/libnsl-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cd $(ROOTDIR)/lib && ln -s libnsl-$(GLIBC_VER).so $@

$(ROOTDIR)/lib/libnsl.so: $(ROOTDIR)/lib/libnsl.so.1
	cd $(ROOTDIR)/lib && ln -s libnsl.so.1 $@

$(ROOTDIR)/lib/libthread_db-1.0.so: $(GLIBC_PATH)/libthread_db-1.0.so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && PATH=$(CROSS_PATH) $(CROSSSTRIP) $@

$(ROOTDIR)/lib/libthread_db.so: $(ROOTDIR)/lib/libthread_db-1.0.so
	cd $(ROOTDIR)/lib && ln -s $(notdir $<) $(notdir $@)

$(ROOTDIR)/lib/libthread_db.so.1:  $(ROOTDIR)/lib/libthread_db-1.0.so
	cd $(ROOTDIR)/lib && ln -s $(notdir $<) $(notdir $@)

