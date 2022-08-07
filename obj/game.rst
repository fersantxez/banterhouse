                              1 ;--------------------------------------------------------
                              2 ; File Created by SDCC : free open source ANSI-C Compiler
                              3 ; Version 3.6.8 #9946 (Linux)
                              4 ;--------------------------------------------------------
                              5 	.module game
                              6 	.optsdcc -mz80
                              7 	
                              8 ;--------------------------------------------------------
                              9 ; Public variables in this module
                             10 ;--------------------------------------------------------
                             11 	.globl _game
                             12 	.globl _AI
                             13 	.globl _keyboard
                             14 	.globl _init_game
                             15 	.globl _deleteSprites
                             16 	.globl _renderSprites
                             17 	.globl _cpct_setVideoMemoryPage
                             18 	.globl _cpct_setPALColour
                             19 	.globl _cpct_waitVSYNC
                             20 	.globl _cpct_px2byteM0
                             21 	.globl _cpct_isKeyPressed
                             22 	.globl _cpct_scanKeyboard_f
                             23 	.globl _cpct_memset
                             24 	.globl _cycle
                             25 	.globl _sprites
                             26 	.globl _coord_x
                             27 	.globl _moveSprites
                             28 ;--------------------------------------------------------
                             29 ; special function registers
                             30 ;--------------------------------------------------------
                             31 ;--------------------------------------------------------
                             32 ; ram data
                             33 ;--------------------------------------------------------
                             34 	.area _DATA
   5DCD                      35 _coord_x::
   5DCD                      36 	.ds 1
   5DCE                      37 _sprites::
   5DCE                      38 	.ds 220
   5EAA                      39 _cycle::
   5EAA                      40 	.ds 1
                             41 ;--------------------------------------------------------
                             42 ; ram data
                             43 ;--------------------------------------------------------
                             44 	.area _INITIALIZED
                             45 ;--------------------------------------------------------
                             46 ; absolute external ram data
                             47 ;--------------------------------------------------------
                             48 	.area _DABS (ABS)
                             49 ;--------------------------------------------------------
                             50 ; global & static initialisations
                             51 ;--------------------------------------------------------
                             52 	.area _HOME
                             53 	.area _GSINIT
                             54 	.area _GSFINAL
                             55 	.area _GSINIT
                             56 ;--------------------------------------------------------
                             57 ; Home
                             58 ;--------------------------------------------------------
                             59 	.area _HOME
                             60 	.area _HOME
                             61 ;--------------------------------------------------------
                             62 ; code
                             63 ;--------------------------------------------------------
                             64 	.area _CODE
                             65 ;src/game.c:11: void init_game() {
                             66 ;	---------------------------------
                             67 ; Function init_game
                             68 ; ---------------------------------
   4110                      69 _init_game::
                             70 ;src/game.c:17: sprites[0].id = 1;												//mark the sprite "alive"
   4110 21 CE 5D      [10]   71 	ld	hl, #_sprites
   4113 36 01         [10]   72 	ld	(hl), #0x01
                             73 ;src/game.c:18: sprites[0].x = sprites[0].y = 0;								//init position to 0,0
   4115 21 D0 5D      [10]   74 	ld	hl, #(_sprites + 0x0002)
   4118 36 00         [10]   75 	ld	(hl), #0x00
   411A 21 CF 5D      [10]   76 	ld	hl, #(_sprites + 0x0001)
   411D 36 00         [10]   77 	ld	(hl), #0x00
                             78 ;src/game.c:19: sprites[0].moveV = sprites[0].moveH = 0;						//init movement to none
   411F 21 D2 5D      [10]   79 	ld	hl, #(_sprites + 0x0004)
   4122 36 00         [10]   80 	ld	(hl), #0x00
   4124 21 D1 5D      [10]   81 	ld	hl, #(_sprites + 0x0003)
   4127 36 00         [10]   82 	ld	(hl), #0x00
                             83 ;src/game.c:21: sprites[0].x_prev_A = sprites[0].y_prev_A = sprites[0].x_prev_B = sprites[0].y_prev_B = 0;
   4129 21 D6 5D      [10]   84 	ld	hl, #(_sprites + 0x0008)
   412C 36 00         [10]   85 	ld	(hl), #0x00
   412E 21 D5 5D      [10]   86 	ld	hl, #(_sprites + 0x0007)
   4131 36 00         [10]   87 	ld	(hl), #0x00
   4133 21 D4 5D      [10]   88 	ld	hl, #(_sprites + 0x0006)
   4136 36 00         [10]   89 	ld	(hl), #0x00
   4138 21 D3 5D      [10]   90 	ld	hl, #(_sprites + 0x0005)
   413B 36 00         [10]   91 	ld	(hl), #0x00
                             92 ;src/game.c:22: sprites[0].height = G_PITU_H;
   413D 21 D7 5D      [10]   93 	ld	hl, #(_sprites + 0x0009)
   4140 36 20         [10]   94 	ld	(hl), #0x20
                             95 ;src/game.c:23: sprites[0].width = G_PITU_W/2;									//!?! /2: - M0, length in bytes = /2 in px
   4142 21 D8 5D      [10]   96 	ld	hl, #(_sprites + 0x000a)
   4145 36 08         [10]   97 	ld	(hl), #0x08
                             98 ;src/game.c:24: sprites[0].properties = 0;										//bitmasked properties - init to 0
   4147 01 D9 5D      [10]   99 	ld	bc, #_sprites + 11
   414A AF            [ 4]  100 	xor	a, a
   414B 02            [ 7]  101 	ld	(bc), a
                            102 ;src/game.c:25: sprites[0].properties = sprites[0].properties | MASK_RENDER;	//init to "render"
   414C 0A            [ 7]  103 	ld	a, (bc)
   414D CB C7         [ 8]  104 	set	0, a
   414F 02            [ 7]  105 	ld	(bc), a
                            106 ;src/game.c:26: sprites[0].sprite_f1 = (u8*)&G_pitu[0]; //&G_pitu[0]			//first position render
   4150 21 71 43      [10]  107 	ld	hl, #_G_pitu
   4153 22 DC 5D      [16]  108 	ld	((_sprites + 0x000e)), hl
                            109 ;src/game.c:27: sprites[0].sprite_f2 = (u8*)G_pitu_walk;
   4156 21 71 45      [10]  110 	ld	hl, #_G_pitu_walk
   4159 22 DE 5D      [16]  111 	ld	((_sprites + 0x0010)), hl
                            112 ;src/game.c:28: sprites[0].sprite_f3 = (u8*)G_pitu_jump;
   415C 21 71 47      [10]  113 	ld	hl, #_G_pitu_jump
   415F 22 E0 5D      [16]  114 	ld	((_sprites + 0x0012)), hl
                            115 ;src/game.c:29: sprites[0].sprite_f3 = (u8*)G_blast;
   4162 21 71 4D      [10]  116 	ld	hl, #_G_blast
   4165 22 E0 5D      [16]  117 	ld	((_sprites + 0x0012)), hl
                            118 ;src/game.c:33: for (i = 1; i < MAX_SPRITES; i++)
   4168 0E 01         [ 7]  119 	ld	c, #0x01
   416A                     120 00102$:
                            121 ;src/game.c:34: sprites[i].id=0;
   416A 06 00         [ 7]  122 	ld	b,#0x00
   416C 69            [ 4]  123 	ld	l, c
   416D 60            [ 4]  124 	ld	h, b
   416E 29            [11]  125 	add	hl, hl
   416F 29            [11]  126 	add	hl, hl
   4170 09            [11]  127 	add	hl, bc
   4171 29            [11]  128 	add	hl, hl
   4172 09            [11]  129 	add	hl, bc
   4173 29            [11]  130 	add	hl, hl
   4174 11 CE 5D      [10]  131 	ld	de, #_sprites
   4177 19            [11]  132 	add	hl, de
   4178 36 00         [10]  133 	ld	(hl), #0x00
                            134 ;src/game.c:33: for (i = 1; i < MAX_SPRITES; i++)
   417A 0C            [ 4]  135 	inc	c
   417B 79            [ 4]  136 	ld	a, c
   417C D6 0A         [ 7]  137 	sub	a, #0x0a
   417E 38 EA         [12]  138 	jr	C,00102$
                            139 ;src/game.c:36: cycle=0;
   4180 21 AA 5E      [10]  140 	ld	hl,#_cycle + 0
   4183 36 00         [10]  141 	ld	(hl), #0x00
   4185 C9            [10]  142 	ret
                            143 ;src/game.c:40: void keyboard(){
                            144 ;	---------------------------------
                            145 ; Function keyboard
                            146 ; ---------------------------------
   4186                     147 _keyboard::
                            148 ;src/game.c:41: sprites[0].moveV = sprites[0].moveH = 0; 						//start with no movement
   4186 21 D2 5D      [10]  149 	ld	hl, #(_sprites + 0x0004)
   4189 36 00         [10]  150 	ld	(hl), #0x00
   418B 21 D1 5D      [10]  151 	ld	hl, #(_sprites + 0x0003)
   418E 36 00         [10]  152 	ld	(hl), #0x00
                            153 ;src/game.c:43: cpct_scanKeyboard_f();											//read keyboard/joystick
   4190 CD 70 5A      [17]  154 	call	_cpct_scanKeyboard_f
                            155 ;src/game.c:44: if (cpct_isKeyPressed(Key_CursorUp) || cpct_isKeyPressed(Key_Q) || cpct_isKeyPressed(Joy0_Up)){	
   4193 21 00 01      [10]  156 	ld	hl, #0x0100
   4196 CD 64 5A      [17]  157 	call	_cpct_isKeyPressed
   4199 7D            [ 4]  158 	ld	a, l
   419A B7            [ 4]  159 	or	a, a
   419B 20 14         [12]  160 	jr	NZ,00101$
   419D 21 08 08      [10]  161 	ld	hl, #0x0808
   41A0 CD 64 5A      [17]  162 	call	_cpct_isKeyPressed
   41A3 7D            [ 4]  163 	ld	a, l
   41A4 B7            [ 4]  164 	or	a, a
   41A5 20 0A         [12]  165 	jr	NZ,00101$
   41A7 21 09 01      [10]  166 	ld	hl, #0x0109
   41AA CD 64 5A      [17]  167 	call	_cpct_isKeyPressed
   41AD 7D            [ 4]  168 	ld	a, l
   41AE B7            [ 4]  169 	or	a, a
   41AF 28 05         [12]  170 	jr	Z,00102$
   41B1                     171 00101$:
                            172 ;src/game.c:45: sprites[0].moveV = -1;		
   41B1 21 D1 5D      [10]  173 	ld	hl, #(_sprites + 0x0003)
   41B4 36 FF         [10]  174 	ld	(hl), #0xff
   41B6                     175 00102$:
                            176 ;src/game.c:47: if (cpct_isKeyPressed(Key_CursorDown) || cpct_isKeyPressed(Key_A) || cpct_isKeyPressed(Joy0_Down)){
   41B6 21 00 04      [10]  177 	ld	hl, #0x0400
   41B9 CD 64 5A      [17]  178 	call	_cpct_isKeyPressed
   41BC 7D            [ 4]  179 	ld	a, l
   41BD B7            [ 4]  180 	or	a, a
   41BE 20 14         [12]  181 	jr	NZ,00105$
   41C0 21 08 20      [10]  182 	ld	hl, #0x2008
   41C3 CD 64 5A      [17]  183 	call	_cpct_isKeyPressed
   41C6 7D            [ 4]  184 	ld	a, l
   41C7 B7            [ 4]  185 	or	a, a
   41C8 20 0A         [12]  186 	jr	NZ,00105$
   41CA 21 09 02      [10]  187 	ld	hl, #0x0209
   41CD CD 64 5A      [17]  188 	call	_cpct_isKeyPressed
   41D0 7D            [ 4]  189 	ld	a, l
   41D1 B7            [ 4]  190 	or	a, a
   41D2 28 05         [12]  191 	jr	Z,00106$
   41D4                     192 00105$:
                            193 ;src/game.c:48: sprites[0].moveV = 1;
   41D4 21 D1 5D      [10]  194 	ld	hl, #(_sprites + 0x0003)
   41D7 36 01         [10]  195 	ld	(hl), #0x01
   41D9                     196 00106$:
                            197 ;src/game.c:50: if (cpct_isKeyPressed(Key_CursorLeft) || cpct_isKeyPressed(Key_O) || cpct_isKeyPressed(Joy0_Left)){
   41D9 21 01 01      [10]  198 	ld	hl, #0x0101
   41DC CD 64 5A      [17]  199 	call	_cpct_isKeyPressed
   41DF 7D            [ 4]  200 	ld	a, l
   41E0 B7            [ 4]  201 	or	a, a
   41E1 20 14         [12]  202 	jr	NZ,00109$
   41E3 21 04 04      [10]  203 	ld	hl, #0x0404
   41E6 CD 64 5A      [17]  204 	call	_cpct_isKeyPressed
   41E9 7D            [ 4]  205 	ld	a, l
   41EA B7            [ 4]  206 	or	a, a
   41EB 20 0A         [12]  207 	jr	NZ,00109$
   41ED 21 09 04      [10]  208 	ld	hl, #0x0409
   41F0 CD 64 5A      [17]  209 	call	_cpct_isKeyPressed
   41F3 7D            [ 4]  210 	ld	a, l
   41F4 B7            [ 4]  211 	or	a, a
   41F5 28 05         [12]  212 	jr	Z,00110$
   41F7                     213 00109$:
                            214 ;src/game.c:51: sprites[0].moveH = -1;
   41F7 21 D2 5D      [10]  215 	ld	hl, #(_sprites + 0x0004)
   41FA 36 FF         [10]  216 	ld	(hl), #0xff
   41FC                     217 00110$:
                            218 ;src/game.c:54: if (cpct_isKeyPressed(Key_CursorRight) || cpct_isKeyPressed(Key_P) || cpct_isKeyPressed(Joy0_Right)){
   41FC 21 00 02      [10]  219 	ld	hl, #0x0200
   41FF CD 64 5A      [17]  220 	call	_cpct_isKeyPressed
   4202 7D            [ 4]  221 	ld	a, l
   4203 B7            [ 4]  222 	or	a, a
   4204 20 13         [12]  223 	jr	NZ,00113$
   4206 21 03 08      [10]  224 	ld	hl, #0x0803
   4209 CD 64 5A      [17]  225 	call	_cpct_isKeyPressed
   420C 7D            [ 4]  226 	ld	a, l
   420D B7            [ 4]  227 	or	a, a
   420E 20 09         [12]  228 	jr	NZ,00113$
   4210 21 09 08      [10]  229 	ld	hl, #0x0809
   4213 CD 64 5A      [17]  230 	call	_cpct_isKeyPressed
   4216 7D            [ 4]  231 	ld	a, l
   4217 B7            [ 4]  232 	or	a, a
   4218 C8            [11]  233 	ret	Z
   4219                     234 00113$:
                            235 ;src/game.c:55: sprites[0].moveH = 1;
   4219 21 D2 5D      [10]  236 	ld	hl, #(_sprites + 0x0004)
   421C 36 01         [10]  237 	ld	(hl), #0x01
   421E C9            [10]  238 	ret
                            239 ;src/game.c:60: void AI(){
                            240 ;	---------------------------------
                            241 ; Function AI
                            242 ; ---------------------------------
   421F                     243 _AI::
                            244 ;src/game.c:61: }
   421F C9            [10]  245 	ret
                            246 ;src/game.c:63: void moveSprites() {
                            247 ;	---------------------------------
                            248 ; Function moveSprites
                            249 ; ---------------------------------
   4220                     250 _moveSprites::
   4220 DD E5         [15]  251 	push	ix
   4222 DD 21 00 00   [14]  252 	ld	ix,#0
   4226 DD 39         [15]  253 	add	ix,sp
   4228 21 F3 FF      [10]  254 	ld	hl, #-13
   422B 39            [11]  255 	add	hl, sp
   422C F9            [ 6]  256 	ld	sp, hl
                            257 ;src/game.c:66: for (i=0; i < MAX_SPRITES; i++) {
   422D DD 36 F5 00   [19]  258 	ld	-11 (ix), #0x00
   4231                     259 00108$:
                            260 ;src/game.c:67: if (sprites[i].id !=0) {			//check only live sprites to optimize CPU (non-zero)
   4231 DD 4E F5      [19]  261 	ld	c,-11 (ix)
   4234 06 00         [ 7]  262 	ld	b,#0x00
   4236 69            [ 4]  263 	ld	l, c
   4237 60            [ 4]  264 	ld	h, b
   4238 29            [11]  265 	add	hl, hl
   4239 29            [11]  266 	add	hl, hl
   423A 09            [11]  267 	add	hl, bc
   423B 29            [11]  268 	add	hl, hl
   423C 09            [11]  269 	add	hl, bc
   423D 29            [11]  270 	add	hl, hl
   423E 01 CE 5D      [10]  271 	ld	bc,#_sprites
   4241 09            [11]  272 	add	hl,bc
   4242 DD 75 FE      [19]  273 	ld	-2 (ix), l
   4245 DD 74 FF      [19]  274 	ld	-1 (ix), h
   4248 7E            [ 7]  275 	ld	a, (hl)
   4249 DD 77 FA      [19]  276 	ld	-6 (ix), a
   424C B7            [ 4]  277 	or	a, a
   424D CA EB 42      [10]  278 	jp	Z, 00109$
                            279 ;src/game.c:70: x = sprites[i].x;
   4250 DD 7E FE      [19]  280 	ld	a, -2 (ix)
   4253 C6 01         [ 7]  281 	add	a, #0x01
   4255 DD 77 F8      [19]  282 	ld	-8 (ix), a
   4258 DD 7E FF      [19]  283 	ld	a, -1 (ix)
   425B CE 00         [ 7]  284 	adc	a, #0x00
   425D DD 77 F9      [19]  285 	ld	-7 (ix), a
   4260 DD 6E F8      [19]  286 	ld	l,-8 (ix)
   4263 DD 66 F9      [19]  287 	ld	h,-7 (ix)
   4266 7E            [ 7]  288 	ld	a, (hl)
   4267 DD 77 FA      [19]  289 	ld	-6 (ix), a
                            290 ;src/game.c:71: y = sprites[i].y;
   426A DD 7E FE      [19]  291 	ld	a, -2 (ix)
   426D C6 02         [ 7]  292 	add	a, #0x02
   426F DD 77 F6      [19]  293 	ld	-10 (ix), a
   4272 DD 7E FF      [19]  294 	ld	a, -1 (ix)
   4275 CE 00         [ 7]  295 	adc	a, #0x00
   4277 DD 77 F7      [19]  296 	ld	-9 (ix), a
   427A DD 6E F6      [19]  297 	ld	l,-10 (ix)
   427D DD 66 F7      [19]  298 	ld	h,-9 (ix)
   4280 7E            [ 7]  299 	ld	a, (hl)
   4281 DD 77 FB      [19]  300 	ld	-5 (ix), a
                            301 ;src/game.c:73: y = y + (4*sprites[i].moveV);	//vertical movement: Y is *px, X is *byte. M0 so Y is 4 times slower
   4284 DD 7E FE      [19]  302 	ld	a, -2 (ix)
   4287 DD 77 FC      [19]  303 	ld	-4 (ix), a
   428A DD 7E FF      [19]  304 	ld	a, -1 (ix)
   428D DD 77 FD      [19]  305 	ld	-3 (ix), a
   4290 DD 6E FC      [19]  306 	ld	l,-4 (ix)
   4293 DD 66 FD      [19]  307 	ld	h,-3 (ix)
   4296 23            [ 6]  308 	inc	hl
   4297 23            [ 6]  309 	inc	hl
   4298 23            [ 6]  310 	inc	hl
   4299 7E            [ 7]  311 	ld	a, (hl)
   429A DD 77 FC      [19]  312 	ld	-4 (ix), a
   429D 87            [ 4]  313 	add	a, a
   429E 87            [ 4]  314 	add	a, a
   429F DD 77 FC      [19]  315 	ld	-4 (ix), a
   42A2 DD 7E FB      [19]  316 	ld	a, -5 (ix)
   42A5 DD 86 FC      [19]  317 	add	a, -4 (ix)
   42A8 DD 77 FC      [19]  318 	ld	-4 (ix), a
   42AB DD 77 F3      [19]  319 	ld	-13 (ix), a
                            320 ;src/game.c:74: x = x + (sprites[i].moveH);
   42AE DD 7E FE      [19]  321 	ld	a, -2 (ix)
   42B1 DD 77 FC      [19]  322 	ld	-4 (ix), a
   42B4 DD 7E FF      [19]  323 	ld	a, -1 (ix)
   42B7 DD 77 FD      [19]  324 	ld	-3 (ix), a
   42BA DD 6E FC      [19]  325 	ld	l,-4 (ix)
   42BD DD 66 FD      [19]  326 	ld	h,-3 (ix)
   42C0 11 04 00      [10]  327 	ld	de, #0x0004
   42C3 19            [11]  328 	add	hl, de
   42C4 7E            [ 7]  329 	ld	a, (hl)
   42C5 DD 77 FC      [19]  330 	ld	-4 (ix), a
   42C8 DD 7E FA      [19]  331 	ld	a, -6 (ix)
   42CB DD 77 FB      [19]  332 	ld	-5 (ix), a
   42CE DD 86 FC      [19]  333 	add	a, -4 (ix)
   42D1 DD 77 FC      [19]  334 	ld	-4 (ix), a
   42D4 DD 77 F4      [19]  335 	ld	-12 (ix), a
                            336 ;src/game.c:84: sprites[i].y = y;
   42D7 DD 6E F6      [19]  337 	ld	l,-10 (ix)
   42DA DD 66 F7      [19]  338 	ld	h,-9 (ix)
   42DD DD 7E F3      [19]  339 	ld	a, -13 (ix)
   42E0 77            [ 7]  340 	ld	(hl), a
                            341 ;src/game.c:86: sprites[i].x = x;
   42E1 DD 6E F8      [19]  342 	ld	l,-8 (ix)
   42E4 DD 66 F9      [19]  343 	ld	h,-7 (ix)
   42E7 DD 7E F4      [19]  344 	ld	a, -12 (ix)
   42EA 77            [ 7]  345 	ld	(hl), a
   42EB                     346 00109$:
                            347 ;src/game.c:66: for (i=0; i < MAX_SPRITES; i++) {
   42EB DD 34 F5      [23]  348 	inc	-11 (ix)
   42EE DD 7E F5      [19]  349 	ld	a, -11 (ix)
   42F1 D6 0A         [ 7]  350 	sub	a, #0x0a
   42F3 DA 31 42      [10]  351 	jp	C, 00108$
   42F6 DD F9         [10]  352 	ld	sp, ix
   42F8 DD E1         [14]  353 	pop	ix
   42FA C9            [10]  354 	ret
                            355 ;src/game.c:91: void game(){
                            356 ;	---------------------------------
                            357 ; Function game
                            358 ; ---------------------------------
   42FB                     359 _game::
                            360 ;src/game.c:92: cpct_setBorder(HW_WHITE);
   42FB 21 10 00      [10]  361 	ld	hl, #0x0010
   42FE E5            [11]  362 	push	hl
   42FF CD DA 5A      [17]  363 	call	_cpct_setPALColour
                            364 ;src/game.c:94: cpct_memset ((u8*)CPCT_LVMEM_START, cpct_px2byteM0(5, 5), 0x8000); //5 is ordinal for WHITE from palette in M0 with 16c
   4302 21 05 05      [10]  365 	ld	hl, #0x0505
   4305 E5            [11]  366 	push	hl
   4306 CD A0 5C      [17]  367 	call	_cpct_px2byteM0
   4309 45            [ 4]  368 	ld	b, l
   430A 21 00 80      [10]  369 	ld	hl, #0x8000
   430D E5            [11]  370 	push	hl
   430E C5            [11]  371 	push	bc
   430F 33            [ 6]  372 	inc	sp
   4310 2E 00         [ 7]  373 	ld	l, #0x00
   4312 E5            [11]  374 	push	hl
   4313 CD BC 5C      [17]  375 	call	_cpct_memset
                            376 ;src/game.c:96: coord_x = 0;
   4316 21 CD 5D      [10]  377 	ld	hl,#_coord_x + 0
   4319 36 00         [10]  378 	ld	(hl), #0x00
                            379 ;src/game.c:98: while (1) {
   431B                     380 00107$:
                            381 ;src/game.c:101: if (!swap_memvideo) { 				//switch
   431B 3A AE 5E      [13]  382 	ld	a,(#_swap_memvideo + 0)
   431E B7            [ 4]  383 	or	a, a
   431F 20 0D         [12]  384 	jr	NZ,00102$
                            385 ;src/game.c:102: mem_start = (u8*) CPCT_LVMEM_START;		//lower VMEM page
   4321 21 00 80      [10]  386 	ld	hl, #0x8000
   4324 22 AB 5E      [16]  387 	ld	(_mem_start), hl
                            388 ;src/game.c:103: mem_page = cpct_page80;					//FIXME:: can probably delete??
   4327 21 AD 5E      [10]  389 	ld	hl,#_mem_page + 0
   432A 36 20         [10]  390 	ld	(hl), #0x20
   432C 18 0B         [12]  391 	jr	00103$
   432E                     392 00102$:
                            393 ;src/game.c:105: mem_start = (u8*) CPCT_VMEM_START;		//upper,regular VMEM page
   432E 21 00 C0      [10]  394 	ld	hl, #0xc000
   4331 22 AB 5E      [16]  395 	ld	(_mem_start), hl
                            396 ;src/game.c:106: mem_page = cpct_pageC0;
   4334 21 AD 5E      [10]  397 	ld	hl,#_mem_page + 0
   4337 36 30         [10]  398 	ld	(hl), #0x30
   4339                     399 00103$:
                            400 ;src/game.c:110: keyboard(); 							//user movement
   4339 CD 86 41      [17]  401 	call	_keyboard
                            402 ;src/game.c:112: moveSprites();
   433C CD 20 42      [17]  403 	call	_moveSprites
                            404 ;src/game.c:113: deleteSprites();
   433F CD 67 59      [17]  405 	call	_deleteSprites
                            406 ;src/game.c:114: renderSprites();
   4342 CD 7C 58      [17]  407 	call	_renderSprites
                            408 ;src/game.c:117: cpct_waitVSYNC();						//Wait until CRTC has printed a full frame to "repaint"
   4345 CD 98 5C      [17]  409 	call	_cpct_waitVSYNC
                            410 ;src/game.c:118: cpct_setVideoMemoryPage(mem_page);		//Tell CRTC to "paint" the new page--FIXME: can this use "mem_start" instead?
   4348 FD 21 AD 5E   [14]  411 	ld	iy, #_mem_page
   434C FD 6E 00      [19]  412 	ld	l, 0 (iy)
   434F CD 33 5C      [17]  413 	call	_cpct_setVideoMemoryPage
                            414 ;src/game.c:119: swap_memvideo = ~swap_memvideo; 		//flip the switch
   4352 FD 21 AE 5E   [14]  415 	ld	iy, #_swap_memvideo
   4356 FD 7E 00      [19]  416 	ld	a, 0 (iy)
   4359 2F            [ 4]  417 	cpl
   435A FD 77 00      [19]  418 	ld	0 (iy), a
                            419 ;src/game.c:121: cycle++;
   435D FD 21 AA 5E   [14]  420 	ld	iy, #_cycle
   4361 FD 34 00      [23]  421 	inc	0 (iy)
                            422 ;src/game.c:122: if (cycle == 16)
   4364 FD 7E 00      [19]  423 	ld	a, 0 (iy)
   4367 D6 10         [ 7]  424 	sub	a, #0x10
   4369 20 B0         [12]  425 	jr	NZ,00107$
                            426 ;src/game.c:123: cycle=0;
   436B FD 36 00 00   [19]  427 	ld	0 (iy), #0x00
   436F 18 AA         [12]  428 	jr	00107$
                            429 	.area _CODE
                            430 	.area _INITIALIZER
                            431 	.area _CABS (ABS)
