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

ECHO?=`which echo`

all:
	@$(ECHO) -e "#\n#<name>\t\t\t<type>\t<mode>\t<uid>\t<gid>\t<major>\t<minor>\t<start>\t<inc>\t<count>\n#" > devices.txt
	@$(ECHO) -e "/dev\t\t\td\t666\t0\t0\t-\t-\t-\t-\t-" >> devices.txt
ifdef KERNEL_ARCH_PXA
	@$(ECHO) "#KERNEL_ARCH_PXA" >> devices.txt
	@$(ECHO) -e "/dev/input\t\td\t666\t0\t0\t-\t-\t-\t-\t-" >> devices.txt
	@$(ECHO) -e "/dev/pts\t\td\t666\t0\t0\t-\t-\t-\t-\t-" >> devices.txt
	@$(ECHO) -e "/dev/ram\t\tb\t666\t0\t0\t1\t0\t0\t1\t4" >> devices.txt
	@$(ECHO) -e "/dev/null\t\tc\t666\t0\t0\t1\t3\t0\t0\t-" >> devices.txt
	@$(ECHO) -e "/dev/zero\t\tc\t666\t0\t0\t1\t5\t0\t0\t-" >> devices.txt
	@$(ECHO) -e "/dev/ptmx\t\tc\t666\t0\t0\t5\t2\t0\t0\t-" >> devices.txt
	@$(ECHO) -e "/dev/ptyp\t\tc\t666\t0\t0\t2\t0\t0\t1\t2" >> devices.txt
	@$(ECHO) -e "/dev/ttyFB\t\tc\t666\t0\t0\t4\t0\t0\t1\t1" >> devices.txt
	@$(ECHO) -e "/dev/ttyS\t\tc\t666\t0\t0\t4\t64\t0\t1\t3" >> devices.txt
	@$(ECHO) -e "/dev/systty\t\tc\t666\t0\t0\t4\t0\t0\t0\t-" >> devices.txt
	@$(ECHO) -e "/dev/tty\t\tc\t666\t0\t0\t5\t0\t0\t0\t-" >> devices.txt
	@$(ECHO) -e "/dev/vcs\t\tc\t666\t0\t0\t7\t0\t0\t1\t3" >> devices.txt
	@$(ECHO) -e "/dev/console\t\tc\t666\t0\t0\t5\t1\t0\t0\t-" >> devices.txt
	@$(ECHO) -e "/dev/cua0\t\tc\t666\t0\t0\t5\t64\t0\t0\t-" >> devices.txt
	@$(ECHO) -e "/dev/rawctl\t\tc\t666\t0\t0\t162\t0\t0\t0\t-" >> devices.txt
	@$(ECHO) -e "/dev/timer\t\tc\t666\t0\t0\t252\t0\t0\t0\t-" >> devices.txt
	@$(ECHO) -e "/dev/random\t\tc\t666\t0\t0\t1\t8\t0\t0\t-" >> devices.txt
	@$(ECHO) -e "/dev/urandom\t\tc\t666\t0\t0\t1\t9\t0\t0\t-" >> devices.txt
	@$(ECHO) -e "/dev/raw\t\td\t777\t0\t0\t-\t-\t-\t-\t-" >> devices.txt                               
	@$(ECHO) -e "/dev/raw/raw1\t\tc\t666\t0\t0\t162\t1\t0\t0\t-" >> devices.txt
# I'm skipping /dev/vcs0-12
else
	$(error "??? KERNEL_ARCH_PXA is not set ???" )
endif
ifdef KERNEL_PCMCIA_PXA
	@$(ECHO) "#KERNEL_PCMCIA_PXA" >> devices.txt
else
	@$(ECHO) "#KERNEL_PCMCIA_PXA is not set" >> devices.txt
endif
ifdef KERNEL_PXA_RTC
	@$(ECHO) "#KERNEL_PXA_RTC" >> devices.txt
else
	@$(ECHO) "#KERNEL_PXA_RTC is not set" >> devices.txt
endif


ifdef KERNEL_USB
	@$(ECHO) "#KERNEL_PXA_USB" >> devices.txt
	@$(ECHO) -e "/dev/usb\td\t666\t0\t0\t-\t-\t-\t-\t-" >> devices.txt
ifdef KERNEL_USB_PRINTER
		@$(ECHO) -e "/dev/usb/lp0\tc\t666\t0\t0\t180\t0\t0\t0\t-" >> devices.txt
else   
	   @$(ECHO) "#KERNEL_USB_PRINTER is not set" >> devices.txt
endif   
ifdef KERNEL_USB_QC
	   @$(ECHO) -e "/dev/video0\tc\t666\t0\t0\t81\t0\t0\t0\t-" >> devices.txt
else   
	   @$(ECHO) "#KERNEL_USB_QC is not set" >> devices.txt
endif
else
	@$(ECHO) "#KERNEL_USB is not set" >> devices.txt
endif


ifdef KERNEL_USB_G_SERIAL
	@$(ECHO) -e "# Gadget serial" >> devices.txt
	@$(ECHO) -e "/dev/ttygserial\tc\t666\t0\t0\t127\t0\t0\t1\t1" >> devices.txt
endif

ifdef KERNEL_PXA_GPIO
	@$(ECHO) "#KERNEL_PXA_GPIO" >> devices.txt
	# GPIO devices could go here
else
	@$(ECHO) "#KERNEL_PXA_GPIO is not set" >> devices.txt
endif

ifdef KERNEL_BLK_DEV_LOOP
	@$(ECHO) "#KERNEL_BLK_DEV_LOOP" >> devices.txt
   # make loopback devices
   ifdef KERNEL_DEVFS_FS
		@$(ECHO) "#KERNEL_DEVFS_FS" >> devices.txt
   else
		@$(ECHO) "#KERNEL_DEVFS_FS is not set" >> devices.txt
		@$(ECHO) -e "/dev/loop\tb\t666\t0\t0\t7\t0\t0\t1\t8" >> devices.txt
   endif
else
	@$(ECHO) "#KERNEL_BLK_DEV_LOOP is not set" >> devices.txt
endif

ifdef KERNEL_FB
	@$(ECHO) "#KERNEL_FB_PXA" >> devices.txt
endif

ifdef KERNEL_DEVFS_FS
	@$(ECHO) -e "/dev/fb0\t\tc\t666\t0\t0\t29\t0\t0\t0\t-" >> devices.txt
	@$(ECHO) -e "/dev/fb\t\tc\t666\t0\t0\t29\t0\t0\t0\t-" >> devices.txt
else
	@$(ECHO) -e "/dev/fb\t\tc\t666\t0\t0\t29\t0\t0\t0\t-" >> devices.txt
endif   

ifeq (y, $(KERNEL_FB_SM501YUV))
	@$(ECHO) -e "/dev/yuv\t\tc\t666\t0\t0\t155\t0\t0\t0\t-" >> devices.txt
else
	@$(ECHO) "#KERNEL_FB_SM501YUV is not set" >> devices.txt
endif
ifdef KERNEL_FB_LCD122X32
	@$(ECHO) "#KERNEL_FB_LCD122X32" >> devices.txt
	@$(ECHO) -e "/dev/lcd\t\tc\t666\t0\t0\t156\t0\t0\t0\t-" >> devices.txt
else
	@$(ECHO) "#KERNEL_FB_LCD122X32 is not set" >> devices.txt
endif
ifdef KERNEL_CPU_32
	@$(ECHO) "#KERNEL_CPU_32" >> devices.txt
else
	@$(ECHO) "#KERNEL_CPU_32 is not set" >> devices.txt
endif
ifdef KERNEL_CPU_32v5
	@$(ECHO) "#KERNEL_CPU_32v5" >> devices.txt
else
	@$(ECHO) "#KERNEL_CPU_32v5 is not set" >> devices.txt
endif
ifdef KERNEL_CPU_XSCALE
	@$(ECHO) "#KERNEL_CPU_XSCALE" >> devices.txt
else
	@$(ECHO) "#KERNEL_CPU_XSCALE is not set" >> devices.txt
endif
ifdef KERNEL_CPU_32v4
	@$(ECHO) "#KERNEL_CPU_32v4" >> devices.txt
else
	@$(ECHO) "#KERNEL_CPU_32v4 is not set" >> devices.txt
endif
ifdef KERNEL_ARCH_PXA
	@$(ECHO) "#KERNEL_ARCH_PXA" >> devices.txt
else
	@$(ECHO) "#KERNEL_ARCH_PXA is not set" >> devices.txt
endif
ifdef KERNEL_ARCH_SCANPASS
	@$(ECHO) "#KERNEL_ARCH_SCANPASS" >> devices.txt
else
	@$(ECHO) "#KERNEL_ARCH_SCANPASS is not set" >> devices.txt
endif
ifeq (y, $(KERNEL_UCB1400_TS))
	@$(ECHO) "#KERNEL_UCB1400_TS" >> devices.txt
	@$(ECHO) -e "/dev/touchscreen\t\tc\t666\t0\t0\t10\t14\t0\t0\t-" >> devices.txt
else
	@$(ECHO) "#KERNEL_UCB1400_TS is not set" >> devices.txt
endif
ifdef KERNEL_MMC_PXA
	@$(ECHO) "#KERNEL_MMC_PXA" >> devices.txt
	@$(ECHO) -e "/dev/mmc\t\tb\t666\t0\t0\t241\t0\t0\t0\t-" >> devices.txt
	@$(ECHO) -e "/dev/mmcblk0\t\tb\t666\t0\t0\t241\t1\t0\t1\t-" >> devices.txt
else
	@$(ECHO) "#KERNEL_MMC_PXA is not set" >> devices.txt
endif
ifdef KERNEL_BD_GENTIMER
	@$(ECHO) "#KERNEL_BD_GENTIMER" >> devices.txt
else
	@$(ECHO) "#KERNEL_BD_GENTIMER is not set" >> devices.txt
endif
ifdef KERNEL_SOUND_PXA_AC97
	@$(ECHO) "#KERNEL_SOUND_PXA_AC97" >> devices.txt
	@$(ECHO) -e "/dev/mixer\t\tc\t666\t0\t0\t14\t0\t0\t0\t-" >> devices.txt
	@$(ECHO) -e "/dev/sequencer\t\tc\t666\t0\t0\t14\t1\t0\t0\t-" >> devices.txt
	@$(ECHO) -e "/dev/midi00\t\tc\t666\t0\t0\t14\t2\t0\t0\t-" >> devices.txt
	@$(ECHO) -e "/dev/dsp\t\tc\t666\t0\t0\t14\t3\t0\t0\t-" >> devices.txt
	@$(ECHO) -e "/dev/audio\t\tc\t666\t0\t0\t14\t4\t0\t0\t-" >> devices.txt
	@$(ECHO) -e "/dev/sndstat\t\tc\t666\t0\t0\t14\t6\t0\t0\t-" >> devices.txt
	@$(ECHO) -e "/dev/audioctl\t\tc\t666\t0\t0\t14\t7\t0\t0\t-" >> devices.txt
# 
# skipping sequencer2, mixer1, midi01, dsp1, audio1, midi02, midi03
else
	@$(ECHO) "#KERNEL_SOUND_PXA_AC97 is not set" >> devices.txt
endif
ifdef KERNEL_MTD
	@$(ECHO) "#KERNEL_MTD" >> devices.txt
else
	@$(ECHO) "#KERNEL_MTD is not set" >> devices.txt
endif
ifdef KERNEL_MTD_PARTITIONS
	@$(ECHO) "#KERNEL_MTD_PARTITIONS" >> devices.txt
else
	@$(ECHO) "#KERNEL_MTD_PARTITIONS is not set" >> devices.txt
endif
ifdef KERNEL_MTD_CMDLINE_PARTS
	@$(ECHO) "#KERNEL_MTD_CMDLINE_PARTS" >> devices.txt
else
	@$(ECHO) "#KERNEL_MTD_CMDLINE_PARTS is not set" >> devices.txt
endif
ifdef KERNEL_MTD_CHAR
	@$(ECHO) "#KERNEL_MTD_CHAR" >> devices.txt
	@$(ECHO) -e "/dev/mtd\t\tc\t666\t0\t0\t90\t0\t0\t2\t8" >> devices.txt
	@$(ECHO) -e "/dev/mtdr\t\tc\t666\t0\t0\t90\t1\t0\t2\t8" >> devices.txt
else
	@$(ECHO) "#KERNEL_MTD_CHAR is not set" >> devices.txt
endif
ifdef KERNEL_MTD_BLOCK
		@$(ECHO) "#KERNEL_MTD_BLOCK" >> devices.txt
	@$(ECHO) -e "/dev/mtdblock\t\tb\t666\t0\t0\t31\t0\t0\t1\t15" >> devices.txt
#	@$(ECHO) -e "/dev/ftla\t\tb\t666\t0\t0\t44\t0\t0\t1\t15" >> devices.txt                    do we need this ??
#	@$(ECHO) -e "/dev/ftlb\t\tb\t666\t0\t0\t44\t16\t16\t1\t15" >> devices.txt                  doesn't seem to work with mkcramfs
#
# I skipped ftlc0-15, nftla-c 0-15 as well
#
else
	@$(ECHO) "#KERNEL_MTD_BLOCK is not set" >> devices.txt
endif
	@$(ECHO) "#BOARD TYPE $(KERNEL_BOARDTYPE)" >> devices.txt
ifeq ("BD2003", $(KERNEL_BOARDTYPE))
	@$(ECHO) -e "/dev/Red\t\tc\t666\t0\t0\t254\t7\t0\t0\t-" >> devices.txt
	@$(ECHO) -e "/dev/Doorlock\t\tc\t666\t0\t0\t254\t9\t0\t0\t-" >> devices.txt
	@$(ECHO) -e "/dev/Amber\t\tc\t666\t0\t0\t254\t15\t0\t0\t-" >> devices.txt
	@$(ECHO) -e "/dev/Feedback2\t\tc\t666\t0\t0\t254\t16\t0\t0\t-" >> devices.txt
	@$(ECHO) -e "/dev/Feedback\t\tc\t666\t0\t0\t254\t17\t0\t0\t-" >> devices.txt
	@$(ECHO) -e "/dev/Turnstile\t\tc\t666\t0\t0\t254\t9\t0\t0\t-" >> devices.txt
	@$(ECHO) -e "/dev/Green\t\tc\t666\t0\t0\t254\t33\t0\t0\t-" >> devices.txt
else
	@$(ECHO) "#KERNEL_BOARDTYPE is not BD2003" >> devices.txt
ifeq ("BD2004", $(KERNEL_BOARDTYPE))
	   @$(ECHO) "#KERNEL_BOARDTYPE is BD2004" >> devices.txt
		@$(ECHO) -e "/dev/gp16in\t\tc\t666\t0\t0\t254\t16\t0\t0\t-" >> devices.txt
		@$(ECHO) -e "/dev/gp17in\t\tc\t666\t0\t0\t254\t17\t0\t0\t-" >> devices.txt
		@$(ECHO) -e "/dev/gp2out\t\tc\t666\t0\t0\t254\t2\t0\t0\t-" >> devices.txt
		@$(ECHO) -e "/dev/gp9out\t\tc\t666\t0\t0\t254\t9\t0\t0\t-" >> devices.txt
		@$(ECHO) -e "/dev/gp32out\t\tc\t666\t0\t0\t254\t32\t0\t0\t-" >> devices.txt
		@$(ECHO) -e "/dev/gp44out\t\tc\t666\t0\t0\t254\t44\t0\t0\t-" >> devices.txt
		@$(ECHO) -e "/dev/gp45out\t\tc\t666\t0\t0\t254\t45\t0\t0\t-" >> devices.txt
		@$(ECHO) -e "/dev/gp47out\t\tc\t666\t0\t0\t254\t47\t0\t0\t-" >> devices.txt
ifdef CONFIG_SUITEDEMO
   		@$(ECHO) -e "/dev/doorLock\t\tc\t666\t0\t0\t254\t32\t0\t0\t-" >> devices.txt
   		@$(ECHO) -e "/dev/custLED\t\tc\t666\t0\t0\t254\t45\t0\t0\t-" >> devices.txt
   		@$(ECHO) -e "/dev/customIn\t\tc\t666\t0\t0\t254\t16\t0\t0\t-" >> devices.txt
else
   		@$(ECHO) "#CONFIG_SUITEDEMO is not set" >> devices.txt
ifdef CONFIG_TMSUITE
   			@$(ECHO) -e "/dev/doorLock\t\tc\t666\t0\t0\t254\t32\t0\t0\t-" >> devices.txt
   			@$(ECHO) -e "/dev/custLED\t\tc\t666\t0\t0\t254\t45\t0\t0\t-" >> devices.txt
   			@$(ECHO) -e "/dev/customIn\t\tc\t666\t0\t0\t254\t16\t0\t0\t-" >> devices.txt
else
   			@$(ECHO) "#CONFIG_TMSUITE is not set" >> devices.txt
endif
ifdef CONFIG_TMTURNSTILE
			@$(ECHO) -e "/dev/turnstile\t\tc\t666\t0\t0\t254\t32\t0\t0\t-" >> devices.txt
			@$(ECHO) -e "/dev/turnstile2\t\tc\t666\t0\t0\t254\t45\t0\t0\t-" >> devices.txt
			@$(ECHO) -e "/dev/feedback\t\tc\t666\t0\t0\t254\t16\t0\t0\t-" >> devices.txt
	   	@$(ECHO) -e "/dev/feedback2\t\tc\t666\t0\t0\t254\t17\t0\t0\t-" >> devices.txt
else
			@$(ECHO) "#CONFIG_TMSUITE is not set" >> devices.txt
endif
endif
else
	@$(ECHO) "#KERNEL_BOARDTYPE is not BD2004" >> devices.txt
endif
ifeq ("NEON", $(KERNEL_BOARDTYPE))
	@$(ECHO) "#KERNEL_BOARDTYPE is NEON" >> devices.txt
endif
endif
	@$(ECHO) "---> finished building devices.txt"
        

