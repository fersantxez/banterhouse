                              1 ;--------------------------------------------------------
                              2 ; File Created by SDCC : free open source ANSI-C Compiler
                              3 ; Version 3.6.8 #9946 (Linux)
                              4 ;--------------------------------------------------------
                              5 	.module menu
                              6 	.optsdcc -mz80
                              7 	
                              8 ;--------------------------------------------------------
                              9 ; Public variables in this module
                             10 ;--------------------------------------------------------
                             11 	.globl _menu
                             12 	.globl _cpct_setPALColour
                             13 	.globl _cpct_drawStringM0
                             14 	.globl _cpct_setDrawCharM0
                             15 	.globl _cpct_drawSprite
                             16 	.globl _cpct_px2byteM0
                             17 	.globl _cpct_isAnyKeyPressed_f
                             18 	.globl _cpct_isKeyPressed
                             19 	.globl _cpct_scanKeyboard_f
                             20 	.globl _cpct_memset
                             21 ;--------------------------------------------------------
                             22 ; special function registers
                             23 ;--------------------------------------------------------
                             24 ;--------------------------------------------------------
                             25 ; ram data
                             26 ;--------------------------------------------------------
                             27 	.area _DATA
                             28 ;--------------------------------------------------------
                             29 ; ram data
                             30 ;--------------------------------------------------------
                             31 	.area _INITIALIZED
                             32 ;--------------------------------------------------------
                             33 ; absolute external ram data
                             34 ;--------------------------------------------------------
                             35 	.area _DABS (ABS)
                             36 ;--------------------------------------------------------
                             37 ; global & static initialisations
                             38 ;--------------------------------------------------------
                             39 	.area _HOME
                             40 	.area _GSINIT
                             41 	.area _GSFINAL
                             42 	.area _GSINIT
                             43 ;--------------------------------------------------------
                             44 ; Home
                             45 ;--------------------------------------------------------
                             46 	.area _HOME
                             47 	.area _HOME
                             48 ;--------------------------------------------------------
                             49 ; code
                             50 ;--------------------------------------------------------
                             51 	.area _CODE
                             52 ;src/menu.c:5: void menu () {
                             53 ;	---------------------------------
                             54 ; Function menu
                             55 ; ---------------------------------
   5FEA                      56 _menu::
                             57 ;src/menu.c:7: cpct_setBorder(HW_WHITE);
   5FEA 21 10 00      [10]   58 	ld	hl, #0x0010
   5FED E5            [11]   59 	push	hl
   5FEE CD 47 63      [17]   60 	call	_cpct_setPALColour
                             61 ;src/menu.c:8: cpct_memset(mem_start, cpct_px2byteM0(5,5), 0x4000); //5=WHITE ordinal from palette; 0x4000 is VMEM_SIZE
   5FF1 21 05 05      [10]   62 	ld	hl, #0x0505
   5FF4 E5            [11]   63 	push	hl
   5FF5 CD 0D 65      [17]   64 	call	_cpct_px2byteM0
   5FF8 55            [ 4]   65 	ld	d, l
   5FF9 ED 4B 2B 67   [20]   66 	ld	bc, (_mem_start)
   5FFD 21 00 40      [10]   67 	ld	hl, #0x4000
   6000 E5            [11]   68 	push	hl
   6001 D5            [11]   69 	push	de
   6002 33            [ 6]   70 	inc	sp
   6003 C5            [11]   71 	push	bc
   6004 CD 29 65      [17]   72 	call	_cpct_memset
                             73 ;src/menu.c:11: cpct_drawSprite(G_logo,
   6007 21 20 20      [10]   74 	ld	hl, #0x2020
   600A E5            [11]   75 	push	hl
   600B 21 F9 D1      [10]   76 	ld	hl, #0xd1f9
   600E E5            [11]   77 	push	hl
   600F 21 A6 57      [10]   78 	ld	hl, #_G_logo
   6012 E5            [11]   79 	push	hl
   6013 CD F1 63      [17]   80 	call	_cpct_drawSprite
                             81 ;src/menu.c:16: cpct_setDrawCharM0 (10, 7); //fg color=15, bg color=5. CPCT>1.5 requires initializing before "drawString"
   6016 21 0A 07      [10]   82 	ld	hl, #0x070a
   6019 E5            [11]   83 	push	hl
   601A CD EF 65      [17]   84 	call	_cpct_setDrawCharM0
                             85 ;src/menu.c:17: cpct_drawStringM0("Press S to Start", cpctm_screenPtr(CPCT_VMEM_START, 10, 160 )); //X=(byte 10)=(pixel 20);Y=(line 160)
   601D 21 4A C6      [10]   86 	ld	hl, #0xc64a
   6020 E5            [11]   87 	push	hl
   6021 21 40 60      [10]   88 	ld	hl, #___str_0
   6024 E5            [11]   89 	push	hl
   6025 CD 53 63      [17]   90 	call	_cpct_drawStringM0
                             91 ;src/menu.c:20: do {
   6028                      92 00101$:
                             93 ;src/menu.c:21: cpct_scanKeyboard_f();
   6028 CD DD 62      [17]   94 	call	_cpct_scanKeyboard_f
                             95 ;src/menu.c:22: } while (cpct_isAnyKeyPressed_f());
   602B CD DC 64      [17]   96 	call	_cpct_isAnyKeyPressed_f
   602E 7D            [ 4]   97 	ld	a, l
   602F B7            [ 4]   98 	or	a, a
   6030 20 F6         [12]   99 	jr	NZ,00101$
                            100 ;src/menu.c:24: while (!cpct_isKeyPressed(Key_S)) //any key: cpct_isAnyKeyPressed_f())
   6032                     101 00104$:
   6032 21 07 10      [10]  102 	ld	hl, #0x1007
   6035 CD D1 62      [17]  103 	call	_cpct_isKeyPressed
   6038 7D            [ 4]  104 	ld	a, l
   6039 B7            [ 4]  105 	or	a, a
   603A C0            [11]  106 	ret	NZ
                            107 ;src/menu.c:25: cpct_scanKeyboard_f();
   603B CD DD 62      [17]  108 	call	_cpct_scanKeyboard_f
   603E 18 F2         [12]  109 	jr	00104$
   6040                     110 ___str_0:
   6040 50 72 65 73 73 20   111 	.ascii "Press S to Start"
        53 20 74 6F 20 53
        74 61 72 74
   6050 00                  112 	.db 0x00
                            113 	.area _CODE
                            114 	.area _INITIALIZER
                            115 	.area _CABS (ABS)
