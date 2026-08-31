;; Firmware-side trampoline: copy the low kernel from 0x8000 and abandon BASIC.

.module bh_bank_boot
.globl _main
.area _CODE

_main::
   di
   ld hl, #0x8000
   ld de, #0x0100
   ld bc, #0x1000
   ldir
   ld bc, #0x7F00
   ld a, #0x8C                  ; Mode 0, lower and upper ROM disabled
   out (c), a
   jp 0x0100

.area _DATA
