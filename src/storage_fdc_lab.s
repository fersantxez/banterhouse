;; Direct uPD765A one-sector read used only by the BH_FDC_LAB build.

.module bh_storage_fdc_lab

.globl _bh_fdc_destination
.globl _bh_fdc_track
.globl _bh_fdc_sector
.globl _bh_fdc_eot
.globl _bh_fdc_transfer_size
.globl _bh_fdc_result
.globl _bh_fdc_prepare
.globl _bh_fdc_seek_track
.globl _bh_fdc_read_sector
.globl _bh_fdc_motor_on
.globl _bh_fdc_motor_off
.globl _bh_fdc_read_request

.area _CODE

FDC_MOTOR  = 0xFA7E
FDC_STATUS = 0xFB7E
FDC_DATA   = 0xFB7F

_bh_fdc_motor_on::
   ld   bc, #FDC_MOTOR
   ld    a, #1
   out  (c), a
   ret

_bh_fdc_motor_off::
   ld   bc, #FDC_MOTOR
   xor   a
   out  (c), a
   ret

;; A=command byte. Carry means timeout or wrong phase.
fdc_write_byte:
   push af
   ld   de, #0
fdc_write_wait:
   ld   bc, #FDC_STATUS
   in    a, (c)
   and  #0xC0
   cp   #0x80                    ; RQM=1, DIO=0
   jr    z, fdc_write_ready
   dec  de
   ld    a, d
   or    e
   jr   nz, fdc_write_wait
   pop  af
   scf
   ret
fdc_write_ready:
   pop  af
   ld   bc, #FDC_DATA
   out  (c), a
   or    a                       ; clear carry
   ret

;; Return result byte in A. Carry means timeout/wrong phase.
fdc_read_result:
   ld   de, #0
fdc_result_wait:
   ld   bc, #FDC_STATUS
   in    a, (c)
   and  #0xC0
   cp   #0xC0                    ; RQM=1, DIO=1
   jr    z, fdc_result_ready
   dec  de
   ld    a, d
   or    e
   jr   nz, fdc_result_wait
   scf
   ret
fdc_result_ready:
   ld   bc, #FDC_DATA
   in    a, (c)
   or    a                       ; clear carry
   ret

fdc_send_specify:
   ld    a, #0x03
   call fdc_write_byte
   ret   c
   ld    a, #0xDF                ; step/unload timing
   call fdc_write_byte
   ret   c
   ld    a, #0x03                ; head load, non-DMA mode
   jp   fdc_write_byte

fdc_recalibrate:
   ld    a, #0x07
   call fdc_write_byte
   ret   c
   xor   a                       ; drive 0
   call fdc_write_byte
   ret   c

   ld   de, #0                   ; command has no direct result phase
fdc_recal_wait:
   ld   bc, #FDC_STATUS
   in    a, (c)
   bit   0, a                    ; drive 0 busy while seeking
   jr    z, fdc_recal_done
   dec  de
   ld    a, d
   or    e
   jr   nz, fdc_recal_wait
   scf
   ret

fdc_seek:
   ld    a, #0x0F
   call fdc_write_byte
   ret   c
   xor   a                       ; drive/head 0
   call fdc_write_byte
   ret   c
   ld    a, (_bh_fdc_track)      ; new cylinder
   call fdc_write_byte
   ret   c

   ;; The drive-busy bit is cleared by SENSE INTERRUPT STATUS, not a useful
   ;; completion edge to poll.  Give the mechanics a bounded settle interval
   ;; (longer than a four-track seek with the programmed SRT), then sense it.
   ld   de, #0x8000
fdc_seek_wait:
   dec  de
   ld    a, d
   or    e
   jr   nz, fdc_seek_wait
fdc_seek_done:
   ld    a, #0x08
   call fdc_write_byte
   ret   c
   call fdc_read_result          ; ST0
   ret   c
   call fdc_read_result          ; present cylinder
   ret   c
   ld   hl, #_bh_fdc_track
   cp   (hl)
   ret   z
   scf
   ret
fdc_recal_done:
   ld    a, #0x08                ; sense interrupt status
   call fdc_write_byte
   ret   c
   call fdc_read_result          ; ST0
   ret   c
   call fdc_read_result          ; present cylinder
   ret   c
   or    a                       ; cylinder must be zero
   ret   z
   scf
   ret

fdc_send_read:
   ld    a, #0x46                ; MFM read data, one side
   call fdc_write_byte
   ret   c
   xor   a                       ; drive/head 0
   call fdc_write_byte
   ret   c
   ld    a, (_bh_fdc_track)      ; C
   call fdc_write_byte
   ret   c
   xor   a                       ; H
   call fdc_write_byte
   ret   c
   ld    a, (_bh_fdc_sector)     ; R
   call fdc_write_byte
   ret   c
   ld    a, #2                   ; N = 512 bytes
   call fdc_write_byte
   ret   c
   ld    a, (_bh_fdc_eot)        ; last sector in this track transfer
   call fdc_write_byte
   ret   c
   ld    a, #0x2A                ; DATA-format GPL
   call fdc_write_byte
   ret   c
   ld    a, #0xFF                ; DTL ignored when N != 0
   jp   fdc_write_byte

_bh_fdc_prepare::
   di
   call fdc_send_specify
   jp    c, fdc_error_command
   call fdc_recalibrate
   jp    c, fdc_error_recal
   ld    l, #0
   ret

_bh_fdc_seek_track::
   di
   call fdc_seek
   jp    c, fdc_error_recal
   ld    l, #0
   ret

_bh_fdc_read_request::
   call _bh_fdc_prepare
   ld    a, l
   or    a
   ret   nz

_bh_fdc_read_sector::
   di
   push ix                       ; SDCC ABI: IX is callee-saved
   call fdc_send_read
   jp    c, fdc_read_error_command

   ld   hl, (_bh_fdc_destination)
   ld   ix, (_bh_fdc_transfer_size)
fdc_data_next:
   ld   de, #0
fdc_data_wait:
   ld   bc, #FDC_STATUS
   in    a, (c)
   ld    b, a
   and  #0xE0
   cp   #0xE0                    ; execution, FDC->CPU, byte ready
   jr    z, fdc_data_ready
   cp   #0xC0                    ; result phase before 512 bytes
   jp    z, fdc_read_error_early
   dec  de
   ld    a, d
   or    e
   jr   nz, fdc_data_wait
   jp   fdc_read_error_data
fdc_data_ready:
   ld   bc, #FDC_DATA
   in    a, (c)
   ld   (hl), a
   inc  hl
   dec  ix
   push ix
   pop  bc
   ld    a, b
   or    c
   jr   nz, fdc_data_next

   ld   hl, #_bh_fdc_result
   ld    b, #7
fdc_result_loop:
   push bc
   call fdc_read_result
   pop  bc
   jp    c, fdc_read_error_result
   ld   (hl), a
   inc  hl
   djnz fdc_result_loop

   ;; A one-sector READ DATA may finish either normally (ST0/ST1=00/00) or
   ;; at the requested EOT boundary (40/80).  Accept only those exact pairs;
   ;; every other status bit still denotes a real media/command error.
   ld    a, (_bh_fdc_result)
   or    a
   jr    z, fdc_status_normal
   cp   #0x40
   jr   nz, fdc_read_error_status
   ld    a, (_bh_fdc_result + 1)
   cp   #0x80
   jr   nz, fdc_read_error_status
   jr fdc_status_st2
fdc_status_normal:
   ld    a, (_bh_fdc_result + 1)
   or    a
   jr   nz, fdc_read_error_status
fdc_status_st2:
   ld    a, (_bh_fdc_result + 2)
   or    a
   jr   nz, fdc_read_error_status
   ld    a, (_bh_fdc_result + 3)
   ld   hl, #_bh_fdc_track
   cp   (hl)
   jr   nz, fdc_read_error_status
   ld    a, (_bh_fdc_result + 4)
   or    a
   jr   nz, fdc_read_error_status
   ld    a, (_bh_fdc_result + 5)
   ld   hl, #_bh_fdc_eot
   cp   (hl)
   jr   nz, fdc_read_error_status
   ld    a, (_bh_fdc_result + 6)
   cp   #2
   jr   nz, fdc_read_error_status
   pop  ix
   ld    l, #0
   ret

fdc_read_error_command:
   pop  ix
   jr fdc_error_command
fdc_read_error_early:
   pop  ix
   jr fdc_error_early
fdc_read_error_data:
   pop  ix
   jr fdc_error_data
fdc_read_error_result:
   pop  ix
   jr fdc_error_result
fdc_read_error_status:
   pop  ix
   jr fdc_error_status

fdc_error_command:
   ld    l, #1
   ret
fdc_error_recal:
   ld    l, #2
   ret
fdc_error_early:
   ld    l, #3
   ret
fdc_error_data:
   ld    l, #4
   ret
fdc_error_result:
   ld    l, #5
   ret
fdc_error_status:
   ld    l, #6
   ret
