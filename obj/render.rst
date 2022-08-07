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
   58C4                      53 _renderSprites::
   58C4 DD E5         [15]   54 	push	ix
   58C6 DD 21 00 00   [14]   55 	ld	ix,#0
   58CA DD 39         [15]   56 	add	ix,sp
   58CC 21 F6 FF      [10]   57 	ld	hl, #-10
   58CF 39            [11]   58 	add	hl, sp
   58D0 F9            [ 6]   59 	ld	sp, hl
                             60 ;src/render.c:16: for (i = 0; i < MAX_SPRITES; i++) {
   58D1 DD 36 F6 00   [19]   61 	ld	-10 (ix), #0x00
   58D5                      62 00126$:
                             63 ;src/render.c:17: if (sprites[i].id !=0) {						//only live and renderable sprites
   58D5 DD 4E F6      [19]   64 	ld	c,-10 (ix)
   58D8 06 00         [ 7]   65 	ld	b,#0x00
   58DA 69            [ 4]   66 	ld	l, c
   58DB 60            [ 4]   67 	ld	h, b
   58DC 29            [11]   68 	add	hl, hl
   58DD 09            [11]   69 	add	hl, bc
   58DE 29            [11]   70 	add	hl, hl
   58DF 29            [11]   71 	add	hl, hl
   58E0 29            [11]   72 	add	hl, hl
   58E1 09            [11]   73 	add	hl, bc
   58E2 01 24 5F      [10]   74 	ld	bc,#_sprites
   58E5 09            [11]   75 	add	hl,bc
   58E6 DD 75 FA      [19]   76 	ld	-6 (ix), l
   58E9 DD 74 FB      [19]   77 	ld	-5 (ix), h
   58EC 7E            [ 7]   78 	ld	a, (hl)
   58ED B7            [ 4]   79 	or	a, a
   58EE CA 68 5A      [10]   80 	jp	Z, 00127$
                             81 ;src/render.c:18: if (sprites[i].properties & MASK_RENDER) {
   58F1 DD 6E FA      [19]   82 	ld	l,-6 (ix)
   58F4 DD 66 FB      [19]   83 	ld	h,-5 (ix)
   58F7 11 0B 00      [10]   84 	ld	de, #0x000b
   58FA 19            [11]   85 	add	hl, de
   58FB 4E            [ 7]   86 	ld	c, (hl)
                             87 ;src/render.c:46: cpct_getScreenPtr(mem_start, sprites[i].x, sprites[i].y),
   58FC DD 7E FA      [19]   88 	ld	a, -6 (ix)
   58FF C6 02         [ 7]   89 	add	a, #0x02
   5901 DD 77 F8      [19]   90 	ld	-8 (ix), a
   5904 DD 7E FB      [19]   91 	ld	a, -5 (ix)
   5907 CE 00         [ 7]   92 	adc	a, #0x00
   5909 DD 77 F9      [19]   93 	ld	-7 (ix), a
   590C DD 7E FA      [19]   94 	ld	a, -6 (ix)
   590F C6 01         [ 7]   95 	add	a, #0x01
   5911 DD 77 FE      [19]   96 	ld	-2 (ix), a
   5914 DD 7E FB      [19]   97 	ld	a, -5 (ix)
   5917 CE 00         [ 7]   98 	adc	a, #0x00
   5919 DD 77 FF      [19]   99 	ld	-1 (ix), a
                            100 ;src/render.c:18: if (sprites[i].properties & MASK_RENDER) {
   591C CB 41         [ 8]  101 	bit	0, c
   591E CA 17 5A      [10]  102 	jp	Z,00119$
                            103 ;src/render.c:33: sprite = sprites[i].sprite_f1; 
   5921 DD 7E FA      [19]  104 	ld	a, -6 (ix)
   5924 C6 0F         [ 7]  105 	add	a, #0x0f
   5926 DD 77 FC      [19]  106 	ld	-4 (ix), a
   5929 DD 7E FB      [19]  107 	ld	a, -5 (ix)
   592C CE 00         [ 7]  108 	adc	a, #0x00
   592E DD 77 FD      [19]  109 	ld	-3 (ix), a
                            110 ;src/render.c:20: if (sprites[i].properties & MASK_ANIMATE) {
   5931 CB 49         [ 8]  111 	bit	1, c
   5933 28 55         [12]  112 	jr	Z,00114$
                            113 ;src/render.c:28: if (anim_clock > 7) num_frame=2;
   5935 3E 07         [ 7]  114 	ld	a, #0x07
   5937 FD 21 1E 60   [14]  115 	ld	iy, #_anim_clock
   593B FD 96 00      [19]  116 	sub	a, 0 (iy)
   593E 30 04         [12]  117 	jr	NC,00102$
   5940 3E 02         [ 7]  118 	ld	a, #0x02
   5942 18 02         [12]  119 	jr	00103$
   5944                     120 00102$:
                            121 ;src/render.c:29: else num_frame=1;
   5944 3E 01         [ 7]  122 	ld	a, #0x01
   5946                     123 00103$:
                            124 ;src/render.c:32: if (num_frame == 1) {
   5946 FE 01         [ 7]  125 	cp	a, #0x01
   5948 20 0B         [12]  126 	jr	NZ,00111$
                            127 ;src/render.c:33: sprite = sprites[i].sprite_f1; 
   594A DD 6E FC      [19]  128 	ld	l,-4 (ix)
   594D DD 66 FD      [19]  129 	ld	h,-3 (ix)
   5950 5E            [ 7]  130 	ld	e, (hl)
   5951 23            [ 6]  131 	inc	hl
   5952 56            [ 7]  132 	ld	d, (hl)
   5953 18 3E         [12]  133 	jr	00115$
   5955                     134 00111$:
                            135 ;src/render.c:34: } else if (num_frame == 2) {
   5955 FE 02         [ 7]  136 	cp	a, #0x02
   5957 20 0F         [12]  137 	jr	NZ,00108$
                            138 ;src/render.c:35: sprite = sprites[i].sprite_f2;
   5959 DD 6E FA      [19]  139 	ld	l,-6 (ix)
   595C DD 66 FB      [19]  140 	ld	h,-5 (ix)
   595F 11 11 00      [10]  141 	ld	de, #0x0011
   5962 19            [11]  142 	add	hl, de
   5963 5E            [ 7]  143 	ld	e, (hl)
   5964 23            [ 6]  144 	inc	hl
   5965 56            [ 7]  145 	ld	d, (hl)
   5966 18 2B         [12]  146 	jr	00115$
   5968                     147 00108$:
                            148 ;src/render.c:36: } else if (num_frame == 3) { 
   5968 D6 03         [ 7]  149 	sub	a, #0x03
   596A 20 0F         [12]  150 	jr	NZ,00105$
                            151 ;src/render.c:37: sprite = sprites[i].sprite_f3; 
   596C DD 6E FA      [19]  152 	ld	l,-6 (ix)
   596F DD 66 FB      [19]  153 	ld	h,-5 (ix)
   5972 11 13 00      [10]  154 	ld	de, #0x0013
   5975 19            [11]  155 	add	hl, de
   5976 5E            [ 7]  156 	ld	e, (hl)
   5977 23            [ 6]  157 	inc	hl
   5978 56            [ 7]  158 	ld	d, (hl)
   5979 18 18         [12]  159 	jr	00115$
   597B                     160 00105$:
                            161 ;src/render.c:38: } else sprite = sprites[i].sprite_f4;
   597B DD 6E FA      [19]  162 	ld	l,-6 (ix)
   597E DD 66 FB      [19]  163 	ld	h,-5 (ix)
   5981 11 15 00      [10]  164 	ld	de, #0x0015
   5984 19            [11]  165 	add	hl, de
   5985 5E            [ 7]  166 	ld	e, (hl)
   5986 23            [ 6]  167 	inc	hl
   5987 56            [ 7]  168 	ld	d, (hl)
   5988 18 09         [12]  169 	jr	00115$
   598A                     170 00114$:
                            171 ;src/render.c:39: } else sprite = sprites[i].sprite_f1;
   598A DD 6E FC      [19]  172 	ld	l,-4 (ix)
   598D DD 66 FD      [19]  173 	ld	h,-3 (ix)
   5990 5E            [ 7]  174 	ld	e, (hl)
   5991 23            [ 6]  175 	inc	hl
   5992 56            [ 7]  176 	ld	d, (hl)
   5993                     177 00115$:
                            178 ;src/render.c:41: if (sprites[i].turned)					//turn sprite around
   5993 DD 6E FA      [19]  179 	ld	l,-6 (ix)
   5996 DD 66 FB      [19]  180 	ld	h,-5 (ix)
   5999 01 17 00      [10]  181 	ld	bc, #0x0017
   599C 09            [11]  182 	add	hl, bc
   599D 7E            [ 7]  183 	ld	a, (hl)
   599E 23            [ 6]  184 	inc	hl
   599F 66            [ 7]  185 	ld	h, (hl)
   59A0 6F            [ 4]  186 	ld	l, a
                            187 ;src/render.c:42: cpct_hflipSpriteMaskedM0(sprites[i].width, sprites[i].height, sprite);
   59A1 DD 7E FA      [19]  188 	ld	a, -6 (ix)
   59A4 C6 09         [ 7]  189 	add	a, #0x09
   59A6 4F            [ 4]  190 	ld	c, a
   59A7 DD 7E FB      [19]  191 	ld	a, -5 (ix)
   59AA CE 00         [ 7]  192 	adc	a, #0x00
   59AC 47            [ 4]  193 	ld	b, a
   59AD DD 7E FA      [19]  194 	ld	a, -6 (ix)
   59B0 C6 0A         [ 7]  195 	add	a, #0x0a
   59B2 DD 77 FC      [19]  196 	ld	-4 (ix), a
   59B5 DD 7E FB      [19]  197 	ld	a, -5 (ix)
   59B8 CE 00         [ 7]  198 	adc	a, #0x00
   59BA DD 77 FD      [19]  199 	ld	-3 (ix), a
                            200 ;src/render.c:41: if (sprites[i].turned)					//turn sprite around
   59BD 7C            [ 4]  201 	ld	a, h
   59BE B5            [ 4]  202 	or	a,l
   59BF 28 1C         [12]  203 	jr	Z,00117$
                            204 ;src/render.c:42: cpct_hflipSpriteMaskedM0(sprites[i].width, sprites[i].height, sprite);
   59C1 0A            [ 7]  205 	ld	a, (bc)
   59C2 DD 6E FC      [19]  206 	ld	l,-4 (ix)
   59C5 DD 66 FD      [19]  207 	ld	h,-3 (ix)
   59C8 F5            [11]  208 	push	af
   59C9 7E            [ 7]  209 	ld	a, (hl)
   59CA DD 77 F7      [19]  210 	ld	-9 (ix), a
   59CD F1            [10]  211 	pop	af
   59CE C5            [11]  212 	push	bc
   59CF D5            [11]  213 	push	de
   59D0 D5            [11]  214 	push	de
   59D1 F5            [11]  215 	push	af
   59D2 33            [ 6]  216 	inc	sp
   59D3 DD 7E F7      [19]  217 	ld	a, -9 (ix)
   59D6 F5            [11]  218 	push	af
   59D7 33            [ 6]  219 	inc	sp
   59D8 CD F3 5B      [17]  220 	call	_cpct_hflipSpriteMaskedM0
   59DB D1            [10]  221 	pop	de
   59DC C1            [10]  222 	pop	bc
   59DD                     223 00117$:
                            224 ;src/render.c:47: sprites[i].width, sprites[i].height);
   59DD 0A            [ 7]  225 	ld	a, (bc)
   59DE DD 77 F7      [19]  226 	ld	-9 (ix), a
   59E1 DD 6E FC      [19]  227 	ld	l,-4 (ix)
   59E4 DD 66 FD      [19]  228 	ld	h,-3 (ix)
   59E7 7E            [ 7]  229 	ld	a, (hl)
   59E8 DD 77 FC      [19]  230 	ld	-4 (ix), a
                            231 ;src/render.c:46: cpct_getScreenPtr(mem_start, sprites[i].x, sprites[i].y),
   59EB DD 6E F8      [19]  232 	ld	l,-8 (ix)
   59EE DD 66 F9      [19]  233 	ld	h,-7 (ix)
   59F1 4E            [ 7]  234 	ld	c, (hl)
   59F2 DD 6E FE      [19]  235 	ld	l,-2 (ix)
   59F5 DD 66 FF      [19]  236 	ld	h,-1 (ix)
   59F8 46            [ 7]  237 	ld	b, (hl)
   59F9 FD 2A 1F 60   [20]  238 	ld	iy, (_mem_start)
   59FD D5            [11]  239 	push	de
   59FE 79            [ 4]  240 	ld	a, c
   59FF F5            [11]  241 	push	af
   5A00 33            [ 6]  242 	inc	sp
   5A01 C5            [11]  243 	push	bc
   5A02 33            [ 6]  244 	inc	sp
   5A03 FD E5         [15]  245 	push	iy
   5A05 CD FE 5E      [17]  246 	call	_cpct_getScreenPtr
   5A08 4D            [ 4]  247 	ld	c, l
   5A09 44            [ 4]  248 	ld	b, h
   5A0A D1            [10]  249 	pop	de
                            250 ;src/render.c:44: cpct_drawSpriteMasked(sprite,
   5A0B DD 66 F7      [19]  251 	ld	h, -9 (ix)
   5A0E DD 6E FC      [19]  252 	ld	l, -4 (ix)
   5A11 E5            [11]  253 	push	hl
   5A12 C5            [11]  254 	push	bc
   5A13 D5            [11]  255 	push	de
   5A14 CD 93 5D      [17]  256 	call	_cpct_drawSpriteMasked
   5A17                     257 00119$:
                            258 ;src/render.c:46: cpct_getScreenPtr(mem_start, sprites[i].x, sprites[i].y),
   5A17 DD 6E FE      [19]  259 	ld	l,-2 (ix)
   5A1A DD 66 FF      [19]  260 	ld	h,-1 (ix)
   5A1D 4E            [ 7]  261 	ld	c, (hl)
                            262 ;src/render.c:51: if (!swap_memvideo) {
   5A1E 3A 22 60      [13]  263 	ld	a,(#_swap_memvideo + 0)
   5A21 B7            [ 4]  264 	or	a, a
   5A22 20 23         [12]  265 	jr	NZ,00121$
                            266 ;src/render.c:52: sprites[i].x_prev_B = sprites[i].x;
   5A24 DD 7E FA      [19]  267 	ld	a, -6 (ix)
   5A27 C6 07         [ 7]  268 	add	a, #0x07
   5A29 6F            [ 4]  269 	ld	l, a
   5A2A DD 7E FB      [19]  270 	ld	a, -5 (ix)
   5A2D CE 00         [ 7]  271 	adc	a, #0x00
   5A2F 67            [ 4]  272 	ld	h, a
   5A30 71            [ 7]  273 	ld	(hl), c
                            274 ;src/render.c:53: sprites[i].y_prev_B = sprites[i].y;
   5A31 DD 7E FA      [19]  275 	ld	a, -6 (ix)
   5A34 C6 08         [ 7]  276 	add	a, #0x08
   5A36 4F            [ 4]  277 	ld	c, a
   5A37 DD 7E FB      [19]  278 	ld	a, -5 (ix)
   5A3A CE 00         [ 7]  279 	adc	a, #0x00
   5A3C 47            [ 4]  280 	ld	b, a
   5A3D DD 6E F8      [19]  281 	ld	l,-8 (ix)
   5A40 DD 66 F9      [19]  282 	ld	h,-7 (ix)
   5A43 7E            [ 7]  283 	ld	a, (hl)
   5A44 02            [ 7]  284 	ld	(bc), a
   5A45 18 21         [12]  285 	jr	00127$
   5A47                     286 00121$:
                            287 ;src/render.c:55: sprites[i].x_prev_A = sprites[i].x;
   5A47 DD 7E FA      [19]  288 	ld	a, -6 (ix)
   5A4A C6 05         [ 7]  289 	add	a, #0x05
   5A4C 6F            [ 4]  290 	ld	l, a
   5A4D DD 7E FB      [19]  291 	ld	a, -5 (ix)
   5A50 CE 00         [ 7]  292 	adc	a, #0x00
   5A52 67            [ 4]  293 	ld	h, a
   5A53 71            [ 7]  294 	ld	(hl), c
                            295 ;src/render.c:56: sprites[i].y_prev_A = sprites[i].y;
   5A54 DD 7E FA      [19]  296 	ld	a, -6 (ix)
   5A57 C6 06         [ 7]  297 	add	a, #0x06
   5A59 4F            [ 4]  298 	ld	c, a
   5A5A DD 7E FB      [19]  299 	ld	a, -5 (ix)
   5A5D CE 00         [ 7]  300 	adc	a, #0x00
   5A5F 47            [ 4]  301 	ld	b, a
   5A60 DD 6E F8      [19]  302 	ld	l,-8 (ix)
   5A63 DD 66 F9      [19]  303 	ld	h,-7 (ix)
   5A66 7E            [ 7]  304 	ld	a, (hl)
   5A67 02            [ 7]  305 	ld	(bc), a
   5A68                     306 00127$:
                            307 ;src/render.c:16: for (i = 0; i < MAX_SPRITES; i++) {
   5A68 DD 34 F6      [23]  308 	inc	-10 (ix)
   5A6B DD 7E F6      [19]  309 	ld	a, -10 (ix)
   5A6E D6 0A         [ 7]  310 	sub	a, #0x0a
   5A70 DA D5 58      [10]  311 	jp	C, 00126$
   5A73 DD F9         [10]  312 	ld	sp, ix
   5A75 DD E1         [14]  313 	pop	ix
   5A77 C9            [10]  314 	ret
                            315 ;src/render.c:62: void deleteSprites(){
                            316 ;	---------------------------------
                            317 ; Function deleteSprites
                            318 ; ---------------------------------
   5A78                     319 _deleteSprites::
   5A78 DD E5         [15]  320 	push	ix
   5A7A DD 21 00 00   [14]  321 	ld	ix,#0
   5A7E DD 39         [15]  322 	add	ix,sp
   5A80 21 F5 FF      [10]  323 	ld	hl, #-11
   5A83 39            [11]  324 	add	hl, sp
   5A84 F9            [ 6]  325 	ld	sp, hl
                            326 ;src/render.c:67: for (i = 0; i < MAX_SPRITES; i++) {
   5A85 DD 36 F5 00   [19]  327 	ld	-11 (ix), #0x00
   5A89                     328 00107$:
                            329 ;src/render.c:68: if (sprites[i].id !=0) {
   5A89 DD 4E F5      [19]  330 	ld	c,-11 (ix)
   5A8C 06 00         [ 7]  331 	ld	b,#0x00
   5A8E 69            [ 4]  332 	ld	l, c
   5A8F 60            [ 4]  333 	ld	h, b
   5A90 29            [11]  334 	add	hl, hl
   5A91 09            [11]  335 	add	hl, bc
   5A92 29            [11]  336 	add	hl, hl
   5A93 29            [11]  337 	add	hl, hl
   5A94 29            [11]  338 	add	hl, hl
   5A95 09            [11]  339 	add	hl, bc
   5A96 01 24 5F      [10]  340 	ld	bc,#_sprites
   5A99 09            [11]  341 	add	hl,bc
   5A9A DD 75 F6      [19]  342 	ld	-10 (ix), l
   5A9D DD 74 F7      [19]  343 	ld	-9 (ix), h
   5AA0 7E            [ 7]  344 	ld	a, (hl)
   5AA1 DD 77 FF      [19]  345 	ld	-1 (ix), a
   5AA4 B7            [ 4]  346 	or	a, a
   5AA5 CA 56 5B      [10]  347 	jp	Z, 00108$
                            348 ;src/render.c:69: if (!swap_memvideo){
   5AA8 3A 22 60      [13]  349 	ld	a,(#_swap_memvideo + 0)
   5AAB B7            [ 4]  350 	or	a, a
   5AAC 20 1E         [12]  351 	jr	NZ,00102$
                            352 ;src/render.c:70: x = sprites[i].x_prev_B;
   5AAE DD 6E F6      [19]  353 	ld	l,-10 (ix)
   5AB1 DD 66 F7      [19]  354 	ld	h,-9 (ix)
   5AB4 11 07 00      [10]  355 	ld	de, #0x0007
   5AB7 19            [11]  356 	add	hl, de
   5AB8 7E            [ 7]  357 	ld	a, (hl)
   5AB9 DD 77 FF      [19]  358 	ld	-1 (ix), a
                            359 ;src/render.c:71: y = sprites[i].y_prev_B;
   5ABC DD 6E F6      [19]  360 	ld	l,-10 (ix)
   5ABF DD 66 F7      [19]  361 	ld	h,-9 (ix)
   5AC2 11 08 00      [10]  362 	ld	de, #0x0008
   5AC5 19            [11]  363 	add	hl, de
   5AC6 7E            [ 7]  364 	ld	a, (hl)
   5AC7 DD 77 FE      [19]  365 	ld	-2 (ix), a
   5ACA 18 1C         [12]  366 	jr	00103$
   5ACC                     367 00102$:
                            368 ;src/render.c:74: x = sprites[i].x_prev_A;
   5ACC DD 6E F6      [19]  369 	ld	l,-10 (ix)
   5ACF DD 66 F7      [19]  370 	ld	h,-9 (ix)
   5AD2 11 05 00      [10]  371 	ld	de, #0x0005
   5AD5 19            [11]  372 	add	hl, de
   5AD6 7E            [ 7]  373 	ld	a, (hl)
   5AD7 DD 77 FF      [19]  374 	ld	-1 (ix), a
                            375 ;src/render.c:75: y = sprites[i].y_prev_A;
   5ADA DD 6E F6      [19]  376 	ld	l,-10 (ix)
   5ADD DD 66 F7      [19]  377 	ld	h,-9 (ix)
   5AE0 11 06 00      [10]  378 	ld	de, #0x0006
   5AE3 19            [11]  379 	add	hl, de
   5AE4 7E            [ 7]  380 	ld	a, (hl)
   5AE5 DD 77 FE      [19]  381 	ld	-2 (ix), a
   5AE8                     382 00103$:
                            383 ;src/render.c:80: sprites[i].width, sprites[i].height);
   5AE8 DD 7E F6      [19]  384 	ld	a, -10 (ix)
   5AEB DD 77 FC      [19]  385 	ld	-4 (ix), a
   5AEE DD 7E F7      [19]  386 	ld	a, -9 (ix)
   5AF1 DD 77 FD      [19]  387 	ld	-3 (ix), a
   5AF4 DD 6E FC      [19]  388 	ld	l,-4 (ix)
   5AF7 DD 66 FD      [19]  389 	ld	h,-3 (ix)
   5AFA 11 09 00      [10]  390 	ld	de, #0x0009
   5AFD 19            [11]  391 	add	hl, de
   5AFE 7E            [ 7]  392 	ld	a, (hl)
   5AFF DD 77 FC      [19]  393 	ld	-4 (ix), a
   5B02 DD 6E F6      [19]  394 	ld	l,-10 (ix)
   5B05 DD 66 F7      [19]  395 	ld	h,-9 (ix)
   5B08 11 0A 00      [10]  396 	ld	de, #0x000a
   5B0B 19            [11]  397 	add	hl, de
   5B0C 7E            [ 7]  398 	ld	a, (hl)
   5B0D DD 77 F6      [19]  399 	ld	-10 (ix), a
                            400 ;src/render.c:79: cpct_px2byteM0(5,5),						//background color
   5B10 21 05 05      [10]  401 	ld	hl, #0x0505
   5B13 E5            [11]  402 	push	hl
   5B14 CD F7 5D      [17]  403 	call	_cpct_px2byteM0
   5B17 DD 75 FA      [19]  404 	ld	-6 (ix), l
   5B1A DD 36 FB 00   [19]  405 	ld	-5 (ix), #0x00
                            406 ;src/render.c:78: cpct_getScreenPtr(mem_start, x, y),
   5B1E 2A 1F 60      [16]  407 	ld	hl, (_mem_start)
   5B21 DD 75 F8      [19]  408 	ld	-8 (ix), l
   5B24 DD 74 F9      [19]  409 	ld	-7 (ix), h
   5B27 DD 66 FE      [19]  410 	ld	h, -2 (ix)
   5B2A DD 6E FF      [19]  411 	ld	l, -1 (ix)
   5B2D E5            [11]  412 	push	hl
   5B2E DD 6E F8      [19]  413 	ld	l,-8 (ix)
   5B31 DD 66 F9      [19]  414 	ld	h,-7 (ix)
   5B34 E5            [11]  415 	push	hl
   5B35 CD FE 5E      [17]  416 	call	_cpct_getScreenPtr
   5B38 DD 74 F9      [19]  417 	ld	-7 (ix), h
   5B3B DD 75 F8      [19]  418 	ld	-8 (ix), l
   5B3E DD 66 FC      [19]  419 	ld	h, -4 (ix)
   5B41 DD 6E F6      [19]  420 	ld	l, -10 (ix)
   5B44 E5            [11]  421 	push	hl
   5B45 DD 6E FA      [19]  422 	ld	l,-6 (ix)
   5B48 DD 66 FB      [19]  423 	ld	h,-5 (ix)
   5B4B E5            [11]  424 	push	hl
   5B4C DD 6E F8      [19]  425 	ld	l,-8 (ix)
   5B4F DD 66 F9      [19]  426 	ld	h,-7 (ix)
   5B52 E5            [11]  427 	push	hl
   5B53 CD 31 5E      [17]  428 	call	_cpct_drawSolidBox
   5B56                     429 00108$:
                            430 ;src/render.c:67: for (i = 0; i < MAX_SPRITES; i++) {
   5B56 DD 34 F5      [23]  431 	inc	-11 (ix)
   5B59 DD 7E F5      [19]  432 	ld	a, -11 (ix)
   5B5C D6 0A         [ 7]  433 	sub	a, #0x0a
   5B5E DA 89 5A      [10]  434 	jp	C, 00107$
   5B61 DD F9         [10]  435 	ld	sp, ix
   5B63 DD E1         [14]  436 	pop	ix
   5B65 C9            [10]  437 	ret
                            438 	.area _CODE
                            439 	.area _INITIALIZER
                            440 	.area _CABS (ABS)
