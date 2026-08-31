;; Standalone low-memory 6128 bank-switch laboratory.

.module bh_bank_lab
.globl _main
.area _CODE

GA_PORT = 0x7F00

_main::
   di
   ld sp, #0x3FF0
   xor a
   ld (current_config), a
   ld (stack_depth), a
   ld a, #0x5A
   ld (0x3000), a
   ld a, #0xA5
   ld (0x3800), a

   ;; Give each expanded page three independent canaries.
   ld a, #4
   ld e, #0x44
   call initialize_bank
   jp c, bank_lab_fail
   ld a, #5
   ld e, #0x55
   call initialize_bank
   jp c, bank_lab_fail
   ld a, #6
   ld e, #0x66
   call initialize_bank
   jp c, bank_lab_fail
   ld a, #7
   ld e, #0x77
   call initialize_bank
   jp c, bank_lab_fail

   ld de, #10000
bank_soak_loop:
   push de
   ld a, #4
   ld e, #0x44
   call verify_bank
   jp c, bank_lab_fail_pop
   ld a, #5
   ld e, #0x55
   call verify_bank
   jp c, bank_lab_fail_pop
   ld a, #6
   ld e, #0x66
   call verify_bank
   jp c, bank_lab_fail_pop
   ld a, #7
   ld e, #0x77
   call verify_bank
   jp c, bank_lab_fail_pop

   ;; Nested push/pop must restore the previous expanded mapping, then CFG0.
   ld a, #4
   call bank_push
   jp c, bank_lab_fail_pop
   ld a, #7
   call bank_push
   jp c, bank_lab_fail_pop
   ld a, (current_config)
   cp #7
   jp nz, bank_lab_fail_pop
   call bank_pop
   jp c, bank_lab_fail_pop
   ld a, (current_config)
   cp #4
   jp nz, bank_lab_fail_pop
   call bank_pop
   jp c, bank_lab_fail_pop
   ld a, (current_config)
   or a
   jp nz, bank_lab_fail_pop

   ld a, (0x3000)
   cp #0x5A
   jp nz, bank_lab_fail_pop
   ld a, (0x3800)
   cp #0xA5
   jp nz, bank_lab_fail_pop
   pop de
   dec de
   ld a, d
   or e
   jr nz, bank_soak_loop

   ;; Underflow and overflow are detected without changing the mapped bank.
   call bank_pop
   jp nc, bank_lab_fail
   ld a, #4
   call bank_push
   jp c, bank_lab_fail
   ld a, #5
   call bank_push
   jp c, bank_lab_fail
   ld a, #6
   call bank_push
   jp c, bank_lab_fail
   ld a, #7
   call bank_push
   jp c, bank_lab_fail
   ld a, #4
   call bank_push
   jp nc, bank_lab_fail
   call bank_pop
   call bank_pop
   call bank_pop
   call bank_pop
   ld a, (current_config)
   or a
   jp nz, bank_lab_fail

bank_lab_pass:
   ld bc, #0xEF00
   ld hl, #pass_text
   jr emit_text
bank_lab_fail_pop:
   pop de
bank_lab_fail:
   xor a
   call page_memory
   ld bc, #0xEF00
   ld hl, #fail_text
emit_text:
   ld a, (hl)
   or a
   jr z, emit_done
   out (c), a
   inc hl
   jr emit_text
emit_done:
   halt
   jr emit_done

initialize_bank:
   ld (expected_pattern), a
   ld a, e
   ld (expected_value), a
   ld a, (expected_pattern)
   call bank_push
   ret c
   ld a, (expected_value)
   ld (0x4000), a
   cpl
   ld (0x5AAA), a
   xor #0xA5
   ld (0x7FFF), a
   jp bank_pop

verify_bank:
   ld (expected_pattern), a
   ld a, e
   ld (expected_value), a
   ld a, (expected_pattern)
   call bank_push
   ret c
   ld a, (expected_value)
   ld e, a
   ld a, (0x4000)
   cp e
   jr nz, verify_bad
   ld a, e
   cpl
   ld e, a
   ld a, (0x5AAA)
   cp e
   jr nz, verify_bad
   ld a, e
   xor #0xA5
   ld e, a
   ld a, (0x7FFF)
   cp e
   jr nz, verify_bad
   call bank_pop
   ret
verify_bad:
   call bank_pop
   scf
   ret

;; A=RAMCFG_0..7. Carry reports overflow.
bank_push:
   ld e, a
   ld a, (stack_depth)
   cp #4
   jr nc, bank_stack_error
   ld c, a
   ld b, #0
   ld hl, #bank_stack
   add hl, bc
   ld a, (current_config)
   ld (hl), a
   ld a, (stack_depth)
   inc a
   ld (stack_depth), a
   ld a, e
   ld (current_config), a
   call page_memory
   or a
   ret

;; Carry reports underflow.
bank_pop:
   ld a, (stack_depth)
   or a
   jr z, bank_stack_error
   dec a
   ld (stack_depth), a
   ld c, a
   ld b, #0
   ld hl, #bank_stack
   add hl, bc
   ld a, (hl)
   ld (current_config), a
   call page_memory
   or a
   ret
bank_stack_error:
   scf
   ret

page_memory:
   or #0xC0
   ld bc, #GA_PORT
   out (c), a
   ret

current_config:  .db 0
stack_depth:     .db 0
bank_stack:      .ds 4
expected_pattern:.db 0
expected_value:  .db 0
pass_text:       .db 0xC2,0xC8,0xDF,0xD0,0xC1,0xD3,0xD3,0x8A,0
fail_text:       .db 0xC2,0xC8,0xDF,0xC6,0xC1,0xC9,0xCC,0x8A,0

.area _DATA
