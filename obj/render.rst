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
                             48 ;src/render.c:6: void renderSprites(){
                             49 ;	---------------------------------
                             50 ; Function renderSprites
                             51 ; ---------------------------------
   587C                      52 _renderSprites::
   587C DD E5         [15]   53 	push	ix
   587E DD 21 00 00   [14]   54 	ld	ix,#0
   5882 DD 39         [15]   55 	add	ix,sp
   5884 21 F5 FF      [10]   56 	ld	hl, #-11
   5887 39            [11]   57 	add	hl, sp
   5888 F9            [ 6]   58 	ld	sp, hl
                             59 ;src/render.c:10: for (i = 0; i < MAX_SPRITES; i++) {
   5889 06 00         [ 7]   60 	ld	b, #0x00
   588B                      61 00109$:
                             62 ;src/render.c:11: if (sprites[i].id !=0) {			//only live and renderable sprites
   588B 58            [ 4]   63 	ld	e,b
   588C 16 00         [ 7]   64 	ld	d,#0x00
   588E 6B            [ 4]   65 	ld	l, e
   588F 62            [ 4]   66 	ld	h, d
   5890 29            [11]   67 	add	hl, hl
   5891 29            [11]   68 	add	hl, hl
   5892 19            [11]   69 	add	hl, de
   5893 29            [11]   70 	add	hl, hl
   5894 19            [11]   71 	add	hl, de
   5895 29            [11]   72 	add	hl, hl
   5896 EB            [ 4]   73 	ex	de,hl
   5897 21 CE 5D      [10]   74 	ld	hl, #_sprites
   589A 19            [11]   75 	add	hl,de
   589B EB            [ 4]   76 	ex	de,hl
   589C 1A            [ 7]   77 	ld	a, (de)
   589D B7            [ 4]   78 	or	a, a
   589E CA 5B 59      [10]   79 	jp	Z, 00110$
                             80 ;src/render.c:12: if (sprites[i].properties & MASK_RENDER){
   58A1 D5            [11]   81 	push	de
   58A2 FD E1         [14]   82 	pop	iy
   58A4 FD 4E 0B      [19]   83 	ld	c, 11 (iy)
                             84 ;src/render.c:16: cpct_getScreenPtr(mem_start, sprites[i].x, sprites[i].y), //on current *mem_start* plus sprite size
   58A7 21 02 00      [10]   85 	ld	hl, #0x0002
   58AA 19            [11]   86 	add	hl,de
   58AB DD 75 F9      [19]   87 	ld	-7 (ix), l
   58AE DD 74 FA      [19]   88 	ld	-6 (ix), h
   58B1 21 01 00      [10]   89 	ld	hl, #0x0001
   58B4 19            [11]   90 	add	hl,de
   58B5 DD 75 FB      [19]   91 	ld	-5 (ix), l
   58B8 DD 74 FC      [19]   92 	ld	-4 (ix), h
                             93 ;src/render.c:12: if (sprites[i].properties & MASK_RENDER){
   58BB CB 41         [ 8]   94 	bit	0, c
   58BD 28 69         [12]   95 	jr	Z,00102$
                             96 ;src/render.c:13: sprite = sprites[i].sprite_f1;
   58BF D5            [11]   97 	push	de
   58C0 FD E1         [14]   98 	pop	iy
   58C2 FD 7E 0E      [19]   99 	ld	a, 14 (iy)
   58C5 DD 77 F5      [19]  100 	ld	-11 (ix), a
   58C8 FD 7E 0F      [19]  101 	ld	a, 15 (iy)
   58CB DD 77 F6      [19]  102 	ld	-10 (ix), a
                            103 ;src/render.c:17: sprites[i].width, sprites[i].height);
   58CE D5            [11]  104 	push	de
   58CF FD E1         [14]  105 	pop	iy
   58D1 FD 7E 09      [19]  106 	ld	a, 9 (iy)
   58D4 DD 77 FD      [19]  107 	ld	-3 (ix), a
   58D7 D5            [11]  108 	push	de
   58D8 FD E1         [14]  109 	pop	iy
   58DA FD 7E 0A      [19]  110 	ld	a, 10 (iy)
   58DD DD 77 FE      [19]  111 	ld	-2 (ix), a
                            112 ;src/render.c:16: cpct_getScreenPtr(mem_start, sprites[i].x, sprites[i].y), //on current *mem_start* plus sprite size
   58E0 DD 6E F9      [19]  113 	ld	l,-7 (ix)
   58E3 DD 66 FA      [19]  114 	ld	h,-6 (ix)
   58E6 7E            [ 7]  115 	ld	a, (hl)
   58E7 DD 77 FF      [19]  116 	ld	-1 (ix), a
   58EA DD 6E FB      [19]  117 	ld	l,-5 (ix)
   58ED DD 66 FC      [19]  118 	ld	h,-4 (ix)
   58F0 4E            [ 7]  119 	ld	c, (hl)
   58F1 FD 2A AB 5E   [20]  120 	ld	iy, (_mem_start)
   58F5 C5            [11]  121 	push	bc
   58F6 D5            [11]  122 	push	de
   58F7 DD 46 FF      [19]  123 	ld	b, -1 (ix)
   58FA C5            [11]  124 	push	bc
   58FB FD E5         [15]  125 	push	iy
   58FD CD A7 5D      [17]  126 	call	_cpct_getScreenPtr
   5900 D1            [10]  127 	pop	de
   5901 C1            [10]  128 	pop	bc
   5902 E5            [11]  129 	push	hl
   5903 FD E1         [14]  130 	pop	iy
                            131 ;src/render.c:15: cpct_drawSpriteMasked(sprite,
   5905 DD 7E F5      [19]  132 	ld	a, -11 (ix)
   5908 DD 77 F7      [19]  133 	ld	-9 (ix), a
   590B DD 7E F6      [19]  134 	ld	a, -10 (ix)
   590E DD 77 F8      [19]  135 	ld	-8 (ix), a
   5911 C5            [11]  136 	push	bc
   5912 D5            [11]  137 	push	de
   5913 DD 66 FD      [19]  138 	ld	h, -3 (ix)
   5916 DD 6E FE      [19]  139 	ld	l, -2 (ix)
   5919 E5            [11]  140 	push	hl
   591A FD E5         [15]  141 	push	iy
   591C DD 6E F7      [19]  142 	ld	l,-9 (ix)
   591F DD 66 F8      [19]  143 	ld	h,-8 (ix)
   5922 E5            [11]  144 	push	hl
   5923 CD 3C 5C      [17]  145 	call	_cpct_drawSpriteMasked
   5926 D1            [10]  146 	pop	de
   5927 C1            [10]  147 	pop	bc
   5928                     148 00102$:
                            149 ;src/render.c:16: cpct_getScreenPtr(mem_start, sprites[i].x, sprites[i].y), //on current *mem_start* plus sprite size
   5928 DD 6E FB      [19]  150 	ld	l,-5 (ix)
   592B DD 66 FC      [19]  151 	ld	h,-4 (ix)
   592E 4E            [ 7]  152 	ld	c, (hl)
                            153 ;src/render.c:21: if (!swap_memvideo) {
   592F 3A AE 5E      [13]  154 	ld	a,(#_swap_memvideo + 0)
   5932 B7            [ 4]  155 	or	a, a
   5933 20 14         [12]  156 	jr	NZ,00104$
                            157 ;src/render.c:22: sprites[i].x_prev_B = sprites[i].x;
   5935 21 07 00      [10]  158 	ld	hl, #0x0007
   5938 19            [11]  159 	add	hl, de
   5939 71            [ 7]  160 	ld	(hl), c
                            161 ;src/render.c:23: sprites[i].y_prev_B = sprites[i].y;
   593A 21 08 00      [10]  162 	ld	hl, #0x0008
   593D 19            [11]  163 	add	hl,de
   593E EB            [ 4]  164 	ex	de,hl
   593F DD 6E F9      [19]  165 	ld	l,-7 (ix)
   5942 DD 66 FA      [19]  166 	ld	h,-6 (ix)
   5945 7E            [ 7]  167 	ld	a, (hl)
   5946 12            [ 7]  168 	ld	(de), a
   5947 18 12         [12]  169 	jr	00110$
   5949                     170 00104$:
                            171 ;src/render.c:25: sprites[i].x_prev_A = sprites[i].x;
   5949 21 05 00      [10]  172 	ld	hl, #0x0005
   594C 19            [11]  173 	add	hl, de
   594D 71            [ 7]  174 	ld	(hl), c
                            175 ;src/render.c:26: sprites[i].y_prev_A = sprites[i].y;
   594E 21 06 00      [10]  176 	ld	hl, #0x0006
   5951 19            [11]  177 	add	hl,de
   5952 EB            [ 4]  178 	ex	de,hl
   5953 DD 6E F9      [19]  179 	ld	l,-7 (ix)
   5956 DD 66 FA      [19]  180 	ld	h,-6 (ix)
   5959 7E            [ 7]  181 	ld	a, (hl)
   595A 12            [ 7]  182 	ld	(de), a
   595B                     183 00110$:
                            184 ;src/render.c:10: for (i = 0; i < MAX_SPRITES; i++) {
   595B 04            [ 4]  185 	inc	b
   595C 78            [ 4]  186 	ld	a, b
   595D D6 0A         [ 7]  187 	sub	a, #0x0a
   595F DA 8B 58      [10]  188 	jp	C, 00109$
   5962 DD F9         [10]  189 	ld	sp, ix
   5964 DD E1         [14]  190 	pop	ix
   5966 C9            [10]  191 	ret
                            192 ;src/render.c:33: void deleteSprites(){
                            193 ;	---------------------------------
                            194 ; Function deleteSprites
                            195 ; ---------------------------------
   5967                     196 _deleteSprites::
   5967 DD E5         [15]  197 	push	ix
   5969 DD 21 00 00   [14]  198 	ld	ix,#0
   596D DD 39         [15]  199 	add	ix,sp
   596F 21 F5 FF      [10]  200 	ld	hl, #-11
   5972 39            [11]  201 	add	hl, sp
   5973 F9            [ 6]  202 	ld	sp, hl
                            203 ;src/render.c:37: for (i = 0; i < MAX_SPRITES; i++) {
   5974 DD 36 F5 00   [19]  204 	ld	-11 (ix), #0x00
   5978                     205 00107$:
                            206 ;src/render.c:38: if (sprites[i].id !=0) {
   5978 DD 4E F5      [19]  207 	ld	c,-11 (ix)
   597B 06 00         [ 7]  208 	ld	b,#0x00
   597D 69            [ 4]  209 	ld	l, c
   597E 60            [ 4]  210 	ld	h, b
   597F 29            [11]  211 	add	hl, hl
   5980 29            [11]  212 	add	hl, hl
   5981 09            [11]  213 	add	hl, bc
   5982 29            [11]  214 	add	hl, hl
   5983 09            [11]  215 	add	hl, bc
   5984 29            [11]  216 	add	hl, hl
   5985 01 CE 5D      [10]  217 	ld	bc,#_sprites
   5988 09            [11]  218 	add	hl,bc
   5989 DD 75 F7      [19]  219 	ld	-9 (ix), l
   598C DD 74 F8      [19]  220 	ld	-8 (ix), h
   598F 7E            [ 7]  221 	ld	a, (hl)
   5990 DD 77 F6      [19]  222 	ld	-10 (ix), a
   5993 B7            [ 4]  223 	or	a, a
   5994 CA 3D 5A      [10]  224 	jp	Z, 00108$
                            225 ;src/render.c:39: if (!swap_memvideo){
   5997 3A AE 5E      [13]  226 	ld	a,(#_swap_memvideo + 0)
   599A B7            [ 4]  227 	or	a, a
   599B 20 1A         [12]  228 	jr	NZ,00102$
                            229 ;src/render.c:40: x = sprites[i].x_prev_B;
   599D C1            [10]  230 	pop	bc
   599E E1            [10]  231 	pop	hl
   599F E5            [11]  232 	push	hl
   59A0 C5            [11]  233 	push	bc
   59A1 11 07 00      [10]  234 	ld	de, #0x0007
   59A4 19            [11]  235 	add	hl, de
   59A5 7E            [ 7]  236 	ld	a, (hl)
   59A6 DD 77 F6      [19]  237 	ld	-10 (ix), a
                            238 ;src/render.c:41: y = sprites[i].y_prev_B;
   59A9 C1            [10]  239 	pop	bc
   59AA E1            [10]  240 	pop	hl
   59AB E5            [11]  241 	push	hl
   59AC C5            [11]  242 	push	bc
   59AD 11 08 00      [10]  243 	ld	de, #0x0008
   59B0 19            [11]  244 	add	hl, de
   59B1 7E            [ 7]  245 	ld	a, (hl)
   59B2 DD 77 FF      [19]  246 	ld	-1 (ix), a
   59B5 18 18         [12]  247 	jr	00103$
   59B7                     248 00102$:
                            249 ;src/render.c:44: x = sprites[i].x_prev_A;
   59B7 C1            [10]  250 	pop	bc
   59B8 E1            [10]  251 	pop	hl
   59B9 E5            [11]  252 	push	hl
   59BA C5            [11]  253 	push	bc
   59BB 11 05 00      [10]  254 	ld	de, #0x0005
   59BE 19            [11]  255 	add	hl, de
   59BF 7E            [ 7]  256 	ld	a, (hl)
   59C0 DD 77 F6      [19]  257 	ld	-10 (ix), a
                            258 ;src/render.c:45: y = sprites[i].y_prev_A;
   59C3 C1            [10]  259 	pop	bc
   59C4 E1            [10]  260 	pop	hl
   59C5 E5            [11]  261 	push	hl
   59C6 C5            [11]  262 	push	bc
   59C7 11 06 00      [10]  263 	ld	de, #0x0006
   59CA 19            [11]  264 	add	hl, de
   59CB 7E            [ 7]  265 	ld	a, (hl)
   59CC DD 77 FF      [19]  266 	ld	-1 (ix), a
   59CF                     267 00103$:
                            268 ;src/render.c:50: sprites[i].width, sprites[i].height);
   59CF DD 7E F7      [19]  269 	ld	a, -9 (ix)
   59D2 DD 77 FD      [19]  270 	ld	-3 (ix), a
   59D5 DD 7E F8      [19]  271 	ld	a, -8 (ix)
   59D8 DD 77 FE      [19]  272 	ld	-2 (ix), a
   59DB DD 6E FD      [19]  273 	ld	l,-3 (ix)
   59DE DD 66 FE      [19]  274 	ld	h,-2 (ix)
   59E1 11 09 00      [10]  275 	ld	de, #0x0009
   59E4 19            [11]  276 	add	hl, de
   59E5 7E            [ 7]  277 	ld	a, (hl)
   59E6 DD 77 FD      [19]  278 	ld	-3 (ix), a
   59E9 DD 6E F7      [19]  279 	ld	l,-9 (ix)
   59EC DD 66 F8      [19]  280 	ld	h,-8 (ix)
   59EF 11 0A 00      [10]  281 	ld	de, #0x000a
   59F2 19            [11]  282 	add	hl, de
   59F3 7E            [ 7]  283 	ld	a, (hl)
   59F4 DD 77 F7      [19]  284 	ld	-9 (ix), a
                            285 ;src/render.c:49: cpct_px2byteM0(5,5), 
   59F7 21 05 05      [10]  286 	ld	hl, #0x0505
   59FA E5            [11]  287 	push	hl
   59FB CD A0 5C      [17]  288 	call	_cpct_px2byteM0
   59FE DD 75 FB      [19]  289 	ld	-5 (ix), l
   5A01 DD 36 FC 00   [19]  290 	ld	-4 (ix), #0x00
                            291 ;src/render.c:48: cpct_getScreenPtr(mem_start, x, y),
   5A05 2A AB 5E      [16]  292 	ld	hl, (_mem_start)
   5A08 DD 75 F9      [19]  293 	ld	-7 (ix), l
   5A0B DD 74 FA      [19]  294 	ld	-6 (ix), h
   5A0E DD 66 FF      [19]  295 	ld	h, -1 (ix)
   5A11 DD 6E F6      [19]  296 	ld	l, -10 (ix)
   5A14 E5            [11]  297 	push	hl
   5A15 DD 6E F9      [19]  298 	ld	l,-7 (ix)
   5A18 DD 66 FA      [19]  299 	ld	h,-6 (ix)
   5A1B E5            [11]  300 	push	hl
   5A1C CD A7 5D      [17]  301 	call	_cpct_getScreenPtr
   5A1F DD 74 FA      [19]  302 	ld	-6 (ix), h
   5A22 DD 75 F9      [19]  303 	ld	-7 (ix), l
   5A25 DD 66 FD      [19]  304 	ld	h, -3 (ix)
   5A28 DD 6E F7      [19]  305 	ld	l, -9 (ix)
   5A2B E5            [11]  306 	push	hl
   5A2C DD 6E FB      [19]  307 	ld	l,-5 (ix)
   5A2F DD 66 FC      [19]  308 	ld	h,-4 (ix)
   5A32 E5            [11]  309 	push	hl
   5A33 DD 6E F9      [19]  310 	ld	l,-7 (ix)
   5A36 DD 66 FA      [19]  311 	ld	h,-6 (ix)
   5A39 E5            [11]  312 	push	hl
   5A3A CD DA 5C      [17]  313 	call	_cpct_drawSolidBox
   5A3D                     314 00108$:
                            315 ;src/render.c:37: for (i = 0; i < MAX_SPRITES; i++) {
   5A3D DD 34 F5      [23]  316 	inc	-11 (ix)
   5A40 DD 7E F5      [19]  317 	ld	a, -11 (ix)
   5A43 D6 0A         [ 7]  318 	sub	a, #0x0a
   5A45 DA 78 59      [10]  319 	jp	C, 00107$
   5A48 DD F9         [10]  320 	ld	sp, ix
   5A4A DD E1         [14]  321 	pop	ix
   5A4C C9            [10]  322 	ret
                            323 	.area _CODE
                            324 	.area _INITIALIZER
                            325 	.area _CABS (ABS)
