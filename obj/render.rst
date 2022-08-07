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
                             17 	.globl _cpct_hflipSpriteMaskedM0
                             18 ;--------------------------------------------------------
                             19 ; special function registers
                             20 ;--------------------------------------------------------
                             21 ;--------------------------------------------------------
                             22 ; ram data
                             23 ;--------------------------------------------------------
                             24 	.area _DATA
                             25 ;--------------------------------------------------------
                             26 ; ram data
                             27 ;--------------------------------------------------------
                             28 	.area _INITIALIZED
                             29 ;--------------------------------------------------------
                             30 ; absolute external ram data
                             31 ;--------------------------------------------------------
                             32 	.area _DABS (ABS)
                             33 ;--------------------------------------------------------
                             34 ; global & static initialisations
                             35 ;--------------------------------------------------------
                             36 	.area _HOME
                             37 	.area _GSINIT
                             38 	.area _GSFINAL
                             39 	.area _GSINIT
                             40 ;--------------------------------------------------------
                             41 ; Home
                             42 ;--------------------------------------------------------
                             43 	.area _HOME
                             44 	.area _HOME
                             45 ;--------------------------------------------------------
                             46 ; code
                             47 ;--------------------------------------------------------
                             48 	.area _CODE
                             49 ;src/render.c:11: void renderSprites(){
                             50 ;	---------------------------------
                             51 ; Function renderSprites
                             52 ; ---------------------------------
   58CE                      53 _renderSprites::
   58CE DD E5         [15]   54 	push	ix
   58D0 DD 21 00 00   [14]   55 	ld	ix,#0
   58D4 DD 39         [15]   56 	add	ix,sp
   58D6 21 F1 FF      [10]   57 	ld	hl, #-15
   58D9 39            [11]   58 	add	hl, sp
   58DA F9            [ 6]   59 	ld	sp, hl
                             60 ;src/render.c:16: for (i = 0; i < MAX_SPRITES; i++) {
   58DB DD 36 F1 00   [19]   61 	ld	-15 (ix), #0x00
   58DF                      62 00128$:
                             63 ;src/render.c:17: if (sprites[i].id !=0) {						//only live and renderable sprites
   58DF DD 4E F1      [19]   64 	ld	c,-15 (ix)
   58E2 06 00         [ 7]   65 	ld	b,#0x00
   58E4 69            [ 4]   66 	ld	l, c
   58E5 60            [ 4]   67 	ld	h, b
   58E6 29            [11]   68 	add	hl, hl
   58E7 09            [11]   69 	add	hl, bc
   58E8 29            [11]   70 	add	hl, hl
   58E9 29            [11]   71 	add	hl, hl
   58EA 29            [11]   72 	add	hl, hl
   58EB 01 5E 5F      [10]   73 	ld	bc,#_sprites
   58EE 09            [11]   74 	add	hl,bc
   58EF DD 75 FB      [19]   75 	ld	-5 (ix), l
   58F2 DD 74 FC      [19]   76 	ld	-4 (ix), h
   58F5 7E            [ 7]   77 	ld	a, (hl)
   58F6 B7            [ 4]   78 	or	a, a
   58F7 CA A3 5A      [10]   79 	jp	Z, 00129$
                             80 ;src/render.c:18: if (sprites[i].properties & MASK_RENDER) {
   58FA DD 6E FB      [19]   81 	ld	l,-5 (ix)
   58FD DD 66 FC      [19]   82 	ld	h,-4 (ix)
   5900 11 0B 00      [10]   83 	ld	de, #0x000b
   5903 19            [11]   84 	add	hl, de
   5904 4E            [ 7]   85 	ld	c, (hl)
                             86 ;src/render.c:46: cpct_getScreenPtr(mem_start, sprites[i].x, sprites[i].y),
   5905 DD 7E FB      [19]   87 	ld	a, -5 (ix)
   5908 C6 02         [ 7]   88 	add	a, #0x02
   590A DD 77 F7      [19]   89 	ld	-9 (ix), a
   590D DD 7E FC      [19]   90 	ld	a, -4 (ix)
   5910 CE 00         [ 7]   91 	adc	a, #0x00
   5912 DD 77 F8      [19]   92 	ld	-8 (ix), a
   5915 DD 7E FB      [19]   93 	ld	a, -5 (ix)
   5918 C6 01         [ 7]   94 	add	a, #0x01
   591A DD 77 FD      [19]   95 	ld	-3 (ix), a
   591D DD 7E FC      [19]   96 	ld	a, -4 (ix)
   5920 CE 00         [ 7]   97 	adc	a, #0x00
   5922 DD 77 FE      [19]   98 	ld	-2 (ix), a
                             99 ;src/render.c:18: if (sprites[i].properties & MASK_RENDER) {
   5925 CB 41         [ 8]  100 	bit	0, c
   5927 CA 52 5A      [10]  101 	jp	Z,00121$
                            102 ;src/render.c:33: sprite = sprites[i].sprite_f1; 
   592A DD 7E FB      [19]  103 	ld	a, -5 (ix)
   592D C6 0F         [ 7]  104 	add	a, #0x0f
   592F DD 77 F4      [19]  105 	ld	-12 (ix), a
   5932 DD 7E FC      [19]  106 	ld	a, -4 (ix)
   5935 CE 00         [ 7]  107 	adc	a, #0x00
   5937 DD 77 F5      [19]  108 	ld	-11 (ix), a
                            109 ;src/render.c:20: if (sprites[i].properties & MASK_ANIMATE) {
   593A CB 49         [ 8]  110 	bit	1, c
   593C 28 55         [12]  111 	jr	Z,00114$
                            112 ;src/render.c:28: if (anim_clock > 7) num_frame=2;
   593E 3E 07         [ 7]  113 	ld	a, #0x07
   5940 FD 21 4E 60   [14]  114 	ld	iy, #_anim_clock
   5944 FD 96 00      [19]  115 	sub	a, 0 (iy)
   5947 30 04         [12]  116 	jr	NC,00102$
   5949 3E 02         [ 7]  117 	ld	a, #0x02
   594B 18 02         [12]  118 	jr	00103$
   594D                     119 00102$:
                            120 ;src/render.c:29: else num_frame=1;
   594D 3E 01         [ 7]  121 	ld	a, #0x01
   594F                     122 00103$:
                            123 ;src/render.c:32: if (num_frame == 1) {
   594F FE 01         [ 7]  124 	cp	a, #0x01
   5951 20 0B         [12]  125 	jr	NZ,00111$
                            126 ;src/render.c:33: sprite = sprites[i].sprite_f1; 
   5953 DD 6E F4      [19]  127 	ld	l,-12 (ix)
   5956 DD 66 F5      [19]  128 	ld	h,-11 (ix)
   5959 5E            [ 7]  129 	ld	e, (hl)
   595A 23            [ 6]  130 	inc	hl
   595B 56            [ 7]  131 	ld	d, (hl)
   595C 18 3E         [12]  132 	jr	00115$
   595E                     133 00111$:
                            134 ;src/render.c:34: } else if (num_frame == 2) {
   595E FE 02         [ 7]  135 	cp	a, #0x02
   5960 20 0F         [12]  136 	jr	NZ,00108$
                            137 ;src/render.c:35: sprite = sprites[i].sprite_f2;
   5962 DD 6E FB      [19]  138 	ld	l,-5 (ix)
   5965 DD 66 FC      [19]  139 	ld	h,-4 (ix)
   5968 11 11 00      [10]  140 	ld	de, #0x0011
   596B 19            [11]  141 	add	hl, de
   596C 5E            [ 7]  142 	ld	e, (hl)
   596D 23            [ 6]  143 	inc	hl
   596E 56            [ 7]  144 	ld	d, (hl)
   596F 18 2B         [12]  145 	jr	00115$
   5971                     146 00108$:
                            147 ;src/render.c:36: } else if (num_frame == 3) { 
   5971 D6 03         [ 7]  148 	sub	a, #0x03
   5973 20 0F         [12]  149 	jr	NZ,00105$
                            150 ;src/render.c:37: sprite = sprites[i].sprite_f3; 
   5975 DD 6E FB      [19]  151 	ld	l,-5 (ix)
   5978 DD 66 FC      [19]  152 	ld	h,-4 (ix)
   597B 11 13 00      [10]  153 	ld	de, #0x0013
   597E 19            [11]  154 	add	hl, de
   597F 5E            [ 7]  155 	ld	e, (hl)
   5980 23            [ 6]  156 	inc	hl
   5981 56            [ 7]  157 	ld	d, (hl)
   5982 18 18         [12]  158 	jr	00115$
   5984                     159 00105$:
                            160 ;src/render.c:38: } else sprite = sprites[i].sprite_f4;
   5984 DD 6E FB      [19]  161 	ld	l,-5 (ix)
   5987 DD 66 FC      [19]  162 	ld	h,-4 (ix)
   598A 11 15 00      [10]  163 	ld	de, #0x0015
   598D 19            [11]  164 	add	hl, de
   598E 5E            [ 7]  165 	ld	e, (hl)
   598F 23            [ 6]  166 	inc	hl
   5990 56            [ 7]  167 	ld	d, (hl)
   5991 18 09         [12]  168 	jr	00115$
   5993                     169 00114$:
                            170 ;src/render.c:39: } else sprite = sprites[i].sprite_f1;
   5993 DD 6E F4      [19]  171 	ld	l,-12 (ix)
   5996 DD 66 F5      [19]  172 	ld	h,-11 (ix)
   5999 5E            [ 7]  173 	ld	e, (hl)
   599A 23            [ 6]  174 	inc	hl
   599B 56            [ 7]  175 	ld	d, (hl)
   599C                     176 00115$:
                            177 ;src/render.c:41: if (sprites[i].turned)					//turn sprite around
   599C DD 7E FB      [19]  178 	ld	a, -5 (ix)
   599F C6 17         [ 7]  179 	add	a, #0x17
   59A1 DD 77 F4      [19]  180 	ld	-12 (ix), a
   59A4 DD 7E FC      [19]  181 	ld	a, -4 (ix)
   59A7 CE 00         [ 7]  182 	adc	a, #0x00
   59A9 DD 77 F5      [19]  183 	ld	-11 (ix), a
   59AC DD 6E F4      [19]  184 	ld	l,-12 (ix)
   59AF DD 66 F5      [19]  185 	ld	h,-11 (ix)
   59B2 4E            [ 7]  186 	ld	c, (hl)
                            187 ;src/render.c:42: cpct_hflipSpriteMaskedM0(sprites[i].width, sprites[i].height, sprite);
   59B3 DD 7E FB      [19]  188 	ld	a, -5 (ix)
   59B6 C6 09         [ 7]  189 	add	a, #0x09
   59B8 DD 77 F9      [19]  190 	ld	-7 (ix), a
   59BB DD 7E FC      [19]  191 	ld	a, -4 (ix)
   59BE CE 00         [ 7]  192 	adc	a, #0x00
   59C0 DD 77 FA      [19]  193 	ld	-6 (ix), a
   59C3 DD 7E FB      [19]  194 	ld	a, -5 (ix)
   59C6 C6 0A         [ 7]  195 	add	a, #0x0a
   59C8 DD 77 F2      [19]  196 	ld	-14 (ix), a
   59CB DD 7E FC      [19]  197 	ld	a, -4 (ix)
   59CE CE 00         [ 7]  198 	adc	a, #0x00
   59D0 DD 77 F3      [19]  199 	ld	-13 (ix), a
                            200 ;src/render.c:41: if (sprites[i].turned)					//turn sprite around
   59D3 79            [ 4]  201 	ld	a, c
   59D4 B7            [ 4]  202 	or	a, a
   59D5 28 18         [12]  203 	jr	Z,00117$
                            204 ;src/render.c:42: cpct_hflipSpriteMaskedM0(sprites[i].width, sprites[i].height, sprite);
   59D7 DD 6E F9      [19]  205 	ld	l,-7 (ix)
   59DA DD 66 FA      [19]  206 	ld	h,-6 (ix)
   59DD 46            [ 7]  207 	ld	b, (hl)
   59DE DD 6E F2      [19]  208 	ld	l,-14 (ix)
   59E1 DD 66 F3      [19]  209 	ld	h,-13 (ix)
   59E4 7E            [ 7]  210 	ld	a, (hl)
   59E5 D5            [11]  211 	push	de
   59E6 D5            [11]  212 	push	de
   59E7 C5            [11]  213 	push	bc
   59E8 33            [ 6]  214 	inc	sp
   59E9 F5            [11]  215 	push	af
   59EA 33            [ 6]  216 	inc	sp
   59EB CD 2D 5C      [17]  217 	call	_cpct_hflipSpriteMaskedM0
   59EE D1            [10]  218 	pop	de
   59EF                     219 00117$:
                            220 ;src/render.c:47: sprites[i].width, sprites[i].height);
   59EF DD 6E F9      [19]  221 	ld	l,-7 (ix)
   59F2 DD 66 FA      [19]  222 	ld	h,-6 (ix)
   59F5 7E            [ 7]  223 	ld	a, (hl)
   59F6 DD 77 FF      [19]  224 	ld	-1 (ix), a
   59F9 DD 6E F2      [19]  225 	ld	l,-14 (ix)
   59FC DD 66 F3      [19]  226 	ld	h,-13 (ix)
   59FF 7E            [ 7]  227 	ld	a, (hl)
   5A00 DD 77 F6      [19]  228 	ld	-10 (ix), a
                            229 ;src/render.c:46: cpct_getScreenPtr(mem_start, sprites[i].x, sprites[i].y),
   5A03 DD 6E F7      [19]  230 	ld	l,-9 (ix)
   5A06 DD 66 F8      [19]  231 	ld	h,-8 (ix)
   5A09 4E            [ 7]  232 	ld	c, (hl)
   5A0A DD 6E FD      [19]  233 	ld	l,-3 (ix)
   5A0D DD 66 FE      [19]  234 	ld	h,-2 (ix)
   5A10 46            [ 7]  235 	ld	b, (hl)
   5A11 FD 2A 4F 60   [20]  236 	ld	iy, (_mem_start)
   5A15 D5            [11]  237 	push	de
   5A16 79            [ 4]  238 	ld	a, c
   5A17 F5            [11]  239 	push	af
   5A18 33            [ 6]  240 	inc	sp
   5A19 C5            [11]  241 	push	bc
   5A1A 33            [ 6]  242 	inc	sp
   5A1B FD E5         [15]  243 	push	iy
   5A1D CD 38 5F      [17]  244 	call	_cpct_getScreenPtr
   5A20 4D            [ 4]  245 	ld	c, l
   5A21 44            [ 4]  246 	ld	b, h
   5A22 D1            [10]  247 	pop	de
                            248 ;src/render.c:44: cpct_drawSpriteMasked(sprite,
   5A23 D5            [11]  249 	push	de
   5A24 DD 66 FF      [19]  250 	ld	h, -1 (ix)
   5A27 DD 6E F6      [19]  251 	ld	l, -10 (ix)
   5A2A E5            [11]  252 	push	hl
   5A2B C5            [11]  253 	push	bc
   5A2C D5            [11]  254 	push	de
   5A2D CD CD 5D      [17]  255 	call	_cpct_drawSpriteMasked
   5A30 D1            [10]  256 	pop	de
                            257 ;src/render.c:49: if (sprites[i].turned)					//turn back to normal (looking right)
   5A31 DD 6E F4      [19]  258 	ld	l,-12 (ix)
   5A34 DD 66 F5      [19]  259 	ld	h,-11 (ix)
   5A37 7E            [ 7]  260 	ld	a, (hl)
   5A38 B7            [ 4]  261 	or	a, a
   5A39 28 17         [12]  262 	jr	Z,00121$
                            263 ;src/render.c:50: cpct_hflipSpriteMaskedM0(sprites[i].width, sprites[i].height, sprite);
   5A3B DD 6E F9      [19]  264 	ld	l,-7 (ix)
   5A3E DD 66 FA      [19]  265 	ld	h,-6 (ix)
   5A41 4E            [ 7]  266 	ld	c, (hl)
   5A42 DD 6E F2      [19]  267 	ld	l,-14 (ix)
   5A45 DD 66 F3      [19]  268 	ld	h,-13 (ix)
   5A48 46            [ 7]  269 	ld	b, (hl)
   5A49 D5            [11]  270 	push	de
   5A4A 79            [ 4]  271 	ld	a, c
   5A4B F5            [11]  272 	push	af
   5A4C 33            [ 6]  273 	inc	sp
   5A4D C5            [11]  274 	push	bc
   5A4E 33            [ 6]  275 	inc	sp
   5A4F CD 2D 5C      [17]  276 	call	_cpct_hflipSpriteMaskedM0
   5A52                     277 00121$:
                            278 ;src/render.c:46: cpct_getScreenPtr(mem_start, sprites[i].x, sprites[i].y),
   5A52 DD 6E FD      [19]  279 	ld	l,-3 (ix)
   5A55 DD 66 FE      [19]  280 	ld	h,-2 (ix)
   5A58 4E            [ 7]  281 	ld	c, (hl)
                            282 ;src/render.c:55: if (!swap_memvideo) {
   5A59 3A 52 60      [13]  283 	ld	a,(#_swap_memvideo + 0)
   5A5C B7            [ 4]  284 	or	a, a
   5A5D 20 23         [12]  285 	jr	NZ,00123$
                            286 ;src/render.c:56: sprites[i].x_prev_B = sprites[i].x;
   5A5F DD 7E FB      [19]  287 	ld	a, -5 (ix)
   5A62 C6 07         [ 7]  288 	add	a, #0x07
   5A64 6F            [ 4]  289 	ld	l, a
   5A65 DD 7E FC      [19]  290 	ld	a, -4 (ix)
   5A68 CE 00         [ 7]  291 	adc	a, #0x00
   5A6A 67            [ 4]  292 	ld	h, a
   5A6B 71            [ 7]  293 	ld	(hl), c
                            294 ;src/render.c:57: sprites[i].y_prev_B = sprites[i].y;
   5A6C DD 7E FB      [19]  295 	ld	a, -5 (ix)
   5A6F C6 08         [ 7]  296 	add	a, #0x08
   5A71 4F            [ 4]  297 	ld	c, a
   5A72 DD 7E FC      [19]  298 	ld	a, -4 (ix)
   5A75 CE 00         [ 7]  299 	adc	a, #0x00
   5A77 47            [ 4]  300 	ld	b, a
   5A78 DD 6E F7      [19]  301 	ld	l,-9 (ix)
   5A7B DD 66 F8      [19]  302 	ld	h,-8 (ix)
   5A7E 7E            [ 7]  303 	ld	a, (hl)
   5A7F 02            [ 7]  304 	ld	(bc), a
   5A80 18 21         [12]  305 	jr	00129$
   5A82                     306 00123$:
                            307 ;src/render.c:59: sprites[i].x_prev_A = sprites[i].x;
   5A82 DD 7E FB      [19]  308 	ld	a, -5 (ix)
   5A85 C6 05         [ 7]  309 	add	a, #0x05
   5A87 6F            [ 4]  310 	ld	l, a
   5A88 DD 7E FC      [19]  311 	ld	a, -4 (ix)
   5A8B CE 00         [ 7]  312 	adc	a, #0x00
   5A8D 67            [ 4]  313 	ld	h, a
   5A8E 71            [ 7]  314 	ld	(hl), c
                            315 ;src/render.c:60: sprites[i].y_prev_A = sprites[i].y;
   5A8F DD 7E FB      [19]  316 	ld	a, -5 (ix)
   5A92 C6 06         [ 7]  317 	add	a, #0x06
   5A94 4F            [ 4]  318 	ld	c, a
   5A95 DD 7E FC      [19]  319 	ld	a, -4 (ix)
   5A98 CE 00         [ 7]  320 	adc	a, #0x00
   5A9A 47            [ 4]  321 	ld	b, a
   5A9B DD 6E F7      [19]  322 	ld	l,-9 (ix)
   5A9E DD 66 F8      [19]  323 	ld	h,-8 (ix)
   5AA1 7E            [ 7]  324 	ld	a, (hl)
   5AA2 02            [ 7]  325 	ld	(bc), a
   5AA3                     326 00129$:
                            327 ;src/render.c:16: for (i = 0; i < MAX_SPRITES; i++) {
   5AA3 DD 34 F1      [23]  328 	inc	-15 (ix)
   5AA6 DD 7E F1      [19]  329 	ld	a, -15 (ix)
   5AA9 D6 0A         [ 7]  330 	sub	a, #0x0a
   5AAB DA DF 58      [10]  331 	jp	C, 00128$
   5AAE DD F9         [10]  332 	ld	sp, ix
   5AB0 DD E1         [14]  333 	pop	ix
   5AB2 C9            [10]  334 	ret
                            335 ;src/render.c:66: void deleteSprites(){
                            336 ;	---------------------------------
                            337 ; Function deleteSprites
                            338 ; ---------------------------------
   5AB3                     339 _deleteSprites::
   5AB3 DD E5         [15]  340 	push	ix
   5AB5 DD 21 00 00   [14]  341 	ld	ix,#0
   5AB9 DD 39         [15]  342 	add	ix,sp
   5ABB 21 F5 FF      [10]  343 	ld	hl, #-11
   5ABE 39            [11]  344 	add	hl, sp
   5ABF F9            [ 6]  345 	ld	sp, hl
                            346 ;src/render.c:71: for (i = 0; i < MAX_SPRITES; i++) {
   5AC0 DD 36 F5 00   [19]  347 	ld	-11 (ix), #0x00
   5AC4                     348 00107$:
                            349 ;src/render.c:72: if (sprites[i].id !=0) {
   5AC4 DD 4E F5      [19]  350 	ld	c,-11 (ix)
   5AC7 06 00         [ 7]  351 	ld	b,#0x00
   5AC9 69            [ 4]  352 	ld	l, c
   5ACA 60            [ 4]  353 	ld	h, b
   5ACB 29            [11]  354 	add	hl, hl
   5ACC 09            [11]  355 	add	hl, bc
   5ACD 29            [11]  356 	add	hl, hl
   5ACE 29            [11]  357 	add	hl, hl
   5ACF 29            [11]  358 	add	hl, hl
   5AD0 01 5E 5F      [10]  359 	ld	bc,#_sprites
   5AD3 09            [11]  360 	add	hl,bc
   5AD4 DD 75 F6      [19]  361 	ld	-10 (ix), l
   5AD7 DD 74 F7      [19]  362 	ld	-9 (ix), h
   5ADA 7E            [ 7]  363 	ld	a, (hl)
   5ADB DD 77 FF      [19]  364 	ld	-1 (ix), a
   5ADE B7            [ 4]  365 	or	a, a
   5ADF CA 90 5B      [10]  366 	jp	Z, 00108$
                            367 ;src/render.c:73: if (!swap_memvideo){
   5AE2 3A 52 60      [13]  368 	ld	a,(#_swap_memvideo + 0)
   5AE5 B7            [ 4]  369 	or	a, a
   5AE6 20 1E         [12]  370 	jr	NZ,00102$
                            371 ;src/render.c:74: x = sprites[i].x_prev_B;
   5AE8 DD 6E F6      [19]  372 	ld	l,-10 (ix)
   5AEB DD 66 F7      [19]  373 	ld	h,-9 (ix)
   5AEE 11 07 00      [10]  374 	ld	de, #0x0007
   5AF1 19            [11]  375 	add	hl, de
   5AF2 7E            [ 7]  376 	ld	a, (hl)
   5AF3 DD 77 FF      [19]  377 	ld	-1 (ix), a
                            378 ;src/render.c:75: y = sprites[i].y_prev_B;
   5AF6 DD 6E F6      [19]  379 	ld	l,-10 (ix)
   5AF9 DD 66 F7      [19]  380 	ld	h,-9 (ix)
   5AFC 11 08 00      [10]  381 	ld	de, #0x0008
   5AFF 19            [11]  382 	add	hl, de
   5B00 7E            [ 7]  383 	ld	a, (hl)
   5B01 DD 77 FE      [19]  384 	ld	-2 (ix), a
   5B04 18 1C         [12]  385 	jr	00103$
   5B06                     386 00102$:
                            387 ;src/render.c:78: x = sprites[i].x_prev_A;
   5B06 DD 6E F6      [19]  388 	ld	l,-10 (ix)
   5B09 DD 66 F7      [19]  389 	ld	h,-9 (ix)
   5B0C 11 05 00      [10]  390 	ld	de, #0x0005
   5B0F 19            [11]  391 	add	hl, de
   5B10 7E            [ 7]  392 	ld	a, (hl)
   5B11 DD 77 FF      [19]  393 	ld	-1 (ix), a
                            394 ;src/render.c:79: y = sprites[i].y_prev_A;
   5B14 DD 6E F6      [19]  395 	ld	l,-10 (ix)
   5B17 DD 66 F7      [19]  396 	ld	h,-9 (ix)
   5B1A 11 06 00      [10]  397 	ld	de, #0x0006
   5B1D 19            [11]  398 	add	hl, de
   5B1E 7E            [ 7]  399 	ld	a, (hl)
   5B1F DD 77 FE      [19]  400 	ld	-2 (ix), a
   5B22                     401 00103$:
                            402 ;src/render.c:84: sprites[i].width, sprites[i].height);
   5B22 DD 7E F6      [19]  403 	ld	a, -10 (ix)
   5B25 DD 77 FC      [19]  404 	ld	-4 (ix), a
   5B28 DD 7E F7      [19]  405 	ld	a, -9 (ix)
   5B2B DD 77 FD      [19]  406 	ld	-3 (ix), a
   5B2E DD 6E FC      [19]  407 	ld	l,-4 (ix)
   5B31 DD 66 FD      [19]  408 	ld	h,-3 (ix)
   5B34 11 09 00      [10]  409 	ld	de, #0x0009
   5B37 19            [11]  410 	add	hl, de
   5B38 7E            [ 7]  411 	ld	a, (hl)
   5B39 DD 77 FC      [19]  412 	ld	-4 (ix), a
   5B3C DD 6E F6      [19]  413 	ld	l,-10 (ix)
   5B3F DD 66 F7      [19]  414 	ld	h,-9 (ix)
   5B42 11 0A 00      [10]  415 	ld	de, #0x000a
   5B45 19            [11]  416 	add	hl, de
   5B46 7E            [ 7]  417 	ld	a, (hl)
   5B47 DD 77 F6      [19]  418 	ld	-10 (ix), a
                            419 ;src/render.c:83: cpct_px2byteM0(5,5),						//background color
   5B4A 21 05 05      [10]  420 	ld	hl, #0x0505
   5B4D E5            [11]  421 	push	hl
   5B4E CD 31 5E      [17]  422 	call	_cpct_px2byteM0
   5B51 DD 75 FA      [19]  423 	ld	-6 (ix), l
   5B54 DD 36 FB 00   [19]  424 	ld	-5 (ix), #0x00
                            425 ;src/render.c:82: cpct_getScreenPtr(mem_start, x, y),
   5B58 2A 4F 60      [16]  426 	ld	hl, (_mem_start)
   5B5B DD 75 F8      [19]  427 	ld	-8 (ix), l
   5B5E DD 74 F9      [19]  428 	ld	-7 (ix), h
   5B61 DD 66 FE      [19]  429 	ld	h, -2 (ix)
   5B64 DD 6E FF      [19]  430 	ld	l, -1 (ix)
   5B67 E5            [11]  431 	push	hl
   5B68 DD 6E F8      [19]  432 	ld	l,-8 (ix)
   5B6B DD 66 F9      [19]  433 	ld	h,-7 (ix)
   5B6E E5            [11]  434 	push	hl
   5B6F CD 38 5F      [17]  435 	call	_cpct_getScreenPtr
   5B72 DD 74 F9      [19]  436 	ld	-7 (ix), h
   5B75 DD 75 F8      [19]  437 	ld	-8 (ix), l
   5B78 DD 66 FC      [19]  438 	ld	h, -4 (ix)
   5B7B DD 6E F6      [19]  439 	ld	l, -10 (ix)
   5B7E E5            [11]  440 	push	hl
   5B7F DD 6E FA      [19]  441 	ld	l,-6 (ix)
   5B82 DD 66 FB      [19]  442 	ld	h,-5 (ix)
   5B85 E5            [11]  443 	push	hl
   5B86 DD 6E F8      [19]  444 	ld	l,-8 (ix)
   5B89 DD 66 F9      [19]  445 	ld	h,-7 (ix)
   5B8C E5            [11]  446 	push	hl
   5B8D CD 6B 5E      [17]  447 	call	_cpct_drawSolidBox
   5B90                     448 00108$:
                            449 ;src/render.c:71: for (i = 0; i < MAX_SPRITES; i++) {
   5B90 DD 34 F5      [23]  450 	inc	-11 (ix)
   5B93 DD 7E F5      [19]  451 	ld	a, -11 (ix)
   5B96 D6 0A         [ 7]  452 	sub	a, #0x0a
   5B98 DA C4 5A      [10]  453 	jp	C, 00107$
   5B9B DD F9         [10]  454 	ld	sp, ix
   5B9D DD E1         [14]  455 	pop	ix
   5B9F C9            [10]  456 	ret
                            457 	.area _CODE
                            458 	.area _INITIALIZER
                            459 	.area _CABS (ABS)
