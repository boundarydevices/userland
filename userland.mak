include rules.mak

all:
	@echo "Building everything"
	@echo "packages = $(PACKAGES)"
	@echo "ARCHIVES = $(CONFIG_ARCHIVEPATH)"
	@echo "BUILDDIR = $(BUILDDIR)"
	@echo "STATEDIR = $(STATEDIR)"
	@echo "CONFIG_GNU_TARGET = $(CONFIG_GNU_TARGET)"
	@echo "INSTALLPATH = $(INSTALLPATH)"
	@echo "ROOTDIR = $(ROOTDIR)"
	@echo "CROSSSTRIP = $(CROSSSTRIP)"


