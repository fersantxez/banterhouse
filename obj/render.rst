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
   6051                      52 _renderSprites::
   6051 DD E5         [15]   53 	push	ix
   6053 DD 21 00 00   [14]   54 	ld	ix,#0
   6057 DD 39         [15]   55 	add	ix,sp
   6059 21 F6 FF      [10]   56 	ld	hl, #-10
   605C 39            [11]   57 	add	hl, sp
   605D F9            [ 6]   58 	ld	sp, hl
                             59 ;src/render.c:16: for (i = 0; i < MAX_SPRITES; i++) {
   605E DD 36 F6 00   [19]   60 	ld	-10 (ix), #0x00
   6062                      61 00126$:
                             62 ;src/render.c:17: if (sprites[i].id !=0) {						//only live and renderable sprites
   6062 DD 4E F6      [19]   63 	ld	c,-10 (ix)
   6065 06 00         [ 7]   64 	ld	b,#0x00
   6067 69            [ 4]   65 	ld	l, c
   6068 60            [ 4]   66 	ld	h, b
   6069 29            [11]   67 	add	hl, hl
   606A 09            [11]   68 	add	hl, bc
   606B 29            [11]   69 	add	hl, hl
   606C 29            [11]   70 	add	hl, hl
   606D 29            [11]   71 	add	hl, hl
   606E 01 3A 66      [10]   72 	ld	bc,#_sprites
   6071 09            [11]   73 	add	hl,bc
   6072 DD 75 F8      [19]   74 	ld	-8 (ix), l
   6075 DD 74 F9      [19]   75 	ld	-7 (ix), h
   6078 7E            [ 7]   76 	ld	a, (hl)
   6079 B7            [ 4]   77 	or	a, a
   607A CA BD 61      [10]   78 	jp	Z, 00127$
                             79 ;src/render.c:18: if (sprites[i].properties & MASK_RENDER) {
   607D C1            [10]   80 	pop	bc
   607E E1            [10]   81 	pop	hl
   607F E5            [11]   82 	push	hl
   6080 C5            [11]   83 	push	bc
   6081 11 0B 00      [10]   84 	ld	de, #0x000b
   6084 19            [11]   85 	add	hl, de
   6085 4E            [ 7]   86 	ld	c, (hl)
                             87 ;src/render.c:47: cpct_getScreenPtr(mem_start, sprites[i].x, sprites[i].y),
   6086 DD 7E F8      [19]   88 	ld	a, -8 (ix)
   6089 C6 02         [ 7]   89 	add	a, #0x02
   608B DD 77 FA      [19]   90 	ld	-6 (ix), a
   608E DD 7E F9      [19]   91 	ld	a, -7 (ix)
   6091 CE 00         [ 7]   92 	adc	a, #0x00
   6093 DD 77 FB      [19]   93 	ld	-5 (ix), a
   6096 DD 7E F8      [19]   94 	ld	a, -8 (ix)
   6099 C6 01         [ 7]   95 	add	a, #0x01
   609B DD 77 FE      [19]   96 	ld	-2 (ix), a
   609E DD 7E F9      [19]   97 	ld	a, -7 (ix)
   60A1 CE 00         [ 7]   98 	adc	a, #0x00
   60A3 DD 77 FF      [19]   99 	ld	-1 (ix), a
                            100 ;src/render.c:18: if (sprites[i].properties & MASK_RENDER) {
   60A6 CB 41         [ 8]  101 	bit	0, c
   60A8 CA 6C 61      [10]  102 	jp	Z,00119$
                            103 ;src/render.c:33: sprite = sprites[i].sprite_f1; 
   60AB DD 7E F8      [19]  104 	ld	a, -8 (ix)
   60AE C6 0F         [ 7]  105 	add	a, #0x0f
   60B0 DD 77 FC      [19]  106 	ld	-4 (ix), a
   60B3 DD 7E F9      [19]  107 	ld	a, -7 (ix)
   60B6 CE 00         [ 7]  108 	adc	a, #0x00
   60B8 DD 77 FD      [19]  109 	ld	-3 (ix), a
                            110 ;src/render.c:20: if (sprites[i].properties & MASK_ANIMATE) {
   60BB CB 49         [ 8]  111 	bit	1, c
   60BD 28 4F         [12]  112 	jr	Z,00114$
                            113 ;src/render.c:28: if (anim_clock > 7) num_frame=2;
   60BF 3E 07         [ 7]  114 	ld	a, #0x07
   60C1 FD 21 2A 67   [14]  115 	ld	iy, #_anim_clock
   60C5 FD 96 00      [19]  116 	sub	a, 0 (iy)
   60C8 30 04         [12]  117 	jr	NC,00102$
   60CA 3E 02         [ 7]  118 	ld	a, #0x02
   60CC 18 02         [12]  119 	jr	00103$
   60CE                     120 00102$:
                            121 ;src/render.c:29: else num_frame=1;
   60CE 3E 01         [ 7]  122 	ld	a, #0x01
   60D0                     123 00103$:
                            124 ;src/render.c:32: if (num_frame == 1) {
   60D0 FE 01         [ 7]  125 	cp	a, #0x01
   60D2 20 0B         [12]  126 	jr	NZ,00111$
                            127 ;src/render.c:33: sprite = sprites[i].sprite_f1; 
   60D4 DD 6E FC      [19]  128 	ld	l,-4 (ix)
   60D7 DD 66 FD      [19]  129 	ld	h,-3 (ix)
   60DA 4E            [ 7]  130 	ld	c, (hl)
   60DB 23            [ 6]  131 	inc	hl
   60DC 46            [ 7]  132 	ld	b, (hl)
   60DD 18 38         [12]  133 	jr	00115$
   60DF                     134 00111$:
                            135 ;src/render.c:34: } else if (num_frame == 2) {
   60DF FE 02         [ 7]  136 	cp	a, #0x02
   60E1 20 0D         [12]  137 	jr	NZ,00108$
                            138 ;src/render.c:35: sprite = sprites[i].sprite_f2;
   60E3 C1            [10]  139 	pop	bc
   60E4 E1            [10]  140 	pop	hl
   60E5 E5            [11]  141 	push	hl
   60E6 C5            [11]  142 	push	bc
   60E7 11 11 00      [10]  143 	ld	de, #0x0011
   60EA 19            [11]  144 	add	hl, de
   60EB 4E            [ 7]  145 	ld	c, (hl)
   60EC 23            [ 6]  146 	inc	hl
   60ED 46            [ 7]  147 	ld	b, (hl)
   60EE 18 27         [12]  148 	jr	00115$
   60F0                     149 00108$:
                            150 ;src/render.c:36: } else if (num_frame == 3) { 
   60F0 D6 03         [ 7]  151 	sub	a, #0x03
   60F2 20 0D         [12]  152 	jr	NZ,00105$
                            153 ;src/render.c:37: sprite = sprites[i].sprite_f3; 
   60F4 C1            [10]  154 	pop	bc
   60F5 E1            [10]  155 	pop	hl
   60F6 E5            [11]  156 	push	hl
   60F7 C5            [11]  157 	push	bc
   60F8 11 13 00      [10]  158 	ld	de, #0x0013
   60FB 19            [11]  159 	add	hl, de
   60FC 4E            [ 7]  160 	ld	c, (hl)
   60FD 23            [ 6]  161 	inc	hl
   60FE 46            [ 7]  162 	ld	b, (hl)
   60FF 18 16         [12]  163 	jr	00115$
   6101                     164 00105$:
                            165 ;src/render.c:38: } else sprite = sprites[i].sprite_f4;
   6101 C1            [10]  166 	pop	bc
   6102 E1            [10]  167 	pop	hl
   6103 E5            [11]  168 	push	hl
   6104 C5            [11]  169 	push	bc
   6105 11 15 00      [10]  170 	ld	de, #0x0015
   6108 19            [11]  171 	add	hl, de
   6109 4E            [ 7]  172 	ld	c, (hl)
   610A 23            [ 6]  173 	inc	hl
   610B 46            [ 7]  174 	ld	b, (hl)
   610C 18 09         [12]  175 	jr	00115$
   610E                     176 00114$:
                            177 ;src/render.c:39: } else sprite = sprites[i].sprite_f1;
   610E DD 6E FC      [19]  178 	ld	l,-4 (ix)
   6111 DD 66 FD      [19]  179 	ld	h,-3 (ix)
   6114 4E            [ 7]  180 	ld	c, (hl)
   6115 23            [ 6]  181 	inc	hl
   6116 46            [ 7]  182 	ld	b, (hl)
   6117                     183 00115$:
                            184 ;src/render.c:41: if (sprites[i].turned)							//turn sprite around
   6117 D1            [10]  185 	pop	de
   6118 E1            [10]  186 	pop	hl
   6119 E5            [11]  187 	push	hl
   611A D5            [11]  188 	push	de
   611B 11 17 00      [10]  189 	ld	de, #0x0017
   611E 19            [11]  190 	add	hl, de
   611F 7E            [ 7]  191 	ld	a, (hl)
   6120 B7            [ 4]  192 	or	a, a
   6121 28 06         [12]  193 	jr	Z,00117$
                            194 ;src/render.c:43: sprite = sprite + ((G_PITU_W*2)*G_PITU_H);	//find next sprite in memory, "rev" version
   6123 21 C0 01      [10]  195 	ld	hl, #0x01c0
   6126 09            [11]  196 	add	hl,bc
   6127 4D            [ 4]  197 	ld	c, l
   6128 44            [ 4]  198 	ld	b, h
   6129                     199 00117$:
                            200 ;src/render.c:48: sprites[i].width, sprites[i].height);
   6129 D1            [10]  201 	pop	de
   612A E1            [10]  202 	pop	hl
   612B E5            [11]  203 	push	hl
   612C D5            [11]  204 	push	de
   612D 11 09 00      [10]  205 	ld	de, #0x0009
   6130 19            [11]  206 	add	hl, de
   6131 7E            [ 7]  207 	ld	a, (hl)
   6132 DD 77 FC      [19]  208 	ld	-4 (ix), a
   6135 D1            [10]  209 	pop	de
   6136 E1            [10]  210 	pop	hl
   6137 E5            [11]  211 	push	hl
   6138 D5            [11]  212 	push	de
   6139 11 0A 00      [10]  213 	ld	de, #0x000a
   613C 19            [11]  214 	add	hl, de
   613D 7E            [ 7]  215 	ld	a, (hl)
   613E DD 77 F7      [19]  216 	ld	-9 (ix), a
                            217 ;src/render.c:47: cpct_getScreenPtr(mem_start, sprites[i].x, sprites[i].y),
   6141 DD 6E FA      [19]  218 	ld	l,-6 (ix)
   6144 DD 66 FB      [19]  219 	ld	h,-5 (ix)
   6147 5E            [ 7]  220 	ld	e, (hl)
   6148 DD 6E FE      [19]  221 	ld	l,-2 (ix)
   614B DD 66 FF      [19]  222 	ld	h,-1 (ix)
   614E 56            [ 7]  223 	ld	d, (hl)
   614F FD 2A 2B 67   [20]  224 	ld	iy, (_mem_start)
   6153 C5            [11]  225 	push	bc
   6154 7B            [ 4]  226 	ld	a, e
   6155 F5            [11]  227 	push	af
   6156 33            [ 6]  228 	inc	sp
   6157 D5            [11]  229 	push	de
   6158 33            [ 6]  230 	inc	sp
   6159 FD E5         [15]  231 	push	iy
   615B CD 14 66      [17]  232 	call	_cpct_getScreenPtr
   615E EB            [ 4]  233 	ex	de,hl
   615F C1            [10]  234 	pop	bc
                            235 ;src/render.c:45: cpct_drawSpriteMasked(sprite,
   6160 DD 66 FC      [19]  236 	ld	h, -4 (ix)
   6163 DD 6E F7      [19]  237 	ld	l, -9 (ix)
   6166 E5            [11]  238 	push	hl
   6167 D5            [11]  239 	push	de
   6168 C5            [11]  240 	push	bc
   6169 CD A9 64      [17]  241 	call	_cpct_drawSpriteMasked
   616C                     242 00119$:
                            243 ;src/render.c:47: cpct_getScreenPtr(mem_start, sprites[i].x, sprites[i].y),
   616C DD 6E FE      [19]  244 	ld	l,-2 (ix)
   616F DD 66 FF      [19]  245 	ld	h,-1 (ix)
   6172 4E            [ 7]  246 	ld	c, (hl)
                            247 ;src/render.c:53: if (!swap_memvideo) {
   6173 3A 2E 67      [13]  248 	ld	a,(#_swap_memvideo + 0)
   6176 B7            [ 4]  249 	or	a, a
   6177 20 23         [12]  250 	jr	NZ,00121$
                            251 ;src/render.c:54: sprites[i].x_prev_B = sprites[i].x;
   6179 DD 7E F8      [19]  252 	ld	a, -8 (ix)
   617C C6 07         [ 7]  253 	add	a, #0x07
   617E 6F            [ 4]  254 	ld	l, a
   617F DD 7E F9      [19]  255 	ld	a, -7 (ix)
   6182 CE 00         [ 7]  256 	adc	a, #0x00
   6184 67            [ 4]  257 	ld	h, a
   6185 71            [ 7]  258 	ld	(hl), c
                            259 ;src/render.c:55: sprites[i].y_prev_B = sprites[i].y;
   6186 DD 7E F8      [19]  260 	ld	a, -8 (ix)
   6189 C6 08         [ 7]  261 	add	a, #0x08
   618B 4F            [ 4]  262 	ld	c, a
   618C DD 7E F9      [19]  263 	ld	a, -7 (ix)
   618F CE 00         [ 7]  264 	adc	a, #0x00
   6191 47            [ 4]  265 	ld	b, a
   6192 DD 6E FA      [19]  266 	ld	l,-6 (ix)
   6195 DD 66 FB      [19]  267 	ld	h,-5 (ix)
   6198 7E            [ 7]  268 	ld	a, (hl)
   6199 02            [ 7]  269 	ld	(bc), a
   619A 18 21         [12]  270 	jr	00127$
   619C                     271 00121$:
                            272 ;src/render.c:57: sprites[i].x_prev_A = sprites[i].x;
   619C DD 7E F8      [19]  273 	ld	a, -8 (ix)
   619F C6 05         [ 7]  274 	add	a, #0x05
   61A1 6F            [ 4]  275 	ld	l, a
   61A2 DD 7E F9      [19]  276 	ld	a, -7 (ix)
   61A5 CE 00         [ 7]  277 	adc	a, #0x00
   61A7 67            [ 4]  278 	ld	h, a
   61A8 71            [ 7]  279 	ld	(hl), c
                            280 ;src/render.c:58: sprites[i].y_prev_A = sprites[i].y;
   61A9 DD 7E F8      [19]  281 	ld	a, -8 (ix)
   61AC C6 06         [ 7]  282 	add	a, #0x06
   61AE 4F            [ 4]  283 	ld	c, a
   61AF DD 7E F9      [19]  284 	ld	a, -7 (ix)
   61B2 CE 00         [ 7]  285 	adc	a, #0x00
   61B4 47            [ 4]  286 	ld	b, a
   61B5 DD 6E FA      [19]  287 	ld	l,-6 (ix)
   61B8 DD 66 FB      [19]  288 	ld	h,-5 (ix)
   61BB 7E            [ 7]  289 	ld	a, (hl)
   61BC 02            [ 7]  290 	ld	(bc), a
   61BD                     291 00127$:
                            292 ;src/render.c:16: for (i = 0; i < MAX_SPRITES; i++) {
   61BD DD 34 F6      [23]  293 	inc	-10 (ix)
   61C0 DD 7E F6      [19]  294 	ld	a, -10 (ix)
   61C3 D6 0A         [ 7]  295 	sub	a, #0x0a
   61C5 DA 62 60      [10]  296 	jp	C, 00126$
   61C8 DD F9         [10]  297 	ld	sp, ix
   61CA DD E1         [14]  298 	pop	ix
   61CC C9            [10]  299 	ret
                            300 ;src/render.c:64: void deleteSprites(){
                            301 ;	---------------------------------
                            302 ; Function deleteSprites
                            303 ; ---------------------------------
   61CD                     304 _deleteSprites::
   61CD DD E5         [15]  305 	push	ix
   61CF DD 21 00 00   [14]  306 	ld	ix,#0
   61D3 DD 39         [15]  307 	add	ix,sp
   61D5 21 F5 FF      [10]  308 	ld	hl, #-11
   61D8 39            [11]  309 	add	hl, sp
   61D9 F9            [ 6]  310 	ld	sp, hl
                            311 ;src/render.c:69: for (i = 0; i < MAX_SPRITES; i++) {
   61DA DD 36 F5 00   [19]  312 	ld	-11 (ix), #0x00
   61DE                     313 00107$:
                            314 ;src/render.c:70: if (sprites[i].id !=0) {
   61DE DD 4E F5      [19]  315 	ld	c,-11 (ix)
   61E1 06 00         [ 7]  316 	ld	b,#0x00
   61E3 69            [ 4]  317 	ld	l, c
   61E4 60            [ 4]  318 	ld	h, b
   61E5 29            [11]  319 	add	hl, hl
   61E6 09            [11]  320 	add	hl, bc
   61E7 29            [11]  321 	add	hl, hl
   61E8 29            [11]  322 	add	hl, hl
   61E9 29            [11]  323 	add	hl, hl
   61EA 01 3A 66      [10]  324 	ld	bc,#_sprites
   61ED 09            [11]  325 	add	hl,bc
   61EE DD 75 FD      [19]  326 	ld	-3 (ix), l
   61F1 DD 74 FE      [19]  327 	ld	-2 (ix), h
   61F4 7E            [ 7]  328 	ld	a, (hl)
   61F5 DD 77 FF      [19]  329 	ld	-1 (ix), a
   61F8 B7            [ 4]  330 	or	a, a
   61F9 CA AA 62      [10]  331 	jp	Z, 00108$
                            332 ;src/render.c:71: if (!swap_memvideo){
   61FC 3A 2E 67      [13]  333 	ld	a,(#_swap_memvideo + 0)
   61FF B7            [ 4]  334 	or	a, a
   6200 20 1E         [12]  335 	jr	NZ,00102$
                            336 ;src/render.c:72: x = sprites[i].x_prev_B;
   6202 DD 6E FD      [19]  337 	ld	l,-3 (ix)
   6205 DD 66 FE      [19]  338 	ld	h,-2 (ix)
   6208 11 07 00      [10]  339 	ld	de, #0x0007
   620B 19            [11]  340 	add	hl, de
   620C 7E            [ 7]  341 	ld	a, (hl)
   620D DD 77 FF      [19]  342 	ld	-1 (ix), a
                            343 ;src/render.c:73: y = sprites[i].y_prev_B;
   6210 DD 6E FD      [19]  344 	ld	l,-3 (ix)
   6213 DD 66 FE      [19]  345 	ld	h,-2 (ix)
   6216 11 08 00      [10]  346 	ld	de, #0x0008
   6219 19            [11]  347 	add	hl, de
   621A 7E            [ 7]  348 	ld	a, (hl)
   621B DD 77 FC      [19]  349 	ld	-4 (ix), a
   621E 18 1C         [12]  350 	jr	00103$
   6220                     351 00102$:
                            352 ;src/render.c:76: x = sprites[i].x_prev_A;
   6220 DD 6E FD      [19]  353 	ld	l,-3 (ix)
   6223 DD 66 FE      [19]  354 	ld	h,-2 (ix)
   6226 11 05 00      [10]  355 	ld	de, #0x0005
   6229 19            [11]  356 	add	hl, de
   622A 7E            [ 7]  357 	ld	a, (hl)
   622B DD 77 FF      [19]  358 	ld	-1 (ix), a
                            359 ;src/render.c:77: y = sprites[i].y_prev_A;
   622E DD 6E FD      [19]  360 	ld	l,-3 (ix)
   6231 DD 66 FE      [19]  361 	ld	h,-2 (ix)
   6234 11 06 00      [10]  362 	ld	de, #0x0006
   6237 19            [11]  363 	add	hl, de
   6238 7E            [ 7]  364 	ld	a, (hl)
   6239 DD 77 FC      [19]  365 	ld	-4 (ix), a
   623C                     366 00103$:
                            367 ;src/render.c:82: sprites[i].width, sprites[i].height);
   623C DD 7E FD      [19]  368 	ld	a, -3 (ix)
   623F DD 77 FA      [19]  369 	ld	-6 (ix), a
   6242 DD 7E FE      [19]  370 	ld	a, -2 (ix)
   6245 DD 77 FB      [19]  371 	ld	-5 (ix), a
   6248 DD 6E FA      [19]  372 	ld	l,-6 (ix)
   624B DD 66 FB      [19]  373 	ld	h,-5 (ix)
   624E 11 09 00      [10]  374 	ld	de, #0x0009
   6251 19            [11]  375 	add	hl, de
   6252 7E            [ 7]  376 	ld	a, (hl)
   6253 DD 77 FA      [19]  377 	ld	-6 (ix), a
   6256 DD 6E FD      [19]  378 	ld	l,-3 (ix)
   6259 DD 66 FE      [19]  379 	ld	h,-2 (ix)
   625C 11 0A 00      [10]  380 	ld	de, #0x000a
   625F 19            [11]  381 	add	hl, de
   6260 7E            [ 7]  382 	ld	a, (hl)
   6261 DD 77 FD      [19]  383 	ld	-3 (ix), a
                            384 ;src/render.c:81: cpct_px2byteM0(5,5),						//background color
   6264 21 05 05      [10]  385 	ld	hl, #0x0505
   6267 E5            [11]  386 	push	hl
   6268 CD 0D 65      [17]  387 	call	_cpct_px2byteM0
   626B DD 75 F8      [19]  388 	ld	-8 (ix), l
   626E DD 36 F9 00   [19]  389 	ld	-7 (ix), #0x00
                            390 ;src/render.c:80: cpct_getScreenPtr(mem_start, x, y),
   6272 2A 2B 67      [16]  391 	ld	hl, (_mem_start)
   6275 DD 75 F6      [19]  392 	ld	-10 (ix), l
   6278 DD 74 F7      [19]  393 	ld	-9 (ix), h
   627B DD 66 FC      [19]  394 	ld	h, -4 (ix)
   627E DD 6E FF      [19]  395 	ld	l, -1 (ix)
   6281 E5            [11]  396 	push	hl
   6282 DD 6E F6      [19]  397 	ld	l,-10 (ix)
   6285 DD 66 F7      [19]  398 	ld	h,-9 (ix)
   6288 E5            [11]  399 	push	hl
   6289 CD 14 66      [17]  400 	call	_cpct_getScreenPtr
   628C DD 74 F7      [19]  401 	ld	-9 (ix), h
   628F DD 75 F6      [19]  402 	ld	-10 (ix), l
   6292 DD 66 FA      [19]  403 	ld	h, -6 (ix)
   6295 DD 6E FD      [19]  404 	ld	l, -3 (ix)
   6298 E5            [11]  405 	push	hl
   6299 DD 6E F8      [19]  406 	ld	l,-8 (ix)
   629C DD 66 F9      [19]  407 	ld	h,-7 (ix)
   629F E5            [11]  408 	push	hl
   62A0 DD 6E F6      [19]  409 	ld	l,-10 (ix)
   62A3 DD 66 F7      [19]  410 	ld	h,-9 (ix)
   62A6 E5            [11]  411 	push	hl
   62A7 CD 47 65      [17]  412 	call	_cpct_drawSolidBox
   62AA                     413 00108$:
                            414 ;src/render.c:69: for (i = 0; i < MAX_SPRITES; i++) {
   62AA DD 34 F5      [23]  415 	inc	-11 (ix)
   62AD DD 7E F5      [19]  416 	ld	a, -11 (ix)
   62B0 D6 0A         [ 7]  417 	sub	a, #0x0a
   62B2 DA DE 61      [10]  418 	jp	C, 00107$
   62B5 DD F9         [10]  419 	ld	sp, ix
   62B7 DD E1         [14]  420 	pop	ix
   62B9 C9            [10]  421 	ret
                            422 	.area _CODE
                            423 	.area _INITIALIZER
                            424 	.area _CABS (ABS)
