#SHELL := /bin/bash
BUILDID=$(shell date +%Y/%m/%d)
TOS = linux
TARCH = x86_64
#TARCH = x86 x86_64 armv6j armv6j_hardfp armv7a_hardfp
CCOMP = gnuc
RELEASE = 1.0


INCLUDEPATH = -Isrc/lib/system/$(CCOMP)/$(TARCH)

SETPATH = CFLAGS=$(INCLUDEPATH)  PATH=.:/bin:/usr/bin MODULES=.:src/lib:src/lib/v4:src/lib/system:src/lib/system/$(CCOMP):src/lib/system/$(CCOMP)/$(TARCH):src/lib/ulm:src/lib/ulm/gnuc:src/lib/ooc2:src/lib/ooc2/gnuc:src/lib/ooc:src/lib/ooc/lowlevel:src/voc:src/voc/gnuc:src/voc/gnuc/$(TARCH):src/tools/ocat:src/tools/browser:src/tools/vocparam:src/tools/coco:src/test

VOC = voc
VOCSTATIC = $(SETPATH) ./vocstatic
VOCPARAM = $(shell ./vocparam > voc.par)
VERSION = GNU_Linux_$(TARCH)
LIBNAME = VishapOberon
LIBRARY = lib$(LIBNAME)

ifndef PREFIX
PREFIX = /opt/voc-$(RELEASE)
endif

CCOPT = -fPIC $(INCLUDEPATH) -g

CC = cc $(CCOPT) -c 
CL = cc $(CCOPT) 
LD = cc -shared -o $(LIBRARY).so
# s is necessary to create index inside a archive
ARCHIVE = ar rcs $(LIBRARY).a

#%.c: %.Mod
#%.o: %.c
#	$(CC) $(input)

all: stage2 stage3 stage4 stage5 stage6 stage7

# when porting to new platform:
# * put corresponding .par file into current directory. it can be generated on the target platform by compiling vocparam (stage0) and running (stage1)
# * run make port0 - this will generate C source files for the target architecture
# * move the source tree to the target machine, and compile (or compile here via crosscompiler) (port1)
port0: stage2 stage3 stage4

# now compile C source files for voc, showdef and ocat on target machine (or by using crosscompiler)
port1: stage5
# after you have "voc" compiled for target architecture. replace vocstatic with it and run make on target platform to get everything compiled

# this builds binary which generates voc.par
stage0: src/tools/vocparam/vocparam.c
	$(CL) -I src/lib -o vocparam src/tools/vocparam/vocparam.c

# this creates voc.par for a host architecture.
# comment this out if you need to build a compiler for a different architecture.
stage1: 
	#rm voc.par
	#$(shell "./vocparam > voc.par")
	#./vocparam > voc.par
	$(VOCPARAM)

# this copies necessary voc.par to the current directory.
# skip this if you are building compiler for the host architecture.
stage2:
	cp src/par/voc.par.$(CCOMP).$(TARCH) voc.par
#	cp src/par/voc.par.gnu.x86_64 voc.par
#	cp src/par/voc.par.gnu.x86 voc.par
#	cp src/par/voc.par.gnu.armv6 voc.par
#	cp src/par/voc.par.gnu.armv7 voc.par

# this prepares modules necessary to build the compiler itself
stage3:

	$(VOCSTATIC) -siapxPS SYSTEM.Mod 
	$(VOCSTATIC) -sPS Args.Mod Console.Mod Unix.Mod 
	$(VOCSTATIC) -sPS oocOakStrings.Mod architecture.Mod version.Mod Kernel.Mod Modules.Mod
	$(VOCSTATIC) -sxPS Files.Mod 
	$(VOCSTATIC) -sPS Reals.Mod CmdlnTexts.Mod errors.Mod

# build the compiler
stage4:
	$(VOCSTATIC) -sPS extTools.Mod
	$(VOCSTATIC) -sPS OPM.cmdln.Mod 
	$(VOCSTATIC) -sxPS OPS.Mod 
	$(VOCSTATIC) -sPS OPT.Mod OPC.Mod OPV.Mod OPB.Mod OPP.Mod
	$(VOCSTATIC) -smPS voc.Mod
	$(VOCSTATIC) -smPS BrowserCmd.Mod
	$(VOCSTATIC) -smPS OCatCmd.Mod

#this is to build the compiler from C sources.
#this is a way to create a bootstrap binary.
stage5:
	$(CC) SYSTEM.c Args.c Console.c Modules.c Unix.c \
	oocOakStrings.c architecture.c version.c Kernel.c Files.c Reals.c CmdlnTexts.c \
	version.c extTools.c \
	OPM.c OPS.c OPT.c OPC.c OPV.c OPB.c OPP.c errors.c

	$(CL) -static  voc.c -o voc \
	SYSTEM.o Args.o Console.o Modules.o Unix.o \
	oocOakStrings.o architecture.o version.o Kernel.o Files.o Reals.o CmdlnTexts.o \
	extTools.o \
	OPM.o OPS.o OPT.o OPC.o OPV.o OPB.o OPP.o errors.o
	$(CL) BrowserCmd.c -o showdef \
	SYSTEM.o Args.o Console.o Modules.o Unix.o oocOakStrings.o architecture.o version.o Kernel.o Files.o Reals.o CmdlnTexts.o \
	OPM.o OPS.o OPT.o OPV.o OPC.o errors.o

	$(CL) OCatCmd.c -o ocat \
	SYSTEM.o Args.o Console.o Modules.o Unix.o oocOakStrings.o architecture.o version.o Kernel.o Files.o Reals.o CmdlnTexts.o



# build all library files
stage6:
	$(VOCSTATIC) -sP	oocAscii.Mod
	$(VOCSTATIC) -sP	oocStrings.Mod
	$(VOCSTATIC) -sP	oocStrings2.Mod
	$(VOCSTATIC) -sP	oocCharClass.Mod
	$(VOCSTATIC) -sP	oocConvTypes.Mod
	$(VOCSTATIC) -sP	oocIntConv.Mod
	$(VOCSTATIC) -sP	oocIntStr.Mod
	$(VOCSTATIC) -sP	oocSysClock.Mod
	$(VOCSTATIC) -sP	oocTime.Mod
#	$(VOCSTATIC) -s	oocLongStrings.Mod
#	$(CC)		oocLongStrings.c
#	$(VOCSTATIC) -s	oocMsg.Mod
#	$(CC)		oocMsg.c


	$(VOCSTATIC) -sP ooc2Strings.Mod
	$(VOCSTATIC) -sP ooc2Ascii.Mod
	$(VOCSTATIC) -sP ooc2CharClass.Mod
	$(VOCSTATIC) -sP ooc2ConvTypes.Mod
	$(VOCSTATIC) -sP ooc2IntConv.Mod
	$(VOCSTATIC) -sP ooc2IntStr.Mod
	$(VOCSTATIC) -sP ooc2Real0.Mod
	$(VOCSTATIC) -sP oocwrapperlibc.Mod
	$(VOCSTATIC) -sP ulmSYSTEM.Mod
	$(VOCSTATIC) -sP ulmASCII.Mod ulmSets.Mod
	$(VOCSTATIC) -sP ulmObjects.Mod ulmDisciplines.Mod
	$(VOCSTATIC) -sP ulmPriorities.Mod ulmServices.Mod ulmEvents.Mod ulmResources.Mod  ulmForwarders.Mod ulmRelatedEvents.Mod

stage7:
	#objects := $(wildcard *.o)
	#$(LD) objects
	$(ARCHIVE) *.o 
	#$(ARCHIVE) objects
	$(LD) *.o
	echo "$(PREFIX)/lib" >> 05vishap.conf

clean:
#	rm_objects := rm $(wildcard *.o)
#	objects
	rm *.o
	rm *.sym
	rm *.h
	rm *.c
	rm *.a
	rm *.so

coco:
	$(JET) Sets.Mod Oberon.Mod CRS.Mod CRT.Mod CRA.Mod CRX.Mod CRP.Mod Coco.Mod -m
	$(CC) Sets.c Oberon.c CRS.c CRT.c CRA.c CRX.c CRP.c
	$(CL) -static -o Coco Coco.c Sets.o Oberon.o CRS.o CRT.o CRA.o CRX.o CRP.o CmdlnTexts.o SYSTEM.o Files.o -L. -lOberon -L/usr/lib -ldl

install:
	test -d $(PREFIX)/bin | mkdir -p $(PREFIX)/bin
	cp voc $(PREFIX)/bin/
	cp showdef $(PREFIX)/bin/
	cp ocat $(PREFIX)/bin/
	cp -a src $(PREFIX)/

	test -d $(PREFIX)/lib/voc | mkdir -p $(PREFIX)/lib/voc
	test -d $(PREFIX)/lib/voc/ | mkdir -p $(PREFIX)/lib/voc
	test -d $(PREFIX)/lib/voc/obj | mkdir -p $(PREFIX)/lib/voc/obj
	test -d $(PREFIX)/lib/voc/sym | mkdir -p $(PREFIX)/lib/voc/sym

	cp $(LIBRARY).so $(PREFIX)/lib
	cp $(LIBRARY).a $(PREFIX)/lib
	cp *.c $(PREFIX)/lib/voc/obj/
	cp *.h $(PREFIX)/lib/voc/obj/
	cp *.sym $(PREFIX)/lib/voc/sym/

	cp 05vishap.conf /etc/ld.so.conf.d/
	ldconfig

#        cp *.o $(PREFIX)/lib/voc/$(RELEASE)/obj/
uninstall:
	rm -rf $(PREFIX)