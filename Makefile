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
BH_Z80_FLAGS := --sdcccall 0 --opt-code-size

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
ROOM_VISUAL_SOURCE := assets/rooms/visuals.json
ROOM_VISUAL_C      := src/room_visuals.c
ROOM_VISUAL_H      := src/room_visuals.h
ROOM_VISUAL_REPORT := generated/room-visual-report.json
ROOM_VISUAL_STAMP  := generated/room-visuals.stamp

.PHONY: run loading-screen music-source font-data room-visuals resources resource-check resource-report resource-lab-dsk fdc-lab-dsk fdc-verify fdc-soak fdc-faults bank-lab-dsk bank-verify expanded-lab-dsk expanded-verify clean-build parallel-build reproducibility check host-tests sizes test-dsk gallery-dsk font-test-dsk audio-test-dsk audio-verify matrix qa rc-verify release \
	_bh-clean-build _bh-parallel-build _bh-check _bh-fdc-lab-dsk _bh-test-dsk _bh-gallery-dsk _bh-font-test-dsk _bh-audio-test-dsk _bh-release

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

$(ROOM_VISUAL_STAMP): $(ROOM_VISUAL_SOURCE) tools/build_room_visuals.py | $(OBJDIR)/.folder
	@python3 tools/build_room_visuals.py --source "$(ROOM_VISUAL_SOURCE)" \
		--header "$(ROOM_VISUAL_H)" --output "$(ROOM_VISUAL_C)" \
		--report "$(ROOM_VISUAL_REPORT)"
	@touch "$@"

room-visuals: $(ROOM_VISUAL_STAMP)

$(OBJDIR)/room_visuals.rel $(OBJDIR)/game_render.rel: $(ROOM_VISUAL_STAMP)

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

reproducibility:
	@bash tools/test_reproducibility.sh

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
	@bash tools/run_host_tests.sh
	@PYTHONPATH=tools python3 tools/test_room_visuals.py
	@$(MAKE) --no-print-directory resource-check
	@bash tools/check.sh

host-tests:
	@bash tools/run_host_tests.sh

resources: room-visuals
	@python3 tools/generate_resource_fixtures.py --output-dir generated/resources
	@python3 tools/build_rooms.py --source assets/rooms/vertical_slice.json \
		--output-dir generated/rooms --report generated/room-report.json
	@python3 tools/resource_pack.py pack --manifest assets/resources.yml --root "$(CURDIR)" \
		--output generated/BHRES.BIN --header generated/resource_ids.h \
		--report generated/resource-report.json

resource-check: resources
	@python3 tools/test_resources.py
	@python3 tools/test_rooms.py
	@python3 tools/resource_pack.py inspect --verify generated/BHRES.BIN >/dev/null
	@printf 'Resource manifest, container, CRC and round-trip checks: PASS\n'

resource-report: resources
	@cat generated/resource-report.json

resource-lab-dsk: resources
	@rm -f generated/banterhouse-resources-lab.dsk
	@$(IDSK) generated/banterhouse-resources-lab.dsk -n >/dev/null
	@python3 tools/normalize_dsk_tracks.py generated/banterhouse-resources-lab.dsk --tracks 40
	@$(IDSK) generated/banterhouse-resources-lab.dsk -i generated/BHRES.BIN -t 1 -f >/dev/null
	@python3 tools/check_resource_dsk.py generated/banterhouse-resources-lab.dsk \
		--container generated/BHRES.BIN --report generated/resource-dsk-report.json

fdc-lab-dsk:
	@tools/with_build_lock.sh $(MAKE) _bh-fdc-lab-dsk

_bh-fdc-lab-dsk: resources
	$(MAKE) cleanall
	$(MAKE) FDC_LAB_ASM=1 Z80CCFLAGS='$(BH_Z80_FLAGS) -DBH_FDC_LAB -DBH_FDC_LAB_CYCLES=$(or $(FDC_LAB_CYCLES),1)' all
	@rm -f generated/banterhouse-fdc-lab.dsk
	@$(IDSK) generated/banterhouse-fdc-lab.dsk -n >/dev/null
	@python3 tools/normalize_dsk_tracks.py generated/banterhouse-fdc-lab.dsk --tracks 40
	@$(IDSK) generated/banterhouse-fdc-lab.dsk -i generated/BHRES.BIN -t 1 -f >/dev/null
	@load=$$(awk '/Binary file start/ { print $$5 }' obj/banterhouse.bin.log); \
	 run=$$(awk '$$2 == "_main" { print $$1 }' obj/banterhouse.map); \
	 test -n "$$load"; test -n "$$run"; \
	 $(IDSK) generated/banterhouse-fdc-lab.dsk -i obj/banterhouse.bin -c "$$load" -e "$$run" -t 1 -f >/dev/null
	@$(IDSK) generated/banterhouse-fdc-lab.dsk -i dsk_files/LOADER.BAS -t 0 -f >/dev/null
	@$(IDSK) generated/banterhouse-fdc-lab.dsk -i dsk_files/LOADING.SCR -t 1 -f >/dev/null
	@python3 tools/check_resource_dsk.py generated/banterhouse-fdc-lab.dsk \
		--container generated/BHRES.BIN --report generated/fdc-lab-dsk-report.json >/dev/null
	@printf 'FDC lab DSK: generated/banterhouse-fdc-lab.dsk\n'

fdc-verify:
	@bash tools/run_fdc_lab.sh

fdc-soak:
	@FDC_LAB_CYCLES=50 FDC_LAB_TIMEOUT=900 bash tools/run_fdc_lab.sh

fdc-faults:
	@bash tools/run_fdc_faults.sh

bank-lab-dsk:
	@mkdir -p generated/bank-lab
	@sdasz80 -l -o -s generated/bank-lab/BANKLAB.rel tools/bank_lab.s
	@sdcc -mz80 --sdcccall 0 --no-std-crt0 --code-loc 0x0100 \
		generated/bank-lab/BANKLAB.rel -o generated/bank-lab/BANKLAB.ihx
	@$(HEX2BIN) -p 00 generated/bank-lab/BANKLAB.ihx >generated/bank-lab/BANKLAB.bin.log
	@sdasz80 -l -o -s generated/bank-lab/BANKBOOT.rel tools/bank_boot.s
	@sdcc -mz80 --sdcccall 0 --no-std-crt0 --code-loc 0x4000 \
		generated/bank-lab/BANKBOOT.rel -o generated/bank-lab/BANKBOOT.ihx
	@$(HEX2BIN) -p 00 generated/bank-lab/BANKBOOT.ihx >generated/bank-lab/BANKBOOT.bin.log
	@rm -f generated/banterhouse-bank-lab.dsk
	@$(IDSK) generated/banterhouse-bank-lab.dsk -n >/dev/null
	@python3 tools/normalize_dsk_tracks.py generated/banterhouse-bank-lab.dsk --tracks 40
	@$(IDSK) generated/banterhouse-bank-lab.dsk -i generated/bank-lab/BANKLAB.bin -c 0x0100 -e 0x0100 -t 1 -f >/dev/null
	@$(IDSK) generated/banterhouse-bank-lab.dsk -i generated/bank-lab/BANKBOOT.bin -c 0x4000 -e 0x4000 -t 1 -f >/dev/null
	@$(IDSK) generated/banterhouse-bank-lab.dsk -i tools/bank_lab/BANKLAB.BAS -t 0 -f >/dev/null
	@printf 'Bank lab DSK: generated/banterhouse-bank-lab.dsk\n'

bank-verify:
	@bash tools/run_bank_lab.sh

expanded-lab-dsk: resources
	@mkdir -p generated/expanded-lab
	@sdasz80 -l -o -s -Igenerated generated/expanded-lab/BHKERN.rel tools/expanded_kernel.s
	@sdasz80 -l -o -s generated/expanded-lab/FDC.rel src/storage_fdc_lab.s
	@sdcc -mz80 --sdcccall 0 --no-std-crt0 --code-loc 0x0100 \
		generated/expanded-lab/BHKERN.rel generated/expanded-lab/FDC.rel \
		-o generated/expanded-lab/BHKERN.ihx
	@$(HEX2BIN) -p 00 generated/expanded-lab/BHKERN.ihx >generated/expanded-lab/BHKERN.bin.log
	@sdasz80 -l -o -s generated/expanded-lab/BHBOOT.rel tools/bank_boot.s
	@sdcc -mz80 --sdcccall 0 --no-std-crt0 --code-loc 0x4000 \
		generated/expanded-lab/BHBOOT.rel -o generated/expanded-lab/BHBOOT.ihx
	@$(HEX2BIN) -p 00 generated/expanded-lab/BHBOOT.ihx >generated/expanded-lab/BHBOOT.bin.log
	@rm -f generated/banterhouse-expanded-lab.dsk
	@$(IDSK) generated/banterhouse-expanded-lab.dsk -n >/dev/null
	@python3 tools/normalize_dsk_tracks.py generated/banterhouse-expanded-lab.dsk --tracks 40
	@$(IDSK) generated/banterhouse-expanded-lab.dsk -i generated/BHRES.BIN -t 1 -f >/dev/null
	@$(IDSK) generated/banterhouse-expanded-lab.dsk -i generated/expanded-lab/BHKERN.bin -c 0x0100 -e 0x0100 -t 1 -f >/dev/null
	@$(IDSK) generated/banterhouse-expanded-lab.dsk -i generated/expanded-lab/BHBOOT.bin -c 0x4000 -e 0x4000 -t 1 -f >/dev/null
	@$(IDSK) generated/banterhouse-expanded-lab.dsk -i dsk_files/LOADING.SCR -t 1 -f >/dev/null
	@$(IDSK) generated/banterhouse-expanded-lab.dsk -i tools/expanded/EXPLOAD.BAS -t 0 -f >/dev/null
	@python3 tools/check_resource_dsk.py generated/banterhouse-expanded-lab.dsk \
		--container generated/BHRES.BIN --report generated/expanded-lab-dsk-report.json >/dev/null
	@printf 'Expanded integrated lab DSK: generated/banterhouse-expanded-lab.dsk\n'

expanded-verify:
	@bash tools/run_expanded_lab.sh

test-dsk:
	@tools/with_build_lock.sh $(MAKE) _bh-test-dsk TEST_DIFFICULTY='$(TEST_DIFFICULTY)'

_bh-test-dsk:
	$(MAKE) cleanall
	$(MAKE) Z80CCFLAGS='$(BH_Z80_FLAGS) -DBH_AUTOTEST -DBH_AUTOTEST_DIFFICULTY=$(TEST_DIFFICULTY) $(AUTOTEST_FLAGS)' all

gallery-dsk:
	@tools/with_build_lock.sh $(MAKE) _bh-gallery-dsk

_bh-gallery-dsk:
	$(MAKE) cleanall
	$(MAKE) Z80CCFLAGS='$(BH_Z80_FLAGS) -DBH_AUTOTEST -DBH_VISUAL_GALLERY $(GALLERY_FLAGS)' all

font-test-dsk:
	@tools/with_build_lock.sh $(MAKE) _bh-font-test-dsk

_bh-font-test-dsk:
	$(MAKE) cleanall
	$(MAKE) Z80CCFLAGS='$(BH_Z80_FLAGS) -DBH_FONT_TEST $(FONT_TEST_FLAGS)' all

audio-test-dsk:
	@tools/with_build_lock.sh $(MAKE) _bh-audio-test-dsk

_bh-audio-test-dsk:
	$(MAKE) cleanall
	$(MAKE) Z80CCFLAGS='$(BH_Z80_FLAGS) -DBH_AUDIO_LIFECYCLE_TEST' all

audio-verify:
	@bash tools/run_audio_test.sh

matrix:
	@tools/with_build_lock.sh bash tools/run_matrix.sh

# Automated acceptance without the long FDC soak. Every emulator helper
# restores the validated release build before returning.
qa:
	@$(MAKE) reproducibility
	@$(MAKE) check
	@$(MAKE) bank-verify
	@$(MAKE) expanded-verify
	@$(MAKE) fdc-verify
	@$(MAKE) fdc-faults
	@$(MAKE) audio-verify
	@$(MAKE) matrix
	@printf 'Automated QA suite: PASS\n'

# Release-candidate automation adds 100 complete 16 KiB FDC loads. Hardware
# compatibility and human playtests remain separate, evidence-backed gates.
rc-verify:
	@$(MAKE) qa
	@$(MAKE) fdc-soak
	@printf 'Automated RC suite: PASS\n'

release:
	@tools/with_build_lock.sh $(MAKE) _bh-release

_bh-release:
	$(MAKE) cleanall
	$(MAKE) all
	$(MAKE) sizes
	@bash tools/check.sh
