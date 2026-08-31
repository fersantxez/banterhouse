;; Compact resident 8x8 1-bpp renderer for Amstrad CPC Mode 0.
;; It uses only RAM-resident data extracted from manuel3d's FONTBASI.BAS.

.module bh_font_renderer

.globl _bh_font_glyphs
.globl _bh_font_ascii_map
.globl _bh_font_special_map
.globl _bh_font_data_end
.globl _bh_font_work_start
.globl _bh_font_work_end

.globl _bh_font_set_colours
.globl _bh_font_draw_char
.globl _bh_font_draw_string
.globl _bh_font_measure
.globl _bh_font_glyph_index

;; Mutable conversion data occupies the free gap immediately after the
;; 876-byte font block and before immutable graphics begin at 0x2000.
.area _BH_FONT_WORK (ABS)
.org 0x1E6C
_bh_font_work_start::
font_current_colours:
   .db #0xFF, #0xFF
font_pair_colours:
   .ds 4
font_nibble_pairs:
   .ds 32
_bh_font_work_end::

.area _CODE
mode0_right_pixel:
   .db #0x00, #0x40, #0x04, #0x44, #0x10, #0x50, #0x14, #0x54
   .db #0x01, #0x41, #0x05, #0x45, #0x11, #0x51, #0x15, #0x55

;; A = palette index; return its right-pixel Mode 0 encoding in A.
font_colour_to_pixel:
   ld    e, a
   ld    d, #0
   ld   hl, #mode0_right_pixel
   add  hl, de
   ld    a, (hl)
   ret

;; void bh_font_set_colours(u8 ink, u8 paper) __z88dk_callee
;; L = ink, H = paper after the packed-byte callee binding.
_bh_font_set_colours::
   pop  bc
   pop  hl
   push bc
   ld    a, l
   and  #0x0F
   ld    l, a
   ld    a, h
   and  #0x0F
   ld    h, a
   ld    a, (font_current_colours)
   cp    l
   jr   nz, font_set_changed
   ld    a, (font_current_colours + 1)
   cp    h
   ret   z

font_set_changed:
   ld   (font_current_colours), hl
   ld    b, l
   ld    c, h
   ld    a, b
   call font_colour_to_pixel
   ld    b, a
   ld    a, c
   call font_colour_to_pixel
   ld    c, a

   ld    a, c                    ; paper, paper
   add   a, a
   or    c
   ld   (font_pair_colours), a
   ld    a, c                    ; paper, ink
   add   a, a
   or    b
   ld   (font_pair_colours + 1), a
   ld    a, b                    ; ink, paper
   add   a, a
   or    c
   ld   (font_pair_colours + 2), a
   ld    a, b                    ; ink, ink
   add   a, a
   or    b
   ld   (font_pair_colours + 3), a

   ;; Expand the 4x4 pair matrix. Entry N contains two video bytes for
   ;; the high/low two-bit groups of source nibble N.
   ld   hl, #font_nibble_pairs
   ld   de, #font_pair_colours
   ld    b, #4
font_set_outer:
   ld    a, (de)
   inc  de
   ld    c, a
   push de
   ld   de, #font_pair_colours

   ld   (hl), c
   inc  hl
   ld    a, (de)
   inc  de
   ld   (hl), a
   inc  hl
   ld   (hl), c
   inc  hl
   ld    a, (de)
   inc  de
   ld   (hl), a
   inc  hl
   ld   (hl), c
   inc  hl
   ld    a, (de)
   inc  de
   ld   (hl), a
   inc  hl
   ld   (hl), c
   inc  hl
   ld    a, (de)
   ld   (hl), a
   inc  hl

   pop  de
   djnz font_set_outer
   ret

;; A = internal character code; return compact glyph index in A.
font_lookup:
   cp   #0x20
   jr    c, font_lookup_special
   cp   #0x7F
   jr   nc, font_lookup_special
   sub  #0x20
   ld    e, a
   ld    d, #0
   ld   hl, #_bh_font_ascii_map
   add  hl, de
   ld    a, (hl)
   ret
font_lookup_special:
   cp   #0x80
   jr    c, font_lookup_fallback
   cp   #0x85
   jr   nc, font_lookup_fallback
   sub  #0x80
   ld    e, a
   ld    d, #0
   ld   hl, #_bh_font_special_map
   add  hl, de
   ld    a, (hl)
   ret
font_lookup_fallback:
   ld    a, (_bh_font_ascii_map + 31) ; '?' - 0x20
   ret

;; Draw A at IX. IX is restored; IY is scratch and restored by public callers.
font_draw_core:
   push ix
   call font_lookup
   ld    l, a
   ld    h, #0
   add  hl, hl
   add  hl, hl
   add  hl, hl
   ld   de, #_bh_font_glyphs
   add  hl, de
   push hl
   pop  iy

   ld   de, #font_nibble_pairs
   ld    b, #8
font_draw_row:
   ld    c, 0(iy)
   inc  iy
   ld    a, c
   and  #0xF0
   rrca
   rrca
   rrca
   ld    l, a
   ld    h, #0
   add  hl, de
   ld    a, (hl)
   ld   0(ix), a
   inc  hl
   ld    a, (hl)
   ld   1(ix), a

   ld    a, c
   and  #0x0F
   add   a, a
   ld    l, a
   ld    h, #0
   add  hl, de
   ld    a, (hl)
   ld   2(ix), a
   inc  hl
   ld    a, (hl)
   ld   3(ix), a

   push ix
   pop  hl
   ld    a, h
   add   a, #8
   ld    h, a
   and  #0x38
   jr   nz, font_draw_no_wrap
   push de
   ld   de, #0xC050
   add  hl, de
   pop  de
font_draw_no_wrap:
   push hl
   pop  ix
   djnz font_draw_row
   pop  ix
   ret

;; u8 bh_font_glyph_index(u16 character) __z88dk_callee
_bh_font_glyph_index::
   pop  bc
   pop  hl
   push bc
   ld    a, l
   call font_lookup
   ld    l, a
   ret

;; void bh_font_draw_char(u8* vmem, u16 character) __z88dk_callee
_bh_font_draw_char::
   ld   (font_restore_char_ix + 2), ix
   ld   (font_restore_char_iy + 2), iy
   pop  bc
   pop  ix
   pop  hl
   push bc
   ld    a, l
   call font_draw_core
font_restore_char_ix:
   ld   ix, #0
font_restore_char_iy:
   ld   iy, #0
   ret

;; void bh_font_draw_string(const u8* text, u8* vmem) __z88dk_callee
_bh_font_draw_string::
   ld   (font_restore_string_ix + 2), ix
   ld   (font_restore_string_iy + 2), iy
   pop  bc
   pop  de
   pop  ix
   push bc
font_string_loop:
   ld    a, (de)
   or    a
   jr    z, font_string_done
   inc  de
   push de
   call font_draw_core
   pop  de
   inc  ix
   inc  ix
   inc  ix
   inc  ix
   jr   font_string_loop
font_string_done:
font_restore_string_ix:
   ld   ix, #0
font_restore_string_iy:
   ld   iy, #0
   ret

;; u8 bh_font_measure(const u8* text) __z88dk_callee
_bh_font_measure::
   pop  de
   pop  hl
   push de
   ld    b, #0
font_measure_loop:
   ld    a, (hl)
   inc  hl
   or    a
   jr    z, font_measure_done
   ld    a, b
   add   a, #4
   ld    b, a
   jr   nc, font_measure_loop
   ld    b, #0xFC
font_measure_done:
   ld    l, b
   ret
