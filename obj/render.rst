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
                             48 ;src/render.c:9: void renderSprites(){
                             49 ;	---------------------------------
                             50 ; Function renderSprites
                             51 ; ---------------------------------
   58A1                      52 _renderSprites::
   58A1 DD E5         [15]   53 	push	ix
   58A3 DD 21 00 00   [14]   54 	ld	ix,#0
   58A7 DD 39         [15]   55 	add	ix,sp
   58A9 21 F5 FF      [10]   56 	ld	hl, #-11
   58AC 39            [11]   57 	add	hl, sp
   58AD F9            [ 6]   58 	ld	sp, hl
                             59 ;src/render.c:14: for (i = 0; i < MAX_SPRITES; i++) {
   58AE 06 00         [ 7]   60 	ld	b, #0x00
   58B0                      61 00109$:
                             62 ;src/render.c:15: if (sprites[i].id !=0) {						//only live and renderable sprites
   58B0 58            [ 4]   63 	ld	e,b
   58B1 16 00         [ 7]   64 	ld	d,#0x00
   58B3 6B            [ 4]   65 	ld	l, e
   58B4 62            [ 4]   66 	ld	h, d
   58B5 29            [11]   67 	add	hl, hl
   58B6 29            [11]   68 	add	hl, hl
   58B7 19            [11]   69 	add	hl, de
   58B8 29            [11]   70 	add	hl, hl
   58B9 19            [11]   71 	add	hl, de
   58BA 29            [11]   72 	add	hl, hl
   58BB EB            [ 4]   73 	ex	de,hl
   58BC 21 FB 5D      [10]   74 	ld	hl, #_sprites
   58BF 19            [11]   75 	add	hl,de
   58C0 EB            [ 4]   76 	ex	de,hl
   58C1 1A            [ 7]   77 	ld	a, (de)
   58C2 B7            [ 4]   78 	or	a, a
   58C3 CA 80 59      [10]   79 	jp	Z, 00110$
                             80 ;src/render.c:16: if (sprites[i].properties & MASK_RENDER){
   58C6 D5            [11]   81 	push	de
   58C7 FD E1         [14]   82 	pop	iy
   58C9 FD 4E 0B      [19]   83 	ld	c, 11 (iy)
                             84 ;src/render.c:22: cpct_getScreenPtr(mem_start, sprites[i].x, sprites[i].y),
   58CC 21 02 00      [10]   85 	ld	hl, #0x0002
   58CF 19            [11]   86 	add	hl,de
   58D0 DD 75 F9      [19]   87 	ld	-7 (ix), l
   58D3 DD 74 FA      [19]   88 	ld	-6 (ix), h
   58D6 21 01 00      [10]   89 	ld	hl, #0x0001
   58D9 19            [11]   90 	add	hl,de
   58DA DD 75 FB      [19]   91 	ld	-5 (ix), l
   58DD DD 74 FC      [19]   92 	ld	-4 (ix), h
                             93 ;src/render.c:16: if (sprites[i].properties & MASK_RENDER){
   58E0 CB 41         [ 8]   94 	bit	0, c
   58E2 28 69         [12]   95 	jr	Z,00102$
                             96 ;src/render.c:17: sprite = sprites[i].sprite_f1;
   58E4 D5            [11]   97 	push	de
   58E5 FD E1         [14]   98 	pop	iy
   58E7 FD 7E 0E      [19]   99 	ld	a, 14 (iy)
   58EA DD 77 F5      [19]  100 	ld	-11 (ix), a
   58ED FD 7E 0F      [19]  101 	ld	a, 15 (iy)
   58F0 DD 77 F6      [19]  102 	ld	-10 (ix), a
                            103 ;src/render.c:23: sprites[i].width, sprites[i].height);
   58F3 D5            [11]  104 	push	de
   58F4 FD E1         [14]  105 	pop	iy
   58F6 FD 7E 09      [19]  106 	ld	a, 9 (iy)
   58F9 DD 77 FD      [19]  107 	ld	-3 (ix), a
   58FC D5            [11]  108 	push	de
   58FD FD E1         [14]  109 	pop	iy
   58FF FD 7E 0A      [19]  110 	ld	a, 10 (iy)
   5902 DD 77 FE      [19]  111 	ld	-2 (ix), a
                            112 ;src/render.c:22: cpct_getScreenPtr(mem_start, sprites[i].x, sprites[i].y),
   5905 DD 6E F9      [19]  113 	ld	l,-7 (ix)
   5908 DD 66 FA      [19]  114 	ld	h,-6 (ix)
   590B 7E            [ 7]  115 	ld	a, (hl)
   590C DD 77 FF      [19]  116 	ld	-1 (ix), a
   590F DD 6E FB      [19]  117 	ld	l,-5 (ix)
   5912 DD 66 FC      [19]  118 	ld	h,-4 (ix)
   5915 4E            [ 7]  119 	ld	c, (hl)
   5916 FD 2A D8 5E   [20]  120 	ld	iy, (_mem_start)
   591A C5            [11]  121 	push	bc
   591B D5            [11]  122 	push	de
   591C DD 46 FF      [19]  123 	ld	b, -1 (ix)
   591F C5            [11]  124 	push	bc
   5920 FD E5         [15]  125 	push	iy
   5922 CD D4 5D      [17]  126 	call	_cpct_getScreenPtr
   5925 D1            [10]  127 	pop	de
   5926 C1            [10]  128 	pop	bc
   5927 E5            [11]  129 	push	hl
   5928 FD E1         [14]  130 	pop	iy
                            131 ;src/render.c:19: cpct_drawSpriteMasked(sprite,
   592A DD 7E F5      [19]  132 	ld	a, -11 (ix)
   592D DD 77 F7      [19]  133 	ld	-9 (ix), a
   5930 DD 7E F6      [19]  134 	ld	a, -10 (ix)
   5933 DD 77 F8      [19]  135 	ld	-8 (ix), a
   5936 C5            [11]  136 	push	bc
   5937 D5            [11]  137 	push	de
   5938 DD 66 FD      [19]  138 	ld	h, -3 (ix)
   593B DD 6E FE      [19]  139 	ld	l, -2 (ix)
   593E E5            [11]  140 	push	hl
   593F FD E5         [15]  141 	push	iy
   5941 DD 6E F7      [19]  142 	ld	l,-9 (ix)
   5944 DD 66 F8      [19]  143 	ld	h,-8 (ix)
   5947 E5            [11]  144 	push	hl
   5948 CD 69 5C      [17]  145 	call	_cpct_drawSpriteMasked
   594B D1            [10]  146 	pop	de
   594C C1            [10]  147 	pop	bc
   594D                     148 00102$:
                            149 ;src/render.c:22: cpct_getScreenPtr(mem_start, sprites[i].x, sprites[i].y),
   594D DD 6E FB      [19]  150 	ld	l,-5 (ix)
   5950 DD 66 FC      [19]  151 	ld	h,-4 (ix)
   5953 4E            [ 7]  152 	ld	c, (hl)
                            153 ;src/render.c:27: if (!swap_memvideo) {
   5954 3A DB 5E      [13]  154 	ld	a,(#_swap_memvideo + 0)
   5957 B7            [ 4]  155 	or	a, a
   5958 20 14         [12]  156 	jr	NZ,00104$
                            157 ;src/render.c:28: sprites[i].x_prev_B = sprites[i].x;
   595A 21 07 00      [10]  158 	ld	hl, #0x0007
   595D 19            [11]  159 	add	hl, de
   595E 71            [ 7]  160 	ld	(hl), c
                            161 ;src/render.c:29: sprites[i].y_prev_B = sprites[i].y;
   595F 21 08 00      [10]  162 	ld	hl, #0x0008
   5962 19            [11]  163 	add	hl,de
   5963 EB            [ 4]  164 	ex	de,hl
   5964 DD 6E F9      [19]  165 	ld	l,-7 (ix)
   5967 DD 66 FA      [19]  166 	ld	h,-6 (ix)
   596A 7E            [ 7]  167 	ld	a, (hl)
   596B 12            [ 7]  168 	ld	(de), a
   596C 18 12         [12]  169 	jr	00110$
   596E                     170 00104$:
                            171 ;src/render.c:31: sprites[i].x_prev_A = sprites[i].x;
   596E 21 05 00      [10]  172 	ld	hl, #0x0005
   5971 19            [11]  173 	add	hl, de
   5972 71            [ 7]  174 	ld	(hl), c
                            175 ;src/render.c:32: sprites[i].y_prev_A = sprites[i].y;
   5973 21 06 00      [10]  176 	ld	hl, #0x0006
   5976 19            [11]  177 	add	hl,de
   5977 EB            [ 4]  178 	ex	de,hl
   5978 DD 6E F9      [19]  179 	ld	l,-7 (ix)
   597B DD 66 FA      [19]  180 	ld	h,-6 (ix)
   597E 7E            [ 7]  181 	ld	a, (hl)
   597F 12            [ 7]  182 	ld	(de), a
   5980                     183 00110$:
                            184 ;src/render.c:14: for (i = 0; i < MAX_SPRITES; i++) {
   5980 04            [ 4]  185 	inc	b
   5981 78            [ 4]  186 	ld	a, b
   5982 D6 0A         [ 7]  187 	sub	a, #0x0a
   5984 DA B0 58      [10]  188 	jp	C, 00109$
   5987 DD F9         [10]  189 	ld	sp, ix
   5989 DD E1         [14]  190 	pop	ix
   598B C9            [10]  191 	ret
                            192 ;src/render.c:38: void deleteSprites(){
                            193 ;	---------------------------------
                            194 ; Function deleteSprites
                            195 ; ---------------------------------
   598C                     196 _deleteSprites::
   598C DD E5         [15]  197 	push	ix
   598E DD 21 00 00   [14]  198 	ld	ix,#0
   5992 DD 39         [15]  199 	add	ix,sp
   5994 21 F5 FF      [10]  200 	ld	hl, #-11
   5997 39            [11]  201 	add	hl, sp
   5998 F9            [ 6]  202 	ld	sp, hl
                            203 ;src/render.c:43: for (i = 0; i < MAX_SPRITES; i++) {
   5999 DD 36 F5 00   [19]  204 	ld	-11 (ix), #0x00
   599D                     205 00107$:
                            206 ;src/render.c:44: if (sprites[i].id !=0) {
   599D DD 4E F5      [19]  207 	ld	c,-11 (ix)
   59A0 06 00         [ 7]  208 	ld	b,#0x00
   59A2 69            [ 4]  209 	ld	l, c
   59A3 60            [ 4]  210 	ld	h, b
   59A4 29            [11]  211 	add	hl, hl
   59A5 29            [11]  212 	add	hl, hl
   59A6 09            [11]  213 	add	hl, bc
   59A7 29            [11]  214 	add	hl, hl
   59A8 09            [11]  215 	add	hl, bc
   59A9 29            [11]  216 	add	hl, hl
   59AA 01 FB 5D      [10]  217 	ld	bc,#_sprites
   59AD 09            [11]  218 	add	hl,bc
   59AE DD 75 F6      [19]  219 	ld	-10 (ix), l
   59B1 DD 74 F7      [19]  220 	ld	-9 (ix), h
   59B4 7E            [ 7]  221 	ld	a, (hl)
   59B5 DD 77 F8      [19]  222 	ld	-8 (ix), a
   59B8 B7            [ 4]  223 	or	a, a
   59B9 CA 6A 5A      [10]  224 	jp	Z, 00108$
                            225 ;src/render.c:45: if (!swap_memvideo){
   59BC 3A DB 5E      [13]  226 	ld	a,(#_swap_memvideo + 0)
   59BF B7            [ 4]  227 	or	a, a
   59C0 20 1E         [12]  228 	jr	NZ,00102$
                            229 ;src/render.c:46: x = sprites[i].x_prev_B;
   59C2 DD 6E F6      [19]  230 	ld	l,-10 (ix)
   59C5 DD 66 F7      [19]  231 	ld	h,-9 (ix)
   59C8 11 07 00      [10]  232 	ld	de, #0x0007
   59CB 19            [11]  233 	add	hl, de
   59CC 7E            [ 7]  234 	ld	a, (hl)
   59CD DD 77 F8      [19]  235 	ld	-8 (ix), a
                            236 ;src/render.c:47: y = sprites[i].y_prev_B;
   59D0 DD 6E F6      [19]  237 	ld	l,-10 (ix)
   59D3 DD 66 F7      [19]  238 	ld	h,-9 (ix)
   59D6 11 08 00      [10]  239 	ld	de, #0x0008
   59D9 19            [11]  240 	add	hl, de
   59DA 7E            [ 7]  241 	ld	a, (hl)
   59DB DD 77 FF      [19]  242 	ld	-1 (ix), a
   59DE 18 1C         [12]  243 	jr	00103$
   59E0                     244 00102$:
                            245 ;src/render.c:50: x = sprites[i].x_prev_A;
   59E0 DD 6E F6      [19]  246 	ld	l,-10 (ix)
   59E3 DD 66 F7      [19]  247 	ld	h,-9 (ix)
   59E6 11 05 00      [10]  248 	ld	de, #0x0005
   59E9 19            [11]  249 	add	hl, de
   59EA 7E            [ 7]  250 	ld	a, (hl)
   59EB DD 77 F8      [19]  251 	ld	-8 (ix), a
                            252 ;src/render.c:51: y = sprites[i].y_prev_A;
   59EE DD 6E F6      [19]  253 	ld	l,-10 (ix)
   59F1 DD 66 F7      [19]  254 	ld	h,-9 (ix)
   59F4 11 06 00      [10]  255 	ld	de, #0x0006
   59F7 19            [11]  256 	add	hl, de
   59F8 7E            [ 7]  257 	ld	a, (hl)
   59F9 DD 77 FF      [19]  258 	ld	-1 (ix), a
   59FC                     259 00103$:
                            260 ;src/render.c:56: sprites[i].width, sprites[i].height);
   59FC DD 7E F6      [19]  261 	ld	a, -10 (ix)
   59FF DD 77 FD      [19]  262 	ld	-3 (ix), a
   5A02 DD 7E F7      [19]  263 	ld	a, -9 (ix)
   5A05 DD 77 FE      [19]  264 	ld	-2 (ix), a
   5A08 DD 6E FD      [19]  265 	ld	l,-3 (ix)
   5A0B DD 66 FE      [19]  266 	ld	h,-2 (ix)
   5A0E 11 09 00      [10]  267 	ld	de, #0x0009
   5A11 19            [11]  268 	add	hl, de
   5A12 7E            [ 7]  269 	ld	a, (hl)
   5A13 DD 77 FD      [19]  270 	ld	-3 (ix), a
   5A16 DD 6E F6      [19]  271 	ld	l,-10 (ix)
   5A19 DD 66 F7      [19]  272 	ld	h,-9 (ix)
   5A1C 11 0A 00      [10]  273 	ld	de, #0x000a
   5A1F 19            [11]  274 	add	hl, de
   5A20 7E            [ 7]  275 	ld	a, (hl)
   5A21 DD 77 F6      [19]  276 	ld	-10 (ix), a
                            277 ;src/render.c:55: cpct_px2byteM0(5,5),						//background color
   5A24 21 05 05      [10]  278 	ld	hl, #0x0505
   5A27 E5            [11]  279 	push	hl
   5A28 CD CD 5C      [17]  280 	call	_cpct_px2byteM0
   5A2B DD 75 FB      [19]  281 	ld	-5 (ix), l
   5A2E DD 36 FC 00   [19]  282 	ld	-4 (ix), #0x00
                            283 ;src/render.c:54: cpct_getScreenPtr(mem_start, x, y),
   5A32 2A D8 5E      [16]  284 	ld	hl, (_mem_start)
   5A35 DD 75 F9      [19]  285 	ld	-7 (ix), l
   5A38 DD 74 FA      [19]  286 	ld	-6 (ix), h
   5A3B DD 66 FF      [19]  287 	ld	h, -1 (ix)
   5A3E DD 6E F8      [19]  288 	ld	l, -8 (ix)
   5A41 E5            [11]  289 	push	hl
   5A42 DD 6E F9      [19]  290 	ld	l,-7 (ix)
   5A45 DD 66 FA      [19]  291 	ld	h,-6 (ix)
   5A48 E5            [11]  292 	push	hl
   5A49 CD D4 5D      [17]  293 	call	_cpct_getScreenPtr
   5A4C DD 74 FA      [19]  294 	ld	-6 (ix), h
   5A4F DD 75 F9      [19]  295 	ld	-7 (ix), l
   5A52 DD 66 FD      [19]  296 	ld	h, -3 (ix)
   5A55 DD 6E F6      [19]  297 	ld	l, -10 (ix)
   5A58 E5            [11]  298 	push	hl
   5A59 DD 6E FB      [19]  299 	ld	l,-5 (ix)
   5A5C DD 66 FC      [19]  300 	ld	h,-4 (ix)
   5A5F E5            [11]  301 	push	hl
   5A60 DD 6E F9      [19]  302 	ld	l,-7 (ix)
   5A63 DD 66 FA      [19]  303 	ld	h,-6 (ix)
   5A66 E5            [11]  304 	push	hl
   5A67 CD 07 5D      [17]  305 	call	_cpct_drawSolidBox
   5A6A                     306 00108$:
                            307 ;src/render.c:43: for (i = 0; i < MAX_SPRITES; i++) {
   5A6A DD 34 F5      [23]  308 	inc	-11 (ix)
   5A6D DD 7E F5      [19]  309 	ld	a, -11 (ix)
   5A70 D6 0A         [ 7]  310 	sub	a, #0x0a
   5A72 DA 9D 59      [10]  311 	jp	C, 00107$
   5A75 DD F9         [10]  312 	ld	sp, ix
   5A77 DD E1         [14]  313 	pop	ix
   5A79 C9            [10]  314 	ret
                            315 	.area _CODE
                            316 	.area _INITIALIZER
                            317 	.area _CABS (ABS)
