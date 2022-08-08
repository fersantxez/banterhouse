                              1 ;--------------------------------------------------------
                              2 ; File Created by SDCC : free open source ANSI-C Compiler
                              3 ; Version 3.6.8 #9946 (Linux)
                              4 ;--------------------------------------------------------
                              5 	.module render
                              6 	.optsdcc -mz80
                              7 	
                              8 ;--------------------------------------------------------
                              9 ; Public variables in this module
                             10 ;--------------------------------------------------------
                             11 	.globl _deleteSprites
                             12 	.globl _renderSprites
                             13 	.globl _cpct_getScreenPtr
                             14 	.globl _cpct_drawSpriteMasked
                             15 	.globl _cpct_drawSolidBox
                             16 	.globl _cpct_px2byteM0
                             17 ;--------------------------------------------------------
                             18 ; special function registers
                             19 ;--------------------------------------------------------
                             20 ;--------------------------------------------------------
                             21 ; ram data
                             22 ;--------------------------------------------------------
                             23 	.area _DATA
                             24 ;--------------------------------------------------------
                             25 ; ram data
                             26 ;--------------------------------------------------------
                             27 	.area _INITIALIZED
                             28 ;--------------------------------------------------------
                             29 ; absolute external ram data
                             30 ;--------------------------------------------------------
                             31 	.area _DABS (ABS)
                             32 ;--------------------------------------------------------
                             33 ; global & static initialisations
                             34 ;--------------------------------------------------------
                             35 	.area _HOME
                             36 	.area _GSINIT
                             37 	.area _GSFINAL
                             38 	.area _GSINIT
                             39 ;--------------------------------------------------------
                             40 ; Home
                             41 ;--------------------------------------------------------
                             42 	.area _HOME
                             43 	.area _HOME
                             44 ;--------------------------------------------------------
                             45 ; code
                             46 ;--------------------------------------------------------
                             47 	.area _CODE
                             48 ;src/render.c:11: void renderSprites(){
                             49 ;	---------------------------------
                             50 ; Function renderSprites
                             51 ; ---------------------------------
   6345                      52 _renderSprites::
   6345 DD E5         [15]   53 	push	ix
   6347 DD 21 00 00   [14]   54 	ld	ix,#0
   634B DD 39         [15]   55 	add	ix,sp
   634D 21 F6 FF      [10]   56 	ld	hl, #-10
   6350 39            [11]   57 	add	hl, sp
   6351 F9            [ 6]   58 	ld	sp, hl
                             59 ;src/render.c:16: for (i = 0; i < MAX_SPRITES; i++) {
   6352 DD 36 F6 00   [19]   60 	ld	-10 (ix), #0x00
   6356                      61 00126$:
                             62 ;src/render.c:17: if (sprites[i].id !=0) {						//only live and renderable sprites
   6356 DD 4E F6      [19]   63 	ld	c,-10 (ix)
   6359 06 00         [ 7]   64 	ld	b,#0x00
   635B 69            [ 4]   65 	ld	l, c
   635C 60            [ 4]   66 	ld	h, b
   635D 29            [11]   67 	add	hl, hl
   635E 09            [11]   68 	add	hl, bc
   635F 29            [11]   69 	add	hl, hl
   6360 29            [11]   70 	add	hl, hl
   6361 29            [11]   71 	add	hl, hl
   6362 01 19 6A      [10]   72 	ld	bc,#_sprites
   6365 09            [11]   73 	add	hl,bc
   6366 DD 75 F9      [19]   74 	ld	-7 (ix), l
   6369 DD 74 FA      [19]   75 	ld	-6 (ix), h
   636C 7E            [ 7]   76 	ld	a, (hl)
   636D B7            [ 4]   77 	or	a, a
   636E CA BF 64      [10]   78 	jp	Z, 00127$
                             79 ;src/render.c:18: if (sprites[i].properties & MASK_RENDER) {
   6371 DD 6E F9      [19]   80 	ld	l,-7 (ix)
   6374 DD 66 FA      [19]   81 	ld	h,-6 (ix)
   6377 11 0B 00      [10]   82 	ld	de, #0x000b
   637A 19            [11]   83 	add	hl, de
   637B 4E            [ 7]   84 	ld	c, (hl)
                             85 ;src/render.c:47: cpct_getScreenPtr(mem_start, sprites[i].x, sprites[i].y),
   637C DD 7E F9      [19]   86 	ld	a, -7 (ix)
   637F C6 02         [ 7]   87 	add	a, #0x02
   6381 DD 77 FE      [19]   88 	ld	-2 (ix), a
   6384 DD 7E FA      [19]   89 	ld	a, -6 (ix)
   6387 CE 00         [ 7]   90 	adc	a, #0x00
   6389 DD 77 FF      [19]   91 	ld	-1 (ix), a
   638C DD 7E F9      [19]   92 	ld	a, -7 (ix)
   638F C6 01         [ 7]   93 	add	a, #0x01
   6391 DD 77 F7      [19]   94 	ld	-9 (ix), a
   6394 DD 7E FA      [19]   95 	ld	a, -6 (ix)
   6397 CE 00         [ 7]   96 	adc	a, #0x00
   6399 DD 77 F8      [19]   97 	ld	-8 (ix), a
                             98 ;src/render.c:18: if (sprites[i].properties & MASK_RENDER) {
   639C CB 41         [ 8]   99 	bit	0, c
   639E CA 6E 64      [10]  100 	jp	Z,00119$
                            101 ;src/render.c:33: sprite = sprites[i].sprite_f1; 
   63A1 DD 7E F9      [19]  102 	ld	a, -7 (ix)
   63A4 C6 0F         [ 7]  103 	add	a, #0x0f
   63A6 DD 77 FB      [19]  104 	ld	-5 (ix), a
   63A9 DD 7E FA      [19]  105 	ld	a, -6 (ix)
   63AC CE 00         [ 7]  106 	adc	a, #0x00
   63AE DD 77 FC      [19]  107 	ld	-4 (ix), a
                            108 ;src/render.c:20: if (sprites[i].properties & MASK_ANIMATE) {
   63B1 CB 49         [ 8]  109 	bit	1, c
   63B3 28 55         [12]  110 	jr	Z,00114$
                            111 ;src/render.c:28: if (anim_clock > 7) num_frame=2;
   63B5 3E 07         [ 7]  112 	ld	a, #0x07
   63B7 FD 21 09 6B   [14]  113 	ld	iy, #_anim_clock
   63BB FD 96 00      [19]  114 	sub	a, 0 (iy)
   63BE 30 04         [12]  115 	jr	NC,00102$
   63C0 3E 02         [ 7]  116 	ld	a, #0x02
   63C2 18 02         [12]  117 	jr	00103$
   63C4                     118 00102$:
                            119 ;src/render.c:29: else num_frame=1;
   63C4 3E 01         [ 7]  120 	ld	a, #0x01
   63C6                     121 00103$:
                            122 ;src/render.c:32: if (num_frame == 1) {
   63C6 FE 01         [ 7]  123 	cp	a, #0x01
   63C8 20 0B         [12]  124 	jr	NZ,00111$
                            125 ;src/render.c:33: sprite = sprites[i].sprite_f1; 
   63CA DD 6E FB      [19]  126 	ld	l,-5 (ix)
   63CD DD 66 FC      [19]  127 	ld	h,-4 (ix)
   63D0 4E            [ 7]  128 	ld	c, (hl)
   63D1 23            [ 6]  129 	inc	hl
   63D2 46            [ 7]  130 	ld	b, (hl)
   63D3 18 3E         [12]  131 	jr	00115$
   63D5                     132 00111$:
                            133 ;src/render.c:34: } else if (num_frame == 2) {
   63D5 FE 02         [ 7]  134 	cp	a, #0x02
   63D7 20 0F         [12]  135 	jr	NZ,00108$
                            136 ;src/render.c:35: sprite = sprites[i].sprite_f2;
   63D9 DD 6E F9      [19]  137 	ld	l,-7 (ix)
   63DC DD 66 FA      [19]  138 	ld	h,-6 (ix)
   63DF 11 11 00      [10]  139 	ld	de, #0x0011
   63E2 19            [11]  140 	add	hl, de
   63E3 4E            [ 7]  141 	ld	c, (hl)
   63E4 23            [ 6]  142 	inc	hl
   63E5 46            [ 7]  143 	ld	b, (hl)
   63E6 18 2B         [12]  144 	jr	00115$
   63E8                     145 00108$:
                            146 ;src/render.c:36: } else if (num_frame == 3) { 
   63E8 D6 03         [ 7]  147 	sub	a, #0x03
   63EA 20 0F         [12]  148 	jr	NZ,00105$
                            149 ;src/render.c:37: sprite = sprites[i].sprite_f3; 
   63EC DD 6E F9      [19]  150 	ld	l,-7 (ix)
   63EF DD 66 FA      [19]  151 	ld	h,-6 (ix)
   63F2 11 13 00      [10]  152 	ld	de, #0x0013
   63F5 19            [11]  153 	add	hl, de
   63F6 4E            [ 7]  154 	ld	c, (hl)
   63F7 23            [ 6]  155 	inc	hl
   63F8 46            [ 7]  156 	ld	b, (hl)
   63F9 18 18         [12]  157 	jr	00115$
   63FB                     158 00105$:
                            159 ;src/render.c:38: } else sprite = sprites[i].sprite_f4;
   63FB DD 6E F9      [19]  160 	ld	l,-7 (ix)
   63FE DD 66 FA      [19]  161 	ld	h,-6 (ix)
   6401 11 15 00      [10]  162 	ld	de, #0x0015
   6404 19            [11]  163 	add	hl, de
   6405 4E            [ 7]  164 	ld	c, (hl)
   6406 23            [ 6]  165 	inc	hl
   6407 46            [ 7]  166 	ld	b, (hl)
   6408 18 09         [12]  167 	jr	00115$
   640A                     168 00114$:
                            169 ;src/render.c:39: } else sprite = sprites[i].sprite_f1;
   640A DD 6E FB      [19]  170 	ld	l,-5 (ix)
   640D DD 66 FC      [19]  171 	ld	h,-4 (ix)
   6410 4E            [ 7]  172 	ld	c, (hl)
   6411 23            [ 6]  173 	inc	hl
   6412 46            [ 7]  174 	ld	b, (hl)
   6413                     175 00115$:
                            176 ;src/render.c:41: if (sprites[i].turned)							//turn sprite around
   6413 DD 6E F9      [19]  177 	ld	l,-7 (ix)
   6416 DD 66 FA      [19]  178 	ld	h,-6 (ix)
   6419 11 17 00      [10]  179 	ld	de, #0x0017
   641C 19            [11]  180 	add	hl, de
   641D 7E            [ 7]  181 	ld	a, (hl)
   641E B7            [ 4]  182 	or	a, a
   641F 28 06         [12]  183 	jr	Z,00117$
                            184 ;src/render.c:43: sprite = sprite + ((G_PITU_W*2)*G_PITU_H);	//find next sprite in memory, "rev" version
   6421 21 C0 01      [10]  185 	ld	hl, #0x01c0
   6424 09            [11]  186 	add	hl,bc
   6425 4D            [ 4]  187 	ld	c, l
   6426 44            [ 4]  188 	ld	b, h
   6427                     189 00117$:
                            190 ;src/render.c:48: sprites[i].width, sprites[i].height);
   6427 DD 6E F9      [19]  191 	ld	l,-7 (ix)
   642A DD 66 FA      [19]  192 	ld	h,-6 (ix)
   642D 11 09 00      [10]  193 	ld	de, #0x0009
   6430 19            [11]  194 	add	hl, de
   6431 7E            [ 7]  195 	ld	a, (hl)
   6432 DD 77 FB      [19]  196 	ld	-5 (ix), a
   6435 DD 6E F9      [19]  197 	ld	l,-7 (ix)
   6438 DD 66 FA      [19]  198 	ld	h,-6 (ix)
   643B 11 0A 00      [10]  199 	ld	de, #0x000a
   643E 19            [11]  200 	add	hl, de
   643F 7E            [ 7]  201 	ld	a, (hl)
   6440 DD 77 FD      [19]  202 	ld	-3 (ix), a
                            203 ;src/render.c:47: cpct_getScreenPtr(mem_start, sprites[i].x, sprites[i].y),
   6443 DD 6E FE      [19]  204 	ld	l,-2 (ix)
   6446 DD 66 FF      [19]  205 	ld	h,-1 (ix)
   6449 5E            [ 7]  206 	ld	e, (hl)
   644A DD 6E F7      [19]  207 	ld	l,-9 (ix)
   644D DD 66 F8      [19]  208 	ld	h,-8 (ix)
   6450 56            [ 7]  209 	ld	d, (hl)
   6451 FD 2A D6 6C   [20]  210 	ld	iy, (_mem_start)
   6455 C5            [11]  211 	push	bc
   6456 7B            [ 4]  212 	ld	a, e
   6457 F5            [11]  213 	push	af
   6458 33            [ 6]  214 	inc	sp
   6459 D5            [11]  215 	push	de
   645A 33            [ 6]  216 	inc	sp
   645B FD E5         [15]  217 	push	iy
   645D CD C3 69      [17]  218 	call	_cpct_getScreenPtr
   6460 EB            [ 4]  219 	ex	de,hl
   6461 C1            [10]  220 	pop	bc
                            221 ;src/render.c:45: cpct_drawSpriteMasked(sprite,
   6462 DD 66 FB      [19]  222 	ld	h, -5 (ix)
   6465 DD 6E FD      [19]  223 	ld	l, -3 (ix)
   6468 E5            [11]  224 	push	hl
   6469 D5            [11]  225 	push	de
   646A C5            [11]  226 	push	bc
   646B CD 50 68      [17]  227 	call	_cpct_drawSpriteMasked
   646E                     228 00119$:
                            229 ;src/render.c:47: cpct_getScreenPtr(mem_start, sprites[i].x, sprites[i].y),
   646E DD 6E F7      [19]  230 	ld	l,-9 (ix)
   6471 DD 66 F8      [19]  231 	ld	h,-8 (ix)
   6474 4E            [ 7]  232 	ld	c, (hl)
                            233 ;src/render.c:53: if (!swap_memvideo) {
   6475 3A D9 6C      [13]  234 	ld	a,(#_swap_memvideo + 0)
   6478 B7            [ 4]  235 	or	a, a
   6479 20 23         [12]  236 	jr	NZ,00121$
                            237 ;src/render.c:54: sprites[i].x_prev_B = sprites[i].x;
   647B DD 7E F9      [19]  238 	ld	a, -7 (ix)
   647E C6 07         [ 7]  239 	add	a, #0x07
   6480 6F            [ 4]  240 	ld	l, a
   6481 DD 7E FA      [19]  241 	ld	a, -6 (ix)
   6484 CE 00         [ 7]  242 	adc	a, #0x00
   6486 67            [ 4]  243 	ld	h, a
   6487 71            [ 7]  244 	ld	(hl), c
                            245 ;src/render.c:55: sprites[i].y_prev_B = sprites[i].y;
   6488 DD 7E F9      [19]  246 	ld	a, -7 (ix)
   648B C6 08         [ 7]  247 	add	a, #0x08
   648D 4F            [ 4]  248 	ld	c, a
   648E DD 7E FA      [19]  249 	ld	a, -6 (ix)
   6491 CE 00         [ 7]  250 	adc	a, #0x00
   6493 47            [ 4]  251 	ld	b, a
   6494 DD 6E FE      [19]  252 	ld	l,-2 (ix)
   6497 DD 66 FF      [19]  253 	ld	h,-1 (ix)
   649A 7E            [ 7]  254 	ld	a, (hl)
   649B 02            [ 7]  255 	ld	(bc), a
   649C 18 21         [12]  256 	jr	00127$
   649E                     257 00121$:
                            258 ;src/render.c:57: sprites[i].x_prev_A = sprites[i].x;
   649E DD 7E F9      [19]  259 	ld	a, -7 (ix)
   64A1 C6 05         [ 7]  260 	add	a, #0x05
   64A3 6F            [ 4]  261 	ld	l, a
   64A4 DD 7E FA      [19]  262 	ld	a, -6 (ix)
   64A7 CE 00         [ 7]  263 	adc	a, #0x00
   64A9 67            [ 4]  264 	ld	h, a
   64AA 71            [ 7]  265 	ld	(hl), c
                            266 ;src/render.c:58: sprites[i].y_prev_A = sprites[i].y;
   64AB DD 7E F9      [19]  267 	ld	a, -7 (ix)
   64AE C6 06         [ 7]  268 	add	a, #0x06
   64B0 4F            [ 4]  269 	ld	c, a
   64B1 DD 7E FA      [19]  270 	ld	a, -6 (ix)
   64B4 CE 00         [ 7]  271 	adc	a, #0x00
   64B6 47            [ 4]  272 	ld	b, a
   64B7 DD 6E FE      [19]  273 	ld	l,-2 (ix)
   64BA DD 66 FF      [19]  274 	ld	h,-1 (ix)
   64BD 7E            [ 7]  275 	ld	a, (hl)
   64BE 02            [ 7]  276 	ld	(bc), a
   64BF                     277 00127$:
                            278 ;src/render.c:16: for (i = 0; i < MAX_SPRITES; i++) {
   64BF DD 34 F6      [23]  279 	inc	-10 (ix)
   64C2 DD 7E F6      [19]  280 	ld	a, -10 (ix)
   64C5 D6 0A         [ 7]  281 	sub	a, #0x0a
   64C7 DA 56 63      [10]  282 	jp	C, 00126$
   64CA DD F9         [10]  283 	ld	sp, ix
   64CC DD E1         [14]  284 	pop	ix
   64CE C9            [10]  285 	ret
                            286 ;src/render.c:64: void deleteSprites(){
                            287 ;	---------------------------------
                            288 ; Function deleteSprites
                            289 ; ---------------------------------
   64CF                     290 _deleteSprites::
   64CF DD E5         [15]  291 	push	ix
   64D1 DD 21 00 00   [14]  292 	ld	ix,#0
   64D5 DD 39         [15]  293 	add	ix,sp
   64D7 21 F5 FF      [10]  294 	ld	hl, #-11
   64DA 39            [11]  295 	add	hl, sp
   64DB F9            [ 6]  296 	ld	sp, hl
                            297 ;src/render.c:69: for (i = 0; i < MAX_SPRITES; i++) {
   64DC DD 36 F5 00   [19]  298 	ld	-11 (ix), #0x00
   64E0                     299 00107$:
                            300 ;src/render.c:70: if (sprites[i].id !=0) {
   64E0 DD 4E F5      [19]  301 	ld	c,-11 (ix)
   64E3 06 00         [ 7]  302 	ld	b,#0x00
   64E5 69            [ 4]  303 	ld	l, c
   64E6 60            [ 4]  304 	ld	h, b
   64E7 29            [11]  305 	add	hl, hl
   64E8 09            [11]  306 	add	hl, bc
   64E9 29            [11]  307 	add	hl, hl
   64EA 29            [11]  308 	add	hl, hl
   64EB 29            [11]  309 	add	hl, hl
   64EC 01 19 6A      [10]  310 	ld	bc,#_sprites
   64EF 09            [11]  311 	add	hl,bc
   64F0 DD 75 F6      [19]  312 	ld	-10 (ix), l
   64F3 DD 74 F7      [19]  313 	ld	-9 (ix), h
   64F6 7E            [ 7]  314 	ld	a, (hl)
   64F7 DD 77 FA      [19]  315 	ld	-6 (ix), a
   64FA B7            [ 4]  316 	or	a, a
   64FB CA AC 65      [10]  317 	jp	Z, 00108$
                            318 ;src/render.c:71: if (!swap_memvideo){
   64FE 3A D9 6C      [13]  319 	ld	a,(#_swap_memvideo + 0)
   6501 B7            [ 4]  320 	or	a, a
   6502 20 1E         [12]  321 	jr	NZ,00102$
                            322 ;src/render.c:72: x = sprites[i].x_prev_B;
   6504 DD 6E F6      [19]  323 	ld	l,-10 (ix)
   6507 DD 66 F7      [19]  324 	ld	h,-9 (ix)
   650A 11 07 00      [10]  325 	ld	de, #0x0007
   650D 19            [11]  326 	add	hl, de
   650E 7E            [ 7]  327 	ld	a, (hl)
   650F DD 77 FA      [19]  328 	ld	-6 (ix), a
                            329 ;src/render.c:73: y = sprites[i].y_prev_B;
   6512 DD 6E F6      [19]  330 	ld	l,-10 (ix)
   6515 DD 66 F7      [19]  331 	ld	h,-9 (ix)
   6518 11 08 00      [10]  332 	ld	de, #0x0008
   651B 19            [11]  333 	add	hl, de
   651C 7E            [ 7]  334 	ld	a, (hl)
   651D DD 77 FB      [19]  335 	ld	-5 (ix), a
   6520 18 1C         [12]  336 	jr	00103$
   6522                     337 00102$:
                            338 ;src/render.c:76: x = sprites[i].x_prev_A;
   6522 DD 6E F6      [19]  339 	ld	l,-10 (ix)
   6525 DD 66 F7      [19]  340 	ld	h,-9 (ix)
   6528 11 05 00      [10]  341 	ld	de, #0x0005
   652B 19            [11]  342 	add	hl, de
   652C 7E            [ 7]  343 	ld	a, (hl)
   652D DD 77 FA      [19]  344 	ld	-6 (ix), a
                            345 ;src/render.c:77: y = sprites[i].y_prev_A;
   6530 DD 6E F6      [19]  346 	ld	l,-10 (ix)
   6533 DD 66 F7      [19]  347 	ld	h,-9 (ix)
   6536 11 06 00      [10]  348 	ld	de, #0x0006
   6539 19            [11]  349 	add	hl, de
   653A 7E            [ 7]  350 	ld	a, (hl)
   653B DD 77 FB      [19]  351 	ld	-5 (ix), a
   653E                     352 00103$:
                            353 ;src/render.c:82: sprites[i].width, sprites[i].height);
   653E DD 7E F6      [19]  354 	ld	a, -10 (ix)
   6541 DD 77 F8      [19]  355 	ld	-8 (ix), a
   6544 DD 7E F7      [19]  356 	ld	a, -9 (ix)
   6547 DD 77 F9      [19]  357 	ld	-7 (ix), a
   654A DD 6E F8      [19]  358 	ld	l,-8 (ix)
   654D DD 66 F9      [19]  359 	ld	h,-7 (ix)
   6550 11 09 00      [10]  360 	ld	de, #0x0009
   6553 19            [11]  361 	add	hl, de
   6554 7E            [ 7]  362 	ld	a, (hl)
   6555 DD 77 F8      [19]  363 	ld	-8 (ix), a
   6558 DD 6E F6      [19]  364 	ld	l,-10 (ix)
   655B DD 66 F7      [19]  365 	ld	h,-9 (ix)
   655E 11 0A 00      [10]  366 	ld	de, #0x000a
   6561 19            [11]  367 	add	hl, de
   6562 7E            [ 7]  368 	ld	a, (hl)
   6563 DD 77 F6      [19]  369 	ld	-10 (ix), a
                            370 ;src/render.c:81: cpct_px2byteM0(5,5),						//background color
   6566 21 05 05      [10]  371 	ld	hl, #0x0505
   6569 E5            [11]  372 	push	hl
   656A CD B4 68      [17]  373 	call	_cpct_px2byteM0
   656D DD 75 FE      [19]  374 	ld	-2 (ix), l
   6570 DD 36 FF 00   [19]  375 	ld	-1 (ix), #0x00
                            376 ;src/render.c:80: cpct_getScreenPtr(mem_start, x, y),
   6574 2A D6 6C      [16]  377 	ld	hl, (_mem_start)
   6577 DD 75 FC      [19]  378 	ld	-4 (ix), l
   657A DD 74 FD      [19]  379 	ld	-3 (ix), h
   657D DD 66 FB      [19]  380 	ld	h, -5 (ix)
   6580 DD 6E FA      [19]  381 	ld	l, -6 (ix)
   6583 E5            [11]  382 	push	hl
   6584 DD 6E FC      [19]  383 	ld	l,-4 (ix)
   6587 DD 66 FD      [19]  384 	ld	h,-3 (ix)
   658A E5            [11]  385 	push	hl
   658B CD C3 69      [17]  386 	call	_cpct_getScreenPtr
   658E DD 74 FD      [19]  387 	ld	-3 (ix), h
   6591 DD 75 FC      [19]  388 	ld	-4 (ix), l
   6594 DD 66 F8      [19]  389 	ld	h, -8 (ix)
   6597 DD 6E F6      [19]  390 	ld	l, -10 (ix)
   659A E5            [11]  391 	push	hl
   659B DD 6E FE      [19]  392 	ld	l,-2 (ix)
   659E DD 66 FF      [19]  393 	ld	h,-1 (ix)
   65A1 E5            [11]  394 	push	hl
   65A2 DD 6E FC      [19]  395 	ld	l,-4 (ix)
   65A5 DD 66 FD      [19]  396 	ld	h,-3 (ix)
   65A8 E5            [11]  397 	push	hl
   65A9 CD F6 68      [17]  398 	call	_cpct_drawSolidBox
   65AC                     399 00108$:
                            400 ;src/render.c:69: for (i = 0; i < MAX_SPRITES; i++) {
   65AC DD 34 F5      [23]  401 	inc	-11 (ix)
   65AF DD 7E F5      [19]  402 	ld	a, -11 (ix)
   65B2 D6 0A         [ 7]  403 	sub	a, #0x0a
   65B4 DA E0 64      [10]  404 	jp	C, 00107$
   65B7 DD F9         [10]  405 	ld	sp, ix
   65B9 DD E1         [14]  406 	pop	ix
   65BB C9            [10]  407 	ret
                            408 	.area _CODE
                            409 	.area _INITIALIZER
                            410 	.area _CABS (ABS)
