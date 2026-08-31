;; Integrated low-memory Expanded proof: banks + FDC resources + CRTC pages.

.module bh_expanded_kernel
.globl _main
.globl _bh_fdc_destination
.globl _bh_fdc_track
.globl _bh_fdc_sector
.globl _bh_fdc_eot
.globl _bh_fdc_transfer_size
.globl _bh_fdc_result
.globl _bh_fdc_motor_on
.globl _bh_fdc_motor_off
.globl _bh_fdc_read_request
.globl _bh_fdc_prepare
.globl _bh_fdc_seek_track
.globl _bh_fdc_read_sector

.include /resource_ids.s/

.area _CODE

_main::
   di
   ld sp, #0x3FF0
   call bank_canaries
   jp c, expanded_fail

   call _bh_fdc_motor_on
   ld b, #10
motor_spin_outer:
   push bc
   ld de, #0
motor_spin_inner:
   dec de
   ld a, d
   or e
   jr nz, motor_spin_inner
   pop bc
   djnz motor_spin_outer

   ;; Header sector: BHRES begins in CP/M block 2, sector C5; AMSDOS adds 128 B.
   ld hl, #0x3000
   ld (_bh_fdc_destination), hl
   xor a
   ld (_bh_fdc_track), a
   ld a, #0xC5
   ld (_bh_fdc_sector), a
   ld (_bh_fdc_eot), a
   ld hl, #512
   ld (_bh_fdc_transfer_size), hl
   call _bh_fdc_read_request
   ld a, l
   or a
   jp nz, expanded_fail_motor
   ld hl, #0x3080
   ld a, (hl)
   cp #'B
   jp nz, expanded_fail_motor
   inc hl
   ld a, (hl)
   cp #'H
   jp nz, expanded_fail_motor
   inc hl
   ld a, (hl)
   cp #'R
   jp nz, expanded_fail_motor
   inc hl
   ld a, (hl)
   cp #'S
   jp nz, expanded_fail_motor
   ld a, (0x308E)
   cp #BH_RESOURCE_BUILD_ID_B0
   jp nz, expanded_fail_motor
   ld a, (0x308F)
   cp #BH_RESOURCE_BUILD_ID_B1
   jp nz, expanded_fail_motor
   ld a, (0x3090)
   cp #BH_RESOURCE_BUILD_ID_B2
   jp nz, expanded_fail_motor
   ld a, (0x3091)
   cp #BH_RESOURCE_BUILD_ID_B3
   jp nz, expanded_fail_motor

   ;; Screen 1: absolute logical sector 5 = track 0/C6, 32 sectors total.
   call _bh_fdc_prepare
   ld a, l
   or a
   jp nz, expanded_fail_motor
   xor a
   ld (_bh_fdc_track), a
   ld a, #0xC6
   ld (_bh_fdc_sector), a
   ld a, #0xC9
   ld (_bh_fdc_eot), a
   ld hl, #0x8000
   ld (_bh_fdc_destination), hl
   ld hl, #0x0800
   ld (_bh_fdc_transfer_size), hl
   call read_chunk
   jp c, expanded_fail_motor

   ld a, #1
   call seek_track
   jp c, expanded_fail_motor
   ld hl, #0x8800
   call read_full_track
   jp c, expanded_fail_motor
   ld a, #2
   call seek_track
   jp c, expanded_fail_motor
   ld hl, #0x9A00
   call read_full_track
   jp c, expanded_fail_motor
   ld a, #3
   call seek_track
   jp c, expanded_fail_motor
   ld hl, #0xAC00
   call read_full_track
   jp c, expanded_fail_motor
   ld a, #4
   call seek_track
   jp c, expanded_fail_motor
   ld a, #0xC1
   ld (_bh_fdc_sector), a
   ld (_bh_fdc_eot), a
   ld hl, #0xBE00
   ld (_bh_fdc_destination), hl
   ld hl, #0x0200
   ld (_bh_fdc_transfer_size), hl
   call read_chunk
   jp c, expanded_fail_motor

   ld hl, #0x8000
   ld bc, #0x4000
   call crc16_block
   ld a, e
   cp #RESOURCE_LAB_PAPER_CRC16_LO
   jp nz, expanded_fail_motor
   ld a, d
   cp #RESOURCE_LAB_PAPER_CRC16_HI
   jp nz, expanded_fail_motor
   ld a, #0x20
   call show_page

   ;; Screen 2: absolute logical sector 37 = track 4/C2.
   call _bh_fdc_prepare
   ld a, l
   or a
   jp nz, expanded_fail_motor
   ld a, #4
   call seek_track
   jp c, expanded_fail_motor
   ld a, #0xC2
   ld (_bh_fdc_sector), a
   ld a, #0xC9
   ld (_bh_fdc_eot), a
   ld hl, #0xC000
   ld (_bh_fdc_destination), hl
   ld hl, #0x1000
   ld (_bh_fdc_transfer_size), hl
   call read_chunk
   jp c, expanded_fail_motor
   ld a, #5
   call seek_track
   jp c, expanded_fail_motor
   ld hl, #0xD000
   call read_full_track
   jp c, expanded_fail_motor
   ld a, #6
   call seek_track
   jp c, expanded_fail_motor
   ld hl, #0xE200
   call read_full_track
   jp c, expanded_fail_motor
   ld a, #7
   call seek_track
   jp c, expanded_fail_motor
   ld a, #0xC1
   ld (_bh_fdc_sector), a
   ld a, #0xC6
   ld (_bh_fdc_eot), a
   ld hl, #0xF400
   ld (_bh_fdc_destination), hl
   ld hl, #0x0C00
   ld (_bh_fdc_transfer_size), hl
   call read_chunk
   jp c, expanded_fail_motor

   ;; Load the first compact room pack directly into its RAM5 slot.
   call _bh_fdc_prepare
   ld a, l
   or a
   jp nz, expanded_fail_motor
   ld a, #RESOURCE_ROOM_F1_RECEPTION_DISK_TRACK
   call seek_track
   jp c, expanded_fail_motor
   ld a, #RESOURCE_ROOM_F1_RECEPTION_DISK_SECTOR_ID
   ld (_bh_fdc_sector), a
   ld (_bh_fdc_eot), a
   ld hl, #0x4000
   ld (_bh_fdc_destination), hl
   ld hl, #0x0200
   ld (_bh_fdc_transfer_size), hl
   ld a, #5
   call page_memory
   call _bh_fdc_read_sector
   ld a, l
   or a
   jp nz, room_bank_fail
   ld hl, #0x4000
   ld a, (hl)
   cp #'B
   jp nz, room_bank_fail
   inc hl
   ld a, (hl)
   cp #'H
   jp nz, room_bank_fail
   inc hl
   ld a, (hl)
   cp #'R
   jp nz, room_bank_fail
   inc hl
   ld a, (hl)
   cp #'M
   jp nz, room_bank_fail
   ld a, (0x4004)
   cp #1
   jp nz, room_bank_fail
   ld a, (0x4005)
   or a
   jp nz, room_bank_fail
   ld a, (0x4006)
   or a
   jp nz, room_bank_fail
   ld hl, #0x4000
   ld bc, #RESOURCE_ROOM_F1_RECEPTION_STORED_SIZE
   call crc16_block
   ld a, e
   cp #RESOURCE_ROOM_F1_RECEPTION_CRC16_LO
   jp nz, room_bank_fail
   ld a, d
   cp #RESOURCE_ROOM_F1_RECEPTION_CRC16_HI
   jp nz, room_bank_fail
   xor a
   call page_memory

   call _bh_fdc_motor_off
   ld hl, #0xC000
   ld bc, #0x4000
   call crc16_block
   ld a, e
   cp #RESOURCE_LAB_INK_CRC16_LO
   jp nz, expanded_fail
   ld a, d
   cp #RESOURCE_LAB_INK_CRC16_HI
   jp nz, expanded_fail
   ld a, #0x30
   call show_page
   ld hl, #pass_text
   jr emit_text

room_bank_fail:
   xor a
   call page_memory
   jp expanded_fail_motor
expanded_fail_motor:
   call _bh_fdc_motor_off
expanded_fail:
   xor a
   call page_memory
   ld hl, #fail_text
emit_text:
   ld bc, #0xEF00
emit_next:
   ld a, (hl)
   or a
   jr z, expanded_halt
   out (c), a
   inc hl
   jr emit_next
expanded_halt:
   halt
   jr expanded_halt

read_full_track:
   ld (_bh_fdc_destination), hl
   ld a, #0xC1
   ld (_bh_fdc_sector), a
   ld a, #0xC9
   ld (_bh_fdc_eot), a
   ld hl, #0x1200
   ld (_bh_fdc_transfer_size), hl
read_chunk:
   call _bh_fdc_read_sector
   ld a, l
   or a
   ret z
   scf
   ret

seek_track:
   ld (_bh_fdc_track), a
   call _bh_fdc_seek_track
   ld a, l
   or a
   ret z
   scf
   ret

show_page:
   ld e, a
   ld bc, #0xBC00
   ld a, #12
   out (c), a
   ld b, #0xBD
   ld a, e
   out (c), a
   ret

crc16_block:
   ld de, #0xFFFF
crc_byte:
   ld a, b
   or c
   ret z
   ld a, (hl)
   xor d
   ld d, a
   push bc
   ld b, #8
crc_bit:
   sla e
   rl d
   jr nc, crc_no_poly
   ld a, e
   xor #0x21
   ld e, a
   ld a, d
   xor #0x10
   ld d, a
crc_no_poly:
   djnz crc_bit
   pop bc
   inc hl
   dec bc
   jr crc_byte

bank_canaries:
   ld a, #4
   ld e, #0x44
   call bank_write
   ret c
   ld a, #5
   ld e, #0x55
   call bank_write
   ret c
   ld a, #6
   ld e, #0x66
   call bank_write
   ret c
   ld a, #7
   ld e, #0x77
   call bank_write
   ret c
   ld a, #4
   ld e, #0x44
   call bank_check
   ret c
   ld a, #5
   ld e, #0x55
   call bank_check
   ret c
   ld a, #6
   ld e, #0x66
   call bank_check
   ret c
   ld a, #7
   ld e, #0x77
bank_check:
   call page_memory
   ld a, (0x4000)
   cp e
   jr nz, bank_bad
   xor a
   call page_memory
   or a
   ret
bank_write:
   call page_memory
   ld a, e
   ld (0x4000), a
   xor a
   call page_memory
   or a
   ret
bank_bad:
   xor a
   call page_memory
   scf
   ret
page_memory:
   or #0xC0
   ld bc, #0x7F00
   out (c), a
   ret

_bh_fdc_destination:: .dw 0
_bh_fdc_track:: .db 0
_bh_fdc_sector:: .db 0
_bh_fdc_eot:: .db 0
_bh_fdc_transfer_size:: .dw 0
_bh_fdc_result:: .ds 7
pass_text: .db 0xC2,0xC8,0xDF,0xD0,0xC1,0xD3,0xD3,0x8A,0
fail_text: .db 0xC2,0xC8,0xDF,0xC6,0xC1,0xC9,0xCC,0x8A,0

.area _DATA
