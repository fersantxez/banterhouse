##-----------------------------LICENSE NOTICE------------------------------------
##  This file is part of CPCtelera: An Amstrad CPC Game Engine 
##  Copyright (C) 2015 ronaldo / Fremos / Cheesetea / ByteRealms (@FranGallegoBR)
##
##  This program is free software: you can redistribute it and/or modify
##  it under the terms of the GNU Lesser General Public License as published by
##  the Free Software Foundation, either version 3 of the License, or
##  (at your option) any later version.
##
##  This program is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU Lesser General Public License for more details.
##
##  You should have received a copy of the GNU Lesser General Public License
##  along with this program.  If not, see <http://www.gnu.org/licenses/>.
##------------------------------------------------------------------------------

###########################################################################
##                          CPCTELERA ENGINE                             ##
##                  Main Building Makefile for Projects                  ##
##-----------------------------------------------------------------------##
## This file contains the rules for building a CPCTelera project. These  ##
## These rules work generically for every CPCTelera project.             ##
## Usually, this file should be left unchanged:                          ##
##  * Project's build configuration is to be found in build_config.mk    ##
##  * Global paths and tool configuration is located at $(CPCT_PATH)/cfg/##
###########################################################################

##
## PROJECT CONFIGURATION (you may change things there to setup this project)
##
include cfg/build_config.mk

##
## USE GLOBAL MAKEFILE (general rules for building CPCtelera projects)
##
include $(CPCT_PATH)/cfg/global_main_makefile.mk

##
## LOCAL NATIVE EMULATOR
##
CAP32_DIR ?= $(CURDIR)/.tools/caprice32
CAP32     ?= $(CAP32_DIR)/cap32
BOOT_AMSDOS_NAME ?= LOADER

LOADING_PNG := assets/concepts/loading/banterhouse-loading-cpc-mode0-v1.png
LOADING_SCR := dsk_files/LOADING.SCR
LOADING_PALETTE_FW := 0,1,2,11,26,25,24,16,15,6,8,4,9,18,3,13
ARKOS_TEMPLATE := $(CPCT_PATH)/tools/arkosTracker-1.0/data/Songs/Demo.aks
MIDI_SOURCE        := music/source/banterhouse-theme.mid
ARKOS_ARRANGEMENT  := music/banterhouse-theme-arrangement.json
ARKOS_THEME_SOURCE := music/banterhouse-theme.aks
ARKOS_SFX_SOURCE   := music/banterhouse-sfx.aks
FONT_DSK       := assets/fonts/manuel3d/font.dsk
FONT_DATA      := src/font_data.s

.PHONY: run loading-screen music-source font-data clean-build parallel-build check sizes test-dsk font-test-dsk audio-test-dsk audio-verify matrix release \
	_bh-clean-build _bh-parallel-build _bh-check _bh-test-dsk _bh-font-test-dsk _bh-audio-test-dsk _bh-release

$(ARKOS_THEME_SOURCE): tools/generate_aks.py tools/midi_smf.py $(ARKOS_TEMPLATE) $(MIDI_SOURCE) $(ARKOS_ARRANGEMENT)
	@python3 tools/generate_aks.py --kind theme --template "$(ARKOS_TEMPLATE)" \
		--midi "$(MIDI_SOURCE)" --arrangement "$(ARKOS_ARRANGEMENT)" --output "$@"
	@printf 'Arkos Tracker theme source: %s\n' "$@"

$(ARKOS_SFX_SOURCE): tools/generate_aks.py $(ARKOS_TEMPLATE)
	@python3 tools/generate_aks.py --kind sfx --template "$(ARKOS_TEMPLATE)" --output "$@"
	@printf 'Arkos Tracker SFX source: %s\n' "$@"

music-source: $(ARKOS_THEME_SOURCE) $(ARKOS_SFX_SOURCE)

$(FONT_DATA): tools/import_manuel3d_font.py $(FONT_DSK)
	@python3 tools/import_manuel3d_font.py --dsk "$(FONT_DSK)" --output "$@"
	@printf 'manuel3d font data: %s (876 bytes at 0x1B00)\n' "$@"

font-data: $(FONT_DATA)

# The generated declaration must exist before audio.c is compiled under -j.
$(OBJDIR)/audio.rel: src/banterhouse-theme.h src/banterhouse-theme.s \
	src/banterhouse-sfx.h src/banterhouse-sfx.s
$(OBJDIR)/font_data.rel: $(FONT_DATA)

# Native SDCC can return from two simultaneous compiler jobs just before the
# second .rel becomes visible to ASlink on APFS.  This stamp is an explicit
# visibility barrier between every compiler output and the link recipe.
RELFILES_READY := $(OBJDIR)/relfiles.ready
$(RELFILES_READY): $(OBJFILES)
	@for file in $(OBJFILES); do \
		tries=0; \
		while ! test -s "$$file"; do \
			tries=$$((tries + 1)); \
			test "$$tries" -lt 50 || { printf 'Missing compiler object: %s\n' "$$file" >&2; exit 1; }; \
			sleep 0.1; \
		done; \
	done
	@touch "$@"

$(IHXFILE): $(RELFILES_READY)

$(LOADING_SCR): $(LOADING_PNG) | $(OBJDIR)/.folder
	@$(IMG2CPC) -m 0 -fwp $(LOADING_PALETTE_FW) -scr -w 160 -h 200 \
		-nt -of bin -o "$(OBJDIR)/loading_screen" "$<" >/dev/null
	@cp "$(OBJDIR)/loading_screen.bin" "$@"
	@printf 'Loading screen: %s (16 KiB, Mode 0)\n' "$@"

# CPCtelera's generated DSK-inclusion rules mutate the same image and do not
# depend on its creation.  Order them explicitly so `make -j` is deterministic.
$(OBJDSKINCSDIR)/LOADER.BAS.$(DSKINC_EXT): $(DSK)
$(OBJDSKINCSDIR)/LOADING.SCR.$(DSKINC_EXT): $(OBJDSKINCSDIR)/LOADER.BAS.$(DSKINC_EXT)

loading-screen: $(LOADING_SCR)

run: all
	cd "$(CAP32_DIR)" && ./cap32 \
		--autocmd='run"$(BOOT_AMSDOS_NAME)"' \
		--sym_file="$(CURDIR)/$(OBJDIR)/$(PROJNAME).noi" \
		"$(CURDIR)/$(DSK)"

clean-build:
	@tools/with_build_lock.sh $(MAKE) _bh-clean-build

_bh-clean-build:
	$(MAKE) cleanall
	$(MAKE) all

parallel-build:
	@tools/with_build_lock.sh $(MAKE) _bh-parallel-build

_bh-parallel-build:
	$(MAKE) cleanall
	$(MAKE) -j2 all

sizes: all
	@v=$$(python3 tools/runtime_highwater.py "$(OBJDIR)/$(PROJNAME).map" "$(OBJDIR)/$(PROJNAME).bin.log"); \
	 test -n "$$v"; n=$$(printf '%d' "0x$$v"); margin=$$((0x8000 - n - 1)); \
	 test "$$margin" -ge 4096; \
	 printf 'Resident runtime high-water: 0x%s; stack/framebuffer margin: %d bytes\n' "$$v" "$$margin"
	@rh=$$(awk '$$2 == "_CODE" && $$3 == "size" { print $$4 }' "$(OBJDIR)/font_renderer.sym"); \
	 test -n "$$rh"; rd=$$(printf '%d' "0x$$rh"); \
	 printf 'Font: 776 bitmap + 100 index bytes; renderer: %d code + 38 work bytes\n' "$$rd"

check:
	@tools/with_build_lock.sh $(MAKE) _bh-check

_bh-check: all sizes
	@bash tools/check.sh

test-dsk:
	@tools/with_build_lock.sh $(MAKE) _bh-test-dsk TEST_DIFFICULTY='$(TEST_DIFFICULTY)'

_bh-test-dsk:
	$(MAKE) cleanall
	$(MAKE) Z80CCFLAGS='--sdcccall 0 -DBH_AUTOTEST -DBH_AUTOTEST_DIFFICULTY=$(TEST_DIFFICULTY) $(AUTOTEST_FLAGS)' all

font-test-dsk:
	@tools/with_build_lock.sh $(MAKE) _bh-font-test-dsk

_bh-font-test-dsk:
	$(MAKE) cleanall
	$(MAKE) Z80CCFLAGS='--sdcccall 0 -DBH_FONT_TEST $(FONT_TEST_FLAGS)' all

audio-test-dsk:
	@tools/with_build_lock.sh $(MAKE) _bh-audio-test-dsk

_bh-audio-test-dsk:
	$(MAKE) cleanall
	$(MAKE) Z80CCFLAGS='--sdcccall 0 -DBH_AUDIO_LIFECYCLE_TEST' all

audio-verify:
	@bash tools/run_audio_test.sh

matrix:
	@tools/with_build_lock.sh bash tools/run_matrix.sh

release:
	@tools/with_build_lock.sh $(MAKE) _bh-release

_bh-release:
	$(MAKE) cleanall
	$(MAKE) all
	$(MAKE) sizes
	@bash tools/check.sh
