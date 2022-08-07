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
   6042                      53 _renderSprites::
   6042 DD E5         [15]   54 	push	ix
   6044 DD 21 00 00   [14]   55 	ld	ix,#0
   6048 DD 39         [15]   56 	add	ix,sp
   604A 21 F1 FF      [10]   57 	ld	hl, #-15
   604D 39            [11]   58 	add	hl, sp
   604E F9            [ 6]   59 	ld	sp, hl
                             60 ;src/render.c:16: for (i = 0; i < MAX_SPRITES; i++) {
   604F DD 36 F1 00   [19]   61 	ld	-15 (ix), #0x00
   6053                      62 00128$:
                             63 ;src/render.c:17: if (sprites[i].id !=0) {						//only live and renderable sprites
   6053 DD 4E F1      [19]   64 	ld	c,-15 (ix)
   6056 06 00         [ 7]   65 	ld	b,#0x00
   6058 69            [ 4]   66 	ld	l, c
   6059 60            [ 4]   67 	ld	h, b
   605A 29            [11]   68 	add	hl, hl
   605B 09            [11]   69 	add	hl, bc
   605C 29            [11]   70 	add	hl, hl
   605D 29            [11]   71 	add	hl, hl
   605E 29            [11]   72 	add	hl, hl
   605F 01 D2 66      [10]   73 	ld	bc,#_sprites
   6062 09            [11]   74 	add	hl,bc
   6063 DD 75 FE      [19]   75 	ld	-2 (ix), l
   6066 DD 74 FF      [19]   76 	ld	-1 (ix), h
   6069 7E            [ 7]   77 	ld	a, (hl)
   606A B7            [ 4]   78 	or	a, a
   606B CA 17 62      [10]   79 	jp	Z, 00129$
                             80 ;src/render.c:18: if (sprites[i].properties & MASK_RENDER) {
   606E DD 6E FE      [19]   81 	ld	l,-2 (ix)
   6071 DD 66 FF      [19]   82 	ld	h,-1 (ix)
   6074 11 0B 00      [10]   83 	ld	de, #0x000b
   6077 19            [11]   84 	add	hl, de
   6078 4E            [ 7]   85 	ld	c, (hl)
                             86 ;src/render.c:46: cpct_getScreenPtr(mem_start, sprites[i].x, sprites[i].y),
   6079 DD 7E FE      [19]   87 	ld	a, -2 (ix)
   607C C6 02         [ 7]   88 	add	a, #0x02
   607E DD 77 FA      [19]   89 	ld	-6 (ix), a
   6081 DD 7E FF      [19]   90 	ld	a, -1 (ix)
   6084 CE 00         [ 7]   91 	adc	a, #0x00
   6086 DD 77 FB      [19]   92 	ld	-5 (ix), a
   6089 DD 7E FE      [19]   93 	ld	a, -2 (ix)
   608C C6 01         [ 7]   94 	add	a, #0x01
   608E DD 77 F3      [19]   95 	ld	-13 (ix), a
   6091 DD 7E FF      [19]   96 	ld	a, -1 (ix)
   6094 CE 00         [ 7]   97 	adc	a, #0x00
   6096 DD 77 F4      [19]   98 	ld	-12 (ix), a
                             99 ;src/render.c:18: if (sprites[i].properties & MASK_RENDER) {
   6099 CB 41         [ 8]  100 	bit	0, c
   609B CA C6 61      [10]  101 	jp	Z,00121$
                            102 ;src/render.c:33: sprite = sprites[i].sprite_f1; 
   609E DD 7E FE      [19]  103 	ld	a, -2 (ix)
   60A1 C6 0F         [ 7]  104 	add	a, #0x0f
   60A3 DD 77 F5      [19]  105 	ld	-11 (ix), a
   60A6 DD 7E FF      [19]  106 	ld	a, -1 (ix)
   60A9 CE 00         [ 7]  107 	adc	a, #0x00
   60AB DD 77 F6      [19]  108 	ld	-10 (ix), a
                            109 ;src/render.c:20: if (sprites[i].properties & MASK_ANIMATE) {
   60AE CB 49         [ 8]  110 	bit	1, c
   60B0 28 55         [12]  111 	jr	Z,00114$
                            112 ;src/render.c:28: if (anim_clock > 7) num_frame=2;
   60B2 3E 07         [ 7]  113 	ld	a, #0x07
   60B4 FD 21 C2 67   [14]  114 	ld	iy, #_anim_clock
   60B8 FD 96 00      [19]  115 	sub	a, 0 (iy)
   60BB 30 04         [12]  116 	jr	NC,00102$
   60BD 3E 02         [ 7]  117 	ld	a, #0x02
   60BF 18 02         [12]  118 	jr	00103$
   60C1                     119 00102$:
                            120 ;src/render.c:29: else num_frame=1;
   60C1 3E 01         [ 7]  121 	ld	a, #0x01
   60C3                     122 00103$:
                            123 ;src/render.c:32: if (num_frame == 1) {
   60C3 FE 01         [ 7]  124 	cp	a, #0x01
   60C5 20 0B         [12]  125 	jr	NZ,00111$
                            126 ;src/render.c:33: sprite = sprites[i].sprite_f1; 
   60C7 DD 6E F5      [19]  127 	ld	l,-11 (ix)
   60CA DD 66 F6      [19]  128 	ld	h,-10 (ix)
   60CD 5E            [ 7]  129 	ld	e, (hl)
   60CE 23            [ 6]  130 	inc	hl
   60CF 56            [ 7]  131 	ld	d, (hl)
   60D0 18 3E         [12]  132 	jr	00115$
   60D2                     133 00111$:
                            134 ;src/render.c:34: } else if (num_frame == 2) {
   60D2 FE 02         [ 7]  135 	cp	a, #0x02
   60D4 20 0F         [12]  136 	jr	NZ,00108$
                            137 ;src/render.c:35: sprite = sprites[i].sprite_f2;
   60D6 DD 6E FE      [19]  138 	ld	l,-2 (ix)
   60D9 DD 66 FF      [19]  139 	ld	h,-1 (ix)
   60DC 11 11 00      [10]  140 	ld	de, #0x0011
   60DF 19            [11]  141 	add	hl, de
   60E0 5E            [ 7]  142 	ld	e, (hl)
   60E1 23            [ 6]  143 	inc	hl
   60E2 56            [ 7]  144 	ld	d, (hl)
   60E3 18 2B         [12]  145 	jr	00115$
   60E5                     146 00108$:
                            147 ;src/render.c:36: } else if (num_frame == 3) { 
   60E5 D6 03         [ 7]  148 	sub	a, #0x03
   60E7 20 0F         [12]  149 	jr	NZ,00105$
                            150 ;src/render.c:37: sprite = sprites[i].sprite_f3; 
   60E9 DD 6E FE      [19]  151 	ld	l,-2 (ix)
   60EC DD 66 FF      [19]  152 	ld	h,-1 (ix)
   60EF 11 13 00      [10]  153 	ld	de, #0x0013
   60F2 19            [11]  154 	add	hl, de
   60F3 5E            [ 7]  155 	ld	e, (hl)
   60F4 23            [ 6]  156 	inc	hl
   60F5 56            [ 7]  157 	ld	d, (hl)
   60F6 18 18         [12]  158 	jr	00115$
   60F8                     159 00105$:
                            160 ;src/render.c:38: } else sprite = sprites[i].sprite_f4;
   60F8 DD 6E FE      [19]  161 	ld	l,-2 (ix)
   60FB DD 66 FF      [19]  162 	ld	h,-1 (ix)
   60FE 11 15 00      [10]  163 	ld	de, #0x0015
   6101 19            [11]  164 	add	hl, de
   6102 5E            [ 7]  165 	ld	e, (hl)
   6103 23            [ 6]  166 	inc	hl
   6104 56            [ 7]  167 	ld	d, (hl)
   6105 18 09         [12]  168 	jr	00115$
   6107                     169 00114$:
                            170 ;src/render.c:39: } else sprite = sprites[i].sprite_f1;
   6107 DD 6E F5      [19]  171 	ld	l,-11 (ix)
   610A DD 66 F6      [19]  172 	ld	h,-10 (ix)
   610D 5E            [ 7]  173 	ld	e, (hl)
   610E 23            [ 6]  174 	inc	hl
   610F 56            [ 7]  175 	ld	d, (hl)
   6110                     176 00115$:
                            177 ;src/render.c:41: if (sprites[i].turned)					//turn sprite around
   6110 DD 7E FE      [19]  178 	ld	a, -2 (ix)
   6113 C6 17         [ 7]  179 	add	a, #0x17
   6115 DD 77 F5      [19]  180 	ld	-11 (ix), a
   6118 DD 7E FF      [19]  181 	ld	a, -1 (ix)
   611B CE 00         [ 7]  182 	adc	a, #0x00
   611D DD 77 F6      [19]  183 	ld	-10 (ix), a
   6120 DD 6E F5      [19]  184 	ld	l,-11 (ix)
   6123 DD 66 F6      [19]  185 	ld	h,-10 (ix)
   6126 4E            [ 7]  186 	ld	c, (hl)
                            187 ;src/render.c:42: cpct_hflipSpriteMaskedM0(sprites[i].width, sprites[i].height, sprite);
   6127 DD 7E FE      [19]  188 	ld	a, -2 (ix)
   612A C6 09         [ 7]  189 	add	a, #0x09
   612C DD 77 FC      [19]  190 	ld	-4 (ix), a
   612F DD 7E FF      [19]  191 	ld	a, -1 (ix)
   6132 CE 00         [ 7]  192 	adc	a, #0x00
   6134 DD 77 FD      [19]  193 	ld	-3 (ix), a
   6137 DD 7E FE      [19]  194 	ld	a, -2 (ix)
   613A C6 0A         [ 7]  195 	add	a, #0x0a
   613C DD 77 F8      [19]  196 	ld	-8 (ix), a
   613F DD 7E FF      [19]  197 	ld	a, -1 (ix)
   6142 CE 00         [ 7]  198 	adc	a, #0x00
   6144 DD 77 F9      [19]  199 	ld	-7 (ix), a
                            200 ;src/render.c:41: if (sprites[i].turned)					//turn sprite around
   6147 79            [ 4]  201 	ld	a, c
   6148 B7            [ 4]  202 	or	a, a
   6149 28 18         [12]  203 	jr	Z,00117$
                            204 ;src/render.c:42: cpct_hflipSpriteMaskedM0(sprites[i].width, sprites[i].height, sprite);
   614B DD 6E FC      [19]  205 	ld	l,-4 (ix)
   614E DD 66 FD      [19]  206 	ld	h,-3 (ix)
   6151 46            [ 7]  207 	ld	b, (hl)
   6152 DD 6E F8      [19]  208 	ld	l,-8 (ix)
   6155 DD 66 F9      [19]  209 	ld	h,-7 (ix)
   6158 7E            [ 7]  210 	ld	a, (hl)
   6159 D5            [11]  211 	push	de
   615A D5            [11]  212 	push	de
   615B C5            [11]  213 	push	bc
   615C 33            [ 6]  214 	inc	sp
   615D F5            [11]  215 	push	af
   615E 33            [ 6]  216 	inc	sp
   615F CD A1 63      [17]  217 	call	_cpct_hflipSpriteMaskedM0
   6162 D1            [10]  218 	pop	de
   6163                     219 00117$:
                            220 ;src/render.c:47: sprites[i].width, sprites[i].height);
   6163 DD 6E FC      [19]  221 	ld	l,-4 (ix)
   6166 DD 66 FD      [19]  222 	ld	h,-3 (ix)
   6169 7E            [ 7]  223 	ld	a, (hl)
   616A DD 77 F7      [19]  224 	ld	-9 (ix), a
   616D DD 6E F8      [19]  225 	ld	l,-8 (ix)
   6170 DD 66 F9      [19]  226 	ld	h,-7 (ix)
   6173 7E            [ 7]  227 	ld	a, (hl)
   6174 DD 77 F2      [19]  228 	ld	-14 (ix), a
                            229 ;src/render.c:46: cpct_getScreenPtr(mem_start, sprites[i].x, sprites[i].y),
   6177 DD 6E FA      [19]  230 	ld	l,-6 (ix)
   617A DD 66 FB      [19]  231 	ld	h,-5 (ix)
   617D 4E            [ 7]  232 	ld	c, (hl)
   617E DD 6E F3      [19]  233 	ld	l,-13 (ix)
   6181 DD 66 F4      [19]  234 	ld	h,-12 (ix)
   6184 46            [ 7]  235 	ld	b, (hl)
   6185 FD 2A C3 67   [20]  236 	ld	iy, (_mem_start)
   6189 D5            [11]  237 	push	de
   618A 79            [ 4]  238 	ld	a, c
   618B F5            [11]  239 	push	af
   618C 33            [ 6]  240 	inc	sp
   618D C5            [11]  241 	push	bc
   618E 33            [ 6]  242 	inc	sp
   618F FD E5         [15]  243 	push	iy
   6191 CD AC 66      [17]  244 	call	_cpct_getScreenPtr
   6194 4D            [ 4]  245 	ld	c, l
   6195 44            [ 4]  246 	ld	b, h
   6196 D1            [10]  247 	pop	de
                            248 ;src/render.c:44: cpct_drawSpriteMasked(sprite,
   6197 D5            [11]  249 	push	de
   6198 DD 66 F7      [19]  250 	ld	h, -9 (ix)
   619B DD 6E F2      [19]  251 	ld	l, -14 (ix)
   619E E5            [11]  252 	push	hl
   619F C5            [11]  253 	push	bc
   61A0 D5            [11]  254 	push	de
   61A1 CD 41 65      [17]  255 	call	_cpct_drawSpriteMasked
   61A4 D1            [10]  256 	pop	de
                            257 ;src/render.c:49: if (sprites[i].turned)					//turn back to normal (looking right)
   61A5 DD 6E F5      [19]  258 	ld	l,-11 (ix)
   61A8 DD 66 F6      [19]  259 	ld	h,-10 (ix)
   61AB 7E            [ 7]  260 	ld	a, (hl)
   61AC B7            [ 4]  261 	or	a, a
   61AD 28 17         [12]  262 	jr	Z,00121$
                            263 ;src/render.c:50: cpct_hflipSpriteMaskedM0(sprites[i].width, sprites[i].height, sprite);
   61AF DD 6E FC      [19]  264 	ld	l,-4 (ix)
   61B2 DD 66 FD      [19]  265 	ld	h,-3 (ix)
   61B5 4E            [ 7]  266 	ld	c, (hl)
   61B6 DD 6E F8      [19]  267 	ld	l,-8 (ix)
   61B9 DD 66 F9      [19]  268 	ld	h,-7 (ix)
   61BC 46            [ 7]  269 	ld	b, (hl)
   61BD D5            [11]  270 	push	de
   61BE 79            [ 4]  271 	ld	a, c
   61BF F5            [11]  272 	push	af
   61C0 33            [ 6]  273 	inc	sp
   61C1 C5            [11]  274 	push	bc
   61C2 33            [ 6]  275 	inc	sp
   61C3 CD A1 63      [17]  276 	call	_cpct_hflipSpriteMaskedM0
   61C6                     277 00121$:
                            278 ;src/render.c:46: cpct_getScreenPtr(mem_start, sprites[i].x, sprites[i].y),
   61C6 DD 6E F3      [19]  279 	ld	l,-13 (ix)
   61C9 DD 66 F4      [19]  280 	ld	h,-12 (ix)
   61CC 4E            [ 7]  281 	ld	c, (hl)
                            282 ;src/render.c:55: if (!swap_memvideo) {
   61CD 3A C6 67      [13]  283 	ld	a,(#_swap_memvideo + 0)
   61D0 B7            [ 4]  284 	or	a, a
   61D1 20 23         [12]  285 	jr	NZ,00123$
                            286 ;src/render.c:56: sprites[i].x_prev_B = sprites[i].x;
   61D3 DD 7E FE      [19]  287 	ld	a, -2 (ix)
   61D6 C6 07         [ 7]  288 	add	a, #0x07
   61D8 6F            [ 4]  289 	ld	l, a
   61D9 DD 7E FF      [19]  290 	ld	a, -1 (ix)
   61DC CE 00         [ 7]  291 	adc	a, #0x00
   61DE 67            [ 4]  292 	ld	h, a
   61DF 71            [ 7]  293 	ld	(hl), c
                            294 ;src/render.c:57: sprites[i].y_prev_B = sprites[i].y;
   61E0 DD 7E FE      [19]  295 	ld	a, -2 (ix)
   61E3 C6 08         [ 7]  296 	add	a, #0x08
   61E5 4F            [ 4]  297 	ld	c, a
   61E6 DD 7E FF      [19]  298 	ld	a, -1 (ix)
   61E9 CE 00         [ 7]  299 	adc	a, #0x00
   61EB 47            [ 4]  300 	ld	b, a
   61EC DD 6E FA      [19]  301 	ld	l,-6 (ix)
   61EF DD 66 FB      [19]  302 	ld	h,-5 (ix)
   61F2 7E            [ 7]  303 	ld	a, (hl)
   61F3 02            [ 7]  304 	ld	(bc), a
   61F4 18 21         [12]  305 	jr	00129$
   61F6                     306 00123$:
                            307 ;src/render.c:59: sprites[i].x_prev_A = sprites[i].x;
   61F6 DD 7E FE      [19]  308 	ld	a, -2 (ix)
   61F9 C6 05         [ 7]  309 	add	a, #0x05
   61FB 6F            [ 4]  310 	ld	l, a
   61FC DD 7E FF      [19]  311 	ld	a, -1 (ix)
   61FF CE 00         [ 7]  312 	adc	a, #0x00
   6201 67            [ 4]  313 	ld	h, a
   6202 71            [ 7]  314 	ld	(hl), c
                            315 ;src/render.c:60: sprites[i].y_prev_A = sprites[i].y;
   6203 DD 7E FE      [19]  316 	ld	a, -2 (ix)
   6206 C6 06         [ 7]  317 	add	a, #0x06
   6208 4F            [ 4]  318 	ld	c, a
   6209 DD 7E FF      [19]  319 	ld	a, -1 (ix)
   620C CE 00         [ 7]  320 	adc	a, #0x00
   620E 47            [ 4]  321 	ld	b, a
   620F DD 6E FA      [19]  322 	ld	l,-6 (ix)
   6212 DD 66 FB      [19]  323 	ld	h,-5 (ix)
   6215 7E            [ 7]  324 	ld	a, (hl)
   6216 02            [ 7]  325 	ld	(bc), a
   6217                     326 00129$:
                            327 ;src/render.c:16: for (i = 0; i < MAX_SPRITES; i++) {
   6217 DD 34 F1      [23]  328 	inc	-15 (ix)
   621A DD 7E F1      [19]  329 	ld	a, -15 (ix)
   621D D6 0A         [ 7]  330 	sub	a, #0x0a
   621F DA 53 60      [10]  331 	jp	C, 00128$
   6222 DD F9         [10]  332 	ld	sp, ix
   6224 DD E1         [14]  333 	pop	ix
   6226 C9            [10]  334 	ret
                            335 ;src/render.c:66: void deleteSprites(){
                            336 ;	---------------------------------
                            337 ; Function deleteSprites
                            338 ; ---------------------------------
   6227                     339 _deleteSprites::
   6227 DD E5         [15]  340 	push	ix
   6229 DD 21 00 00   [14]  341 	ld	ix,#0
   622D DD 39         [15]  342 	add	ix,sp
   622F 21 F5 FF      [10]  343 	ld	hl, #-11
   6232 39            [11]  344 	add	hl, sp
   6233 F9            [ 6]  345 	ld	sp, hl
                            346 ;src/render.c:71: for (i = 0; i < MAX_SPRITES; i++) {
   6234 DD 36 F5 00   [19]  347 	ld	-11 (ix), #0x00
   6238                     348 00107$:
                            349 ;src/render.c:72: if (sprites[i].id !=0) {
   6238 DD 4E F5      [19]  350 	ld	c,-11 (ix)
   623B 06 00         [ 7]  351 	ld	b,#0x00
   623D 69            [ 4]  352 	ld	l, c
   623E 60            [ 4]  353 	ld	h, b
   623F 29            [11]  354 	add	hl, hl
   6240 09            [11]  355 	add	hl, bc
   6241 29            [11]  356 	add	hl, hl
   6242 29            [11]  357 	add	hl, hl
   6243 29            [11]  358 	add	hl, hl
   6244 01 D2 66      [10]  359 	ld	bc,#_sprites
   6247 09            [11]  360 	add	hl,bc
   6248 DD 75 F6      [19]  361 	ld	-10 (ix), l
   624B DD 74 F7      [19]  362 	ld	-9 (ix), h
   624E 7E            [ 7]  363 	ld	a, (hl)
   624F DD 77 FF      [19]  364 	ld	-1 (ix), a
   6252 B7            [ 4]  365 	or	a, a
   6253 CA 04 63      [10]  366 	jp	Z, 00108$
                            367 ;src/render.c:73: if (!swap_memvideo){
   6256 3A C6 67      [13]  368 	ld	a,(#_swap_memvideo + 0)
   6259 B7            [ 4]  369 	or	a, a
   625A 20 1E         [12]  370 	jr	NZ,00102$
                            371 ;src/render.c:74: x = sprites[i].x_prev_B;
   625C DD 6E F6      [19]  372 	ld	l,-10 (ix)
   625F DD 66 F7      [19]  373 	ld	h,-9 (ix)
   6262 11 07 00      [10]  374 	ld	de, #0x0007
   6265 19            [11]  375 	add	hl, de
   6266 7E            [ 7]  376 	ld	a, (hl)
   6267 DD 77 FF      [19]  377 	ld	-1 (ix), a
                            378 ;src/render.c:75: y = sprites[i].y_prev_B;
   626A DD 6E F6      [19]  379 	ld	l,-10 (ix)
   626D DD 66 F7      [19]  380 	ld	h,-9 (ix)
   6270 11 08 00      [10]  381 	ld	de, #0x0008
   6273 19            [11]  382 	add	hl, de
   6274 7E            [ 7]  383 	ld	a, (hl)
   6275 DD 77 FE      [19]  384 	ld	-2 (ix), a
   6278 18 1C         [12]  385 	jr	00103$
   627A                     386 00102$:
                            387 ;src/render.c:78: x = sprites[i].x_prev_A;
   627A DD 6E F6      [19]  388 	ld	l,-10 (ix)
   627D DD 66 F7      [19]  389 	ld	h,-9 (ix)
   6280 11 05 00      [10]  390 	ld	de, #0x0005
   6283 19            [11]  391 	add	hl, de
   6284 7E            [ 7]  392 	ld	a, (hl)
   6285 DD 77 FF      [19]  393 	ld	-1 (ix), a
                            394 ;src/render.c:79: y = sprites[i].y_prev_A;
   6288 DD 6E F6      [19]  395 	ld	l,-10 (ix)
   628B DD 66 F7      [19]  396 	ld	h,-9 (ix)
   628E 11 06 00      [10]  397 	ld	de, #0x0006
   6291 19            [11]  398 	add	hl, de
   6292 7E            [ 7]  399 	ld	a, (hl)
   6293 DD 77 FE      [19]  400 	ld	-2 (ix), a
   6296                     401 00103$:
                            402 ;src/render.c:84: sprites[i].width, sprites[i].height);
   6296 DD 7E F6      [19]  403 	ld	a, -10 (ix)
   6299 DD 77 FC      [19]  404 	ld	-4 (ix), a
   629C DD 7E F7      [19]  405 	ld	a, -9 (ix)
   629F DD 77 FD      [19]  406 	ld	-3 (ix), a
   62A2 DD 6E FC      [19]  407 	ld	l,-4 (ix)
   62A5 DD 66 FD      [19]  408 	ld	h,-3 (ix)
   62A8 11 09 00      [10]  409 	ld	de, #0x0009
   62AB 19            [11]  410 	add	hl, de
   62AC 7E            [ 7]  411 	ld	a, (hl)
   62AD DD 77 FC      [19]  412 	ld	-4 (ix), a
   62B0 DD 6E F6      [19]  413 	ld	l,-10 (ix)
   62B3 DD 66 F7      [19]  414 	ld	h,-9 (ix)
   62B6 11 0A 00      [10]  415 	ld	de, #0x000a
   62B9 19            [11]  416 	add	hl, de
   62BA 7E            [ 7]  417 	ld	a, (hl)
   62BB DD 77 F6      [19]  418 	ld	-10 (ix), a
                            419 ;src/render.c:83: cpct_px2byteM0(5,5),						//background color
   62BE 21 05 05      [10]  420 	ld	hl, #0x0505
   62C1 E5            [11]  421 	push	hl
   62C2 CD A5 65      [17]  422 	call	_cpct_px2byteM0
   62C5 DD 75 FA      [19]  423 	ld	-6 (ix), l
   62C8 DD 36 FB 00   [19]  424 	ld	-5 (ix), #0x00
                            425 ;src/render.c:82: cpct_getScreenPtr(mem_start, x, y),
   62CC 2A C3 67      [16]  426 	ld	hl, (_mem_start)
   62CF DD 75 F8      [19]  427 	ld	-8 (ix), l
   62D2 DD 74 F9      [19]  428 	ld	-7 (ix), h
   62D5 DD 66 FE      [19]  429 	ld	h, -2 (ix)
   62D8 DD 6E FF      [19]  430 	ld	l, -1 (ix)
   62DB E5            [11]  431 	push	hl
   62DC DD 6E F8      [19]  432 	ld	l,-8 (ix)
   62DF DD 66 F9      [19]  433 	ld	h,-7 (ix)
   62E2 E5            [11]  434 	push	hl
   62E3 CD AC 66      [17]  435 	call	_cpct_getScreenPtr
   62E6 DD 74 F9      [19]  436 	ld	-7 (ix), h
   62E9 DD 75 F8      [19]  437 	ld	-8 (ix), l
   62EC DD 66 FC      [19]  438 	ld	h, -4 (ix)
   62EF DD 6E F6      [19]  439 	ld	l, -10 (ix)
   62F2 E5            [11]  440 	push	hl
   62F3 DD 6E FA      [19]  441 	ld	l,-6 (ix)
   62F6 DD 66 FB      [19]  442 	ld	h,-5 (ix)
   62F9 E5            [11]  443 	push	hl
   62FA DD 6E F8      [19]  444 	ld	l,-8 (ix)
   62FD DD 66 F9      [19]  445 	ld	h,-7 (ix)
   6300 E5            [11]  446 	push	hl
   6301 CD DF 65      [17]  447 	call	_cpct_drawSolidBox
   6304                     448 00108$:
                            449 ;src/render.c:71: for (i = 0; i < MAX_SPRITES; i++) {
   6304 DD 34 F5      [23]  450 	inc	-11 (ix)
   6307 DD 7E F5      [19]  451 	ld	a, -11 (ix)
   630A D6 0A         [ 7]  452 	sub	a, #0x0a
   630C DA 38 62      [10]  453 	jp	C, 00107$
   630F DD F9         [10]  454 	ld	sp, ix
   6311 DD E1         [14]  455 	pop	ix
   6313 C9            [10]  456 	ret
                            457 	.area _CODE
                            458 	.area _INITIALIZER
                            459 	.area _CABS (ABS)
