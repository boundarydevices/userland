#
# devices.mak
#
# This makefile will build a device list suitable for
# use with either mkcramfs or mkfs.jffs2
#
# The following fragment is from cramfs-1.1/device_table.txt:
#
# When building a target filesystem, it is desirable to not have to
# become root and then run 'mknod' a thousand times.  Using a device 
# table you can create device nodes and directories "on the fly".
#
# This is a sample device table file for use with mkcramfs.  You can
# do all sorts of interesting things with a device table file.  For
# example, if you want to adjust the permissions on a particular file
# you can just add an entry like:
#   /sbin/foobar	f	2755	0	0	-	-	-	-	-
# and (assuming the file /sbin/foobar exists) it will be made setuid
# root (regardless of what its permissions are on the host filesystem.
# Furthermore, you can use a single table entry to create a many device
# minors.  For example, if I wanted to create /dev/hda and /dev/hda[0-15]
# I could just use the following two table entries:
#   /dev/hda	b	640	0	0	3	0	0	0	-
#   /dev/hda	b	640	0	0	3	1	1	1	15
# 
# Device table entries take the form of:
# <name>    <type>	<mode>	<uid>	<gid>	<major>	<minor>	<start>	<inc>	<count>
# where name is the file name,  type can be one of: 
#	f	A regular file
#	d	Directory
#	c	Character special device file
#	b	Block special device file
#	p	Fifo (named pipe)
# uid is the user id for the target file, gid is the group id for the
# target file.  The rest of the entries (major, minor, etc) apply only 
# to device special files.
# Have fun
# -Erik Andersen <andersen@codepoet.org>
#
#<name>		<type>	<mode>	<uid>	<gid>	<major>	<minor>	<start>	<inc>	<count>
#
#
#
#
# Notes on Boundary Devices' use:
#
# The primary objective here is to create a set of devices which match 
# the configuration of the kernel, so the kernel configuration file is
# read first, and the KERNEL_X variables are used to determine whether 
# to produce each device.
#

include .config
include .kernelconfig

all:
	@echo -e "#\n#<name>\t\t\t<type>\t<mode>\t<uid>\t<gid>\t<major>\t<minor>\t<start>\t<inc>\t<count>\n#" > devices.txt
	@echo -e "/dev\t\t\td\t666\t0\t0\t-\t-\t-\t-\t-" >> devices.txt
ifdef KERNEL_ARCH_PXA
	@echo "#KERNEL_ARCH_PXA" >> devices.txt
	@echo -e "/dev/input\t\td\t666\t0\t0\t-\t-\t-\t-\t-" >> devices.txt
	@echo -e "/dev/pts\t\td\t666\t0\t0\t-\t-\t-\t-\t-" >> devices.txt
	@echo -e "/dev/ram\t\tb\t666\t0\t0\t1\t0\t0\t1\t4" >> devices.txt
	@echo -e "/dev/null\t\tc\t666\t0\t0\t1\t3\t0\t0\t-" >> devices.txt
	@echo -e "/dev/zero\t\tc\t666\t0\t0\t1\t5\t0\t0\t-" >> devices.txt
	@echo -e "/dev/ptmx\t\tc\t666\t0\t0\t5\t2\t0\t0\t-" >> devices.txt
	@echo -e "/dev/ptyp\t\tc\t666\t0\t0\t2\t0\t0\t1\t2" >> devices.txt
	@echo -e "/dev/ttyFB\t\tc\t666\t0\t0\t4\t0\t0\t1\t1" >> devices.txt
	@echo -e "/dev/ttyS\t\tc\t666\t0\t0\t4\t64\t0\t1\t3" >> devices.txt
	@echo -e "/dev/systty\t\tc\t666\t0\t0\t4\t0\t0\t0\t-" >> devices.txt
	@echo -e "/dev/tty\t\tc\t666\t0\t0\t5\t0\t0\t0\t-" >> devices.txt
	@echo -e "/dev/vcs\t\tc\t666\t0\t0\t7\t0\t0\t1\t3" >> devices.txt
	@echo -e "/dev/console\t\tc\t666\t0\t0\t5\t1\t0\t0\t-" >> devices.txt
	@echo -e "/dev/cua0\t\tc\t666\t0\t0\t5\t64\t0\t0\t-" >> devices.txt
	@echo -e "/dev/rawctl\t\tc\t666\t0\t0\t162\t0\t0\t0\t-" >> devices.txt
	@echo -e "/dev/timer\t\tc\t666\t0\t0\t252\t0\t0\t0\t-" >> devices.txt
	@echo -e "/dev/random\t\tc\t666\t0\t0\t1\t8\t0\t0\t-" >> devices.txt
	@echo -e "/dev/urandom\t\tc\t666\t0\t0\t1\t9\t0\t0\t-" >> devices.txt
	@echo -e "/dev/raw\t\td\t777\t0\t0\t-\t-\t-\t-\t-" >> devices.txt                               
	@echo -e "/dev/raw/raw1\t\tc\t666\t0\t0\t162\t1\t0\t0\t-" >> devices.txt
# I'm skipping /dev/vcs0-12
else
	$(error "??? KERNEL_ARCH_PXA is not set ???" )
endif
ifdef KERNEL_PCMCIA_PXA
	@echo "#KERNEL_PCMCIA_PXA" >> devices.txt
else
	@echo "#KERNEL_PCMCIA_PXA is not set" >> devices.txt
endif
ifdef KERNEL_PXA_RTC
	@echo "#KERNEL_PXA_RTC" >> devices.txt
else
	@echo "#KERNEL_PXA_RTC is not set" >> devices.txt
endif


ifdef KERNEL_USB
	@echo "#KERNEL_PXA_USB" >> devices.txt
	@echo -e "/dev/usb\td\t666\t0\t0\t-\t-\t-\t-\t-" >> devices.txt
ifdef KERNEL_USB_PRINTER
		@echo -e "/dev/usb/lp0\tc\t666\t0\t0\t180\t0\t0\t0\t-" >> devices.txt
else   
	   @echo "#KERNEL_USB_PRINTER is not set" >> devices.txt
endif   
ifdef KERNEL_USB_QC
	   @echo -e "/dev/video0\tc\t666\t0\t0\t81\t0\t0\t0\t-" >> devices.txt
else   
	   @echo "#KERNEL_USB_QC is not set" >> devices.txt
endif
else
	@echo "#KERNEL_USB is not set" >> devices.txt
endif


ifdef KERNEL_USB_G_SERIAL
	@echo -e "# Gadget serial" >> devices.txt
	@echo -e "/dev/ttygserial\tc\t666\t0\t0\t127\t0\t0\t1\t1" >> devices.txt
endif

ifdef KERNEL_PXA_GPIO
	@echo "#KERNEL_PXA_GPIO" >> devices.txt
	# GPIO devices could go here
else
	@echo "#KERNEL_PXA_GPIO is not set" >> devices.txt
endif

ifdef KERNEL_BLK_DEV_LOOP
	@echo "#KERNEL_BLK_DEV_LOOP" >> devices.txt
   # make loopback devices
   ifdef KERNEL_DEVFS_FS
		@echo "#KERNEL_DEVFS_FS" >> devices.txt
   else
		@echo "#KERNEL_DEVFS_FS is not set" >> devices.txt
		@echo -e "/dev/loop\tb\t666\t0\t0\t7\t0\t0\t1\t8" >> devices.txt
   endif
else
	@echo "#KERNEL_BLK_DEV_LOOP is not set" >> devices.txt
endif

ifdef KERNEL_FB
	@echo "#KERNEL_FB_PXA" >> devices.txt
endif

ifdef KERNEL_DEVFS_FS
	@echo -e "/dev/fb0\t\tc\t666\t0\t0\t29\t0\t0\t0\t-" >> devices.txt
	@echo -e "/dev/fb\t\tc\t666\t0\t0\t29\t0\t0\t0\t-" >> devices.txt
else
	@echo -e "/dev/fb\t\tc\t666\t0\t0\t29\t0\t0\t0\t-" >> devices.txt
endif   

ifeq (y, $(KERNEL_FB_SM501YUV))
	@echo -e "/dev/yuv\t\tc\t666\t0\t0\t155\t0\t0\t0\t-" >> devices.txt
else
	@echo "#KERNEL_FB_SM501YUV is not set" >> devices.txt
endif
ifdef KERNEL_FB_LCD122X32
	@echo "#KERNEL_FB_LCD122X32" >> devices.txt
	@echo -e "/dev/lcd\t\tc\t666\t0\t0\t156\t0\t0\t0\t-" >> devices.txt
else
	@echo "#KERNEL_FB_LCD122X32 is not set" >> devices.txt
endif
ifdef KERNEL_CPU_32
	@echo "#KERNEL_CPU_32" >> devices.txt
else
	@echo "#KERNEL_CPU_32 is not set" >> devices.txt
endif
ifdef KERNEL_CPU_32v5
	@echo "#KERNEL_CPU_32v5" >> devices.txt
else
	@echo "#KERNEL_CPU_32v5 is not set" >> devices.txt
endif
ifdef KERNEL_CPU_XSCALE
	@echo "#KERNEL_CPU_XSCALE" >> devices.txt
else
	@echo "#KERNEL_CPU_XSCALE is not set" >> devices.txt
endif
ifdef KERNEL_CPU_32v4
	@echo "#KERNEL_CPU_32v4" >> devices.txt
else
	@echo "#KERNEL_CPU_32v4 is not set" >> devices.txt
endif
ifdef KERNEL_ARCH_PXA
	@echo "#KERNEL_ARCH_PXA" >> devices.txt
else
	@echo "#KERNEL_ARCH_PXA is not set" >> devices.txt
endif
ifdef KERNEL_ARCH_SCANPASS
	@echo "#KERNEL_ARCH_SCANPASS" >> devices.txt
else
	@echo "#KERNEL_ARCH_SCANPASS is not set" >> devices.txt
endif
ifeq (y, $(KERNEL_UCB1400_TS))
	@echo "#KERNEL_UCB1400_TS" >> devices.txt
	@echo -e "/dev/touchscreen\t\tc\t666\t0\t0\t10\t14\t0\t0\t-" >> devices.txt
else
	@echo "#KERNEL_UCB1400_TS is not set" >> devices.txt
endif
ifdef KERNEL_MMC_PXA
	@echo "#KERNEL_MMC_PXA" >> devices.txt
	@echo -e "/dev/mmc\t\tb\t666\t0\t0\t241\t0\t0\t0\t-" >> devices.txt
	@echo -e "/dev/mmcblk0\t\tb\t666\t0\t0\t241\t1\t0\t1\t-" >> devices.txt
else
	@echo "#KERNEL_MMC_PXA is not set" >> devices.txt
endif
ifdef KERNEL_BD_GENTIMER
	@echo "#KERNEL_BD_GENTIMER" >> devices.txt
else
	@echo "#KERNEL_BD_GENTIMER is not set" >> devices.txt
endif
ifdef KERNEL_SOUND_PXA_AC97
	@echo "#KERNEL_SOUND_PXA_AC97" >> devices.txt
	@echo -e "/dev/mixer\t\tc\t666\t0\t0\t14\t0\t0\t0\t-" >> devices.txt
	@echo -e "/dev/sequencer\t\tc\t666\t0\t0\t14\t1\t0\t0\t-" >> devices.txt
	@echo -e "/dev/midi00\t\tc\t666\t0\t0\t14\t2\t0\t0\t-" >> devices.txt
	@echo -e "/dev/dsp\t\tc\t666\t0\t0\t14\t3\t0\t0\t-" >> devices.txt
	@echo -e "/dev/audio\t\tc\t666\t0\t0\t14\t4\t0\t0\t-" >> devices.txt
	@echo -e "/dev/sndstat\t\tc\t666\t0\t0\t14\t6\t0\t0\t-" >> devices.txt
	@echo -e "/dev/audioctl\t\tc\t666\t0\t0\t14\t7\t0\t0\t-" >> devices.txt
# 
# skipping sequencer2, mixer1, midi01, dsp1, audio1, midi02, midi03
else
	@echo "#KERNEL_SOUND_PXA_AC97 is not set" >> devices.txt
endif
ifdef KERNEL_MTD
	@echo "#KERNEL_MTD" >> devices.txt
else
	@echo "#KERNEL_MTD is not set" >> devices.txt
endif
ifdef KERNEL_MTD_PARTITIONS
	@echo "#KERNEL_MTD_PARTITIONS" >> devices.txt
else
	@echo "#KERNEL_MTD_PARTITIONS is not set" >> devices.txt
endif
ifdef KERNEL_MTD_CMDLINE_PARTS
	@echo "#KERNEL_MTD_CMDLINE_PARTS" >> devices.txt
else
	@echo "#KERNEL_MTD_CMDLINE_PARTS is not set" >> devices.txt
endif
ifdef KERNEL_MTD_CHAR
	@echo "#KERNEL_MTD_CHAR" >> devices.txt
	@echo -e "/dev/mtd\t\tc\t666\t0\t0\t90\t0\t0\t2\t8" >> devices.txt
	@echo -e "/dev/mtdr\t\tc\t666\t0\t0\t90\t1\t0\t2\t8" >> devices.txt
else
	@echo "#KERNEL_MTD_CHAR is not set" >> devices.txt
endif
ifdef KERNEL_MTD_BLOCK
		@echo "#KERNEL_MTD_BLOCK" >> devices.txt
	@echo -e "/dev/mtdblock\t\tb\t666\t0\t0\t31\t0\t0\t1\t15" >> devices.txt
#	@echo -e "/dev/ftla\t\tb\t666\t0\t0\t44\t0\t0\t1\t15" >> devices.txt                    do we need this ??
#	@echo -e "/dev/ftlb\t\tb\t666\t0\t0\t44\t16\t16\t1\t15" >> devices.txt                  doesn't seem to work with mkcramfs
#
# I skipped ftlc0-15, nftla-c 0-15 as well
#
else
	@echo "#KERNEL_MTD_BLOCK is not set" >> devices.txt
endif
	@echo "#BOARD TYPE $(KERNEL_BOARDTYPE)" >> devices.txt
ifeq ("BD2003", $(KERNEL_BOARDTYPE))
	@echo -e "/dev/Red\t\tc\t666\t0\t0\t254\t7\t0\t0\t-" >> devices.txt
	@echo -e "/dev/Doorlock\t\tc\t666\t0\t0\t254\t9\t0\t0\t-" >> devices.txt
	@echo -e "/dev/Amber\t\tc\t666\t0\t0\t254\t15\t0\t0\t-" >> devices.txt
	@echo -e "/dev/Feedback2\t\tc\t666\t0\t0\t254\t16\t0\t0\t-" >> devices.txt
	@echo -e "/dev/Feedback\t\tc\t666\t0\t0\t254\t17\t0\t0\t-" >> devices.txt
	@echo -e "/dev/Turnstile\t\tc\t666\t0\t0\t254\t9\t0\t0\t-" >> devices.txt
	@echo -e "/dev/Green\t\tc\t666\t0\t0\t254\t33\t0\t0\t-" >> devices.txt
else
	@echo "#KERNEL_BOARDTYPE is not BD2003" >> devices.txt
ifeq ("BD2004", $(KERNEL_BOARDTYPE))
	   @echo "#KERNEL_BOARDTYPE is BD2004" >> devices.txt
		@echo -e "/dev/gp16in\t\tc\t666\t0\t0\t254\t16\t0\t0\t-" >> devices.txt
		@echo -e "/dev/gp17in\t\tc\t666\t0\t0\t254\t17\t0\t0\t-" >> devices.txt
		@echo -e "/dev/gp2out\t\tc\t666\t0\t0\t254\t2\t0\t0\t-" >> devices.txt
		@echo -e "/dev/gp9out\t\tc\t666\t0\t0\t254\t9\t0\t0\t-" >> devices.txt
		@echo -e "/dev/gp32out\t\tc\t666\t0\t0\t254\t32\t0\t0\t-" >> devices.txt
		@echo -e "/dev/gp44out\t\tc\t666\t0\t0\t254\t44\t0\t0\t-" >> devices.txt
		@echo -e "/dev/gp45out\t\tc\t666\t0\t0\t254\t45\t0\t0\t-" >> devices.txt
		@echo -e "/dev/gp47out\t\tc\t666\t0\t0\t254\t47\t0\t0\t-" >> devices.txt
ifdef CONFIG_SUITEDEMO
   		@echo -e "/dev/doorLock\t\tc\t666\t0\t0\t254\t32\t0\t0\t-" >> devices.txt
   		@echo -e "/dev/custLED\t\tc\t666\t0\t0\t254\t45\t0\t0\t-" >> devices.txt
   		@echo -e "/dev/customIn\t\tc\t666\t0\t0\t254\t16\t0\t0\t-" >> devices.txt
else
   		@echo "#CONFIG_SUITEDEMO is not set" >> devices.txt
ifdef CONFIG_TMSUITE
   			@echo -e "/dev/doorLock\t\tc\t666\t0\t0\t254\t32\t0\t0\t-" >> devices.txt
   			@echo -e "/dev/custLED\t\tc\t666\t0\t0\t254\t45\t0\t0\t-" >> devices.txt
   			@echo -e "/dev/customIn\t\tc\t666\t0\t0\t254\t16\t0\t0\t-" >> devices.txt
else
   			@echo "#CONFIG_TMSUITE is not set" >> devices.txt
endif
ifdef CONFIG_TMTURNSTILE
			@echo -e "/dev/turnstile\t\tc\t666\t0\t0\t254\t32\t0\t0\t-" >> devices.txt
			@echo -e "/dev/turnstile2\t\tc\t666\t0\t0\t254\t45\t0\t0\t-" >> devices.txt
			@echo -e "/dev/feedback\t\tc\t666\t0\t0\t254\t16\t0\t0\t-" >> devices.txt
	   	@echo -e "/dev/feedback2\t\tc\t666\t0\t0\t254\t17\t0\t0\t-" >> devices.txt
else
			@echo "#CONFIG_TMSUITE is not set" >> devices.txt
endif
endif
else
	@echo "#KERNEL_BOARDTYPE is not BD2004" >> devices.txt
endif
ifeq ("NEON", $(KERNEL_BOARDTYPE))
	@echo "#KERNEL_BOARDTYPE is NEON" >> devices.txt
endif
endif
	@echo "---> finished building devices.txt"
        

