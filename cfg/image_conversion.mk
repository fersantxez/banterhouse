##-----------------------------LICENSE NOTICE------------------------------------
##  This file is part of CPCtelera: An Amstrad CPC Game Engine 
##  Copyright (C) 2016 ronaldo / Fremos / Cheesetea / ByteRealms (@FranGallegoBR)
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

############################################################################
##                        CPCTELERA ENGINE                                ##
##                 Automatic image conversion file                        ##
##------------------------------------------------------------------------##
## This file is intended for users to automate image conversion from JPG, ##
## PNG, GIF, etc. into C-arrays.                                          ##
##                                                                        ##
## Macro used for conversion is IMG2SPRITES, which has up to 9 parameters:##
##  (1): Image file to be converted into C sprite (PNG, JPG, GIF, etc)    ##
##  (2): Graphics mode (0,1,2) for the generated C sprite                 ##
##  (3): Prefix to add to all C-identifiers generated                     ##
##  (4): Width in pixels of each sprite/tile/etc that will be generated   ##
##  (5): Height in pixels of each sprite/tile/etc that will be generated  ##
##  (6): Firmware palette used to convert the image file into C values    ##
##  (7): (mask / tileset /)                                               ##
##     - "mask":    generate interlaced mask for all sprites converted    ##
##     - "tileset": generate a tileset array with pointers to all sprites ##
##  (8): Output subfolder for generated .C/.H files (in project folder)   ##
##  (9): (hwpalette)                                                      ##
##     - "hwpalette": output palette array with hardware colour values    ##
## (10): Aditional options (you can use this to pass aditional modifiers  ##
##       to cpct_img2tileset)                                             ##
##                                                                        ##
## Macro is used in this way (one line for each image to be converted):   ##
##  $(eval $(call IMG2SPRITES,(1),(2),(3),(4),(5),(6),(7),(8),(9), (10))) ##
##                                                                        ##
## Important:                                                             ##
##  * Do NOT separate macro parameters with spaces, blanks or other chars.##
##    ANY character you put into a macro parameter will be passed to the  ##
##    macro. Therefore ...,src/sprites,... will represent "src/sprites"   ##
##    folder, whereas ...,  src/sprites,... means "  src/sprites" folder. ##
##                                                                        ##
##  * You can omit parameters but leaving them empty. Therefore, if you   ##
##  wanted to specify an output folder but do not want your sprites to    ##
##  have mask and/or tileset, you may omit parameter (7) leaving it empty ##
##     $(eval $(call IMG2SPRITES,imgs/1.png,0,g,4,8,$(PAL),,src/))        ##
############################################################################

# Palette in image_conversion needs FW_VALUES, in Decimal (RGAS gives FW/hex)
# conversion table: https://lronaldo.github.io/cpctelera/files/video/cpct_setPalette-asm.html
#hex from RGAS
#PALETTE={00 1A 0B 14 17 0D \
		  12 16 19 03 07 11 \
		  0F 10 0C 01} 
#PALETTE={FW_BLACK FW_BRIGHT_WHITE FW_SKY_BLUE FW_BRIGHT_CYAN FW_PASTEL_CYAN FW_WHITE \
#		 FW_BRIGHT_GREEN FW_PASTEL_GREEN FW_PASTEL_YELLOW FW_RED FW_PURPLE FW_PASTEL_MAGENTA \
#		 FW_ORANGE FW_PINK FW_YELLOW FW_BLUE}
#NOTE: palette definition has no curly braces {} or parentheses () ?
PALETTE=0 26 11 20 23 13 \
		 18 22 25 3 7 17 \
		 15 16 12 1

## Example image conversion
##    This example would convert img/example.png into src/example.{c|h} files.
##    A C-array called pre_example[24*12*2] would be generated with the definition
##    of the image example.png in mode 0 screen pixel format, with interlaced mask.
##    The palette used for conversion is given through the PALETTE variable and
##    a pre_palette[16] array will be generated with the 16 palette colours as 
##	  hardware colour values.

#$(eval $(call IMG2SPRITES,img/example.png,0,pre,24,12,$(PALETTE),mask,src/,hwpalette))
#$(eval $(call IMG2SPRITES,img/pitu.png,0,g,16,32,$(PALETTE),,src/,hwpalette))

#From Taller CPCtelera
#https://youtu.be/8fI68O1V-08?t=1018

#default config
#$(eval $(call IMG2SP, SET_MODE        , 0             ))  { 0, 1, 2          }
#$(eval $(call IMG2SP, SET_MASK        , none          ))  { interlaced, none }
#$(eval $(call IMG2SP, SET_FOLDER      , src/          ))
#$(eval $(call IMG2SP, SET_EXTRAPAR    ,               ))
#$(eval $(call IMG2SP, SET_IMG_FORMAT  , sprites       ))  { sprites, zgtiles }
#$(eval $(call IMG2SP, SET_OUTPUT      , c             ))  { bin, c           }
#$(eval $(call IMG2SP, SET_PALETTE_FW  , $(PALETTE)    ))
#$(eval $(call IMG2SP, CONVERT_PALETTE , $(PALETTE), g_palette ))
#$(eval $(call IMG2SP, CONVERT         , img.png, w, h, array, palette, tileset))

#example - conversion
$(eval $(call IMG2SP, SET_MODE        , 0             ))
$(eval $(call IMG2SP, SET_MASK        , none          ))
$(eval $(call IMG2SP, SET_FOLDER      , src/          ))
$(eval $(call IMG2SP, SET_EXTRAPAR    ,               ))
$(eval $(call IMG2SP, SET_IMG_FORMAT  , zgtiles       ))  #CPCtelera uses this format, unusual but performing
$(eval $(call IMG2SP, SET_OUTPUT      , c             ))  
$(eval $(call IMG2SP, SET_PALETTE_FW  , $(PALETTE)    ))
#$(eval $(call IMG2SP, CONVERT_PALETTE , $(PALETTE), g_palette ))
$(eval $(call IMG2SP, CONVERT         , maps/tileset.png, 8, 8, g_tileset, , ))
