#
# cramfs.mak
#
# This makefile downloads and builds a patched version of
# mkcramfs adding support for JFFS2-style device tables.
#
# History:
# $Log: cramfs.make,v $
# Revision 1.1  2004-06-18 04:15:37  ericn
# -Initial import
#
#
#

$(CONFIG_ARCHIVEPATH)/cramfs-1.1.tar.gz:
	cd $(CONFIG_ARCHIVEPATH) && wget http://easynews.dl.sourceforge.net/sourceforge/cramfs/cramfs-1.1.tar.gz

$(CONFIG_ARCHIVEPATH)/cramfs-dev.patch:
	cd $(CONFIG_ARCHIVEPATH) && wget http://boundarydevices.com/cramfs-dev.patch

$(BUILDDIR)/cramfs-1.1/unpacked: $(CONFIG_ARCHIVEPATH)/cramfs-1.1.tar.gz \
                        $(CONFIG_ARCHIVEPATH)/cramfs-dev.patch
	cd $(BUILDDIR) && \
   tar -zxvf $(CONFIG_ARCHIVEPATH)/cramfs-1.1.tar.gz && \
	patch -p0 < $(CONFIG_ARCHIVEPATH)/cramfs-dev.patch
	touch $@

$(BUILDDIR)/cramfs-1.1/mkcramfs: $(BUILDDIR)/cramfs-1.1/unpacked
	cd $(BUILDDIR)/cramfs-1.1/ && make all

$(BUILDDIR)/cramfs-1.1/cramfsck: $(BUILDDIR)/cramfs-1.1/unpacked
	cd $(BUILDDIR)/cramfs-1.1/ && make all


