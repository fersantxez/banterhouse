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
   5854                      52 _renderSprites::
   5854 DD E5         [15]   53 	push	ix
   5856 DD 21 00 00   [14]   54 	ld	ix,#0
   585A DD 39         [15]   55 	add	ix,sp
   585C 21 F5 FF      [10]   56 	ld	hl, #-11
   585F 39            [11]   57 	add	hl, sp
   5860 F9            [ 6]   58 	ld	sp, hl
                             59 ;src/render.c:10: for (i = 0; i < MAX_SPRITES; i++) {
   5861 06 00         [ 7]   60 	ld	b, #0x00
   5863                      61 00109$:
                             62 ;src/render.c:11: if (sprites[i].id !=0) {			//only live and renderable sprites
   5863 58            [ 4]   63 	ld	e,b
   5864 16 00         [ 7]   64 	ld	d,#0x00
   5866 6B            [ 4]   65 	ld	l, e
   5867 62            [ 4]   66 	ld	h, d
   5868 29            [11]   67 	add	hl, hl
   5869 29            [11]   68 	add	hl, hl
   586A 19            [11]   69 	add	hl, de
   586B 29            [11]   70 	add	hl, hl
   586C 19            [11]   71 	add	hl, de
   586D 29            [11]   72 	add	hl, hl
   586E EB            [ 4]   73 	ex	de,hl
   586F 21 AE 5D      [10]   74 	ld	hl, #_sprites
   5872 19            [11]   75 	add	hl,de
   5873 EB            [ 4]   76 	ex	de,hl
   5874 1A            [ 7]   77 	ld	a, (de)
   5875 B7            [ 4]   78 	or	a, a
   5876 CA 33 59      [10]   79 	jp	Z, 00110$
                             80 ;src/render.c:12: if (sprites[i].properties & MASK_RENDER){
   5879 D5            [11]   81 	push	de
   587A FD E1         [14]   82 	pop	iy
   587C FD 4E 0B      [19]   83 	ld	c, 11 (iy)
                             84 ;src/render.c:16: cpct_getScreenPtr(mem_start, sprites[i].x, sprites[i].y), //on current *mem_start* plus sprite size
   587F 21 02 00      [10]   85 	ld	hl, #0x0002
   5882 19            [11]   86 	add	hl,de
   5883 DD 75 FE      [19]   87 	ld	-2 (ix), l
   5886 DD 74 FF      [19]   88 	ld	-1 (ix), h
   5889 21 01 00      [10]   89 	ld	hl, #0x0001
   588C 19            [11]   90 	add	hl,de
   588D DD 75 FC      [19]   91 	ld	-4 (ix), l
   5890 DD 74 FD      [19]   92 	ld	-3 (ix), h
                             93 ;src/render.c:12: if (sprites[i].properties & MASK_RENDER){
   5893 CB 41         [ 8]   94 	bit	0, c
   5895 28 69         [12]   95 	jr	Z,00102$
                             96 ;src/render.c:13: sprite = sprites[i].sprite_f1;
   5897 D5            [11]   97 	push	de
   5898 FD E1         [14]   98 	pop	iy
   589A FD 7E 0E      [19]   99 	ld	a, 14 (iy)
   589D DD 77 F5      [19]  100 	ld	-11 (ix), a
   58A0 FD 7E 0F      [19]  101 	ld	a, 15 (iy)
   58A3 DD 77 F6      [19]  102 	ld	-10 (ix), a
                            103 ;src/render.c:17: sprites[i].width, sprites[i].height);
   58A6 D5            [11]  104 	push	de
   58A7 FD E1         [14]  105 	pop	iy
   58A9 FD 7E 09      [19]  106 	ld	a, 9 (iy)
   58AC DD 77 F7      [19]  107 	ld	-9 (ix), a
   58AF D5            [11]  108 	push	de
   58B0 FD E1         [14]  109 	pop	iy
   58B2 FD 7E 0A      [19]  110 	ld	a, 10 (iy)
   58B5 DD 77 F9      [19]  111 	ld	-7 (ix), a
                            112 ;src/render.c:16: cpct_getScreenPtr(mem_start, sprites[i].x, sprites[i].y), //on current *mem_start* plus sprite size
   58B8 DD 6E FE      [19]  113 	ld	l,-2 (ix)
   58BB DD 66 FF      [19]  114 	ld	h,-1 (ix)
   58BE 7E            [ 7]  115 	ld	a, (hl)
   58BF DD 77 F8      [19]  116 	ld	-8 (ix), a
   58C2 DD 6E FC      [19]  117 	ld	l,-4 (ix)
   58C5 DD 66 FD      [19]  118 	ld	h,-3 (ix)
   58C8 4E            [ 7]  119 	ld	c, (hl)
   58C9 FD 2A 8B 5E   [20]  120 	ld	iy, (_mem_start)
   58CD C5            [11]  121 	push	bc
   58CE D5            [11]  122 	push	de
   58CF DD 46 F8      [19]  123 	ld	b, -8 (ix)
   58D2 C5            [11]  124 	push	bc
   58D3 FD E5         [15]  125 	push	iy
   58D5 CD 87 5D      [17]  126 	call	_cpct_getScreenPtr
   58D8 D1            [10]  127 	pop	de
   58D9 C1            [10]  128 	pop	bc
   58DA E5            [11]  129 	push	hl
   58DB FD E1         [14]  130 	pop	iy
                            131 ;src/render.c:15: cpct_drawSpriteMasked(sprite,
   58DD DD 7E F5      [19]  132 	ld	a, -11 (ix)
   58E0 DD 77 FA      [19]  133 	ld	-6 (ix), a
   58E3 DD 7E F6      [19]  134 	ld	a, -10 (ix)
   58E6 DD 77 FB      [19]  135 	ld	-5 (ix), a
   58E9 C5            [11]  136 	push	bc
   58EA D5            [11]  137 	push	de
   58EB DD 66 F7      [19]  138 	ld	h, -9 (ix)
   58EE DD 6E F9      [19]  139 	ld	l, -7 (ix)
   58F1 E5            [11]  140 	push	hl
   58F2 FD E5         [15]  141 	push	iy
   58F4 DD 6E FA      [19]  142 	ld	l,-6 (ix)
   58F7 DD 66 FB      [19]  143 	ld	h,-5 (ix)
   58FA E5            [11]  144 	push	hl
   58FB CD 1C 5C      [17]  145 	call	_cpct_drawSpriteMasked
   58FE D1            [10]  146 	pop	de
   58FF C1            [10]  147 	pop	bc
   5900                     148 00102$:
                            149 ;src/render.c:16: cpct_getScreenPtr(mem_start, sprites[i].x, sprites[i].y), //on current *mem_start* plus sprite size
   5900 DD 6E FC      [19]  150 	ld	l,-4 (ix)
   5903 DD 66 FD      [19]  151 	ld	h,-3 (ix)
   5906 4E            [ 7]  152 	ld	c, (hl)
                            153 ;src/render.c:21: if (!swap_memvideo) {
   5907 3A 8E 5E      [13]  154 	ld	a,(#_swap_memvideo + 0)
   590A B7            [ 4]  155 	or	a, a
   590B 20 14         [12]  156 	jr	NZ,00104$
                            157 ;src/render.c:22: sprites[i].x_prev_B = sprites[i].x;
   590D 21 07 00      [10]  158 	ld	hl, #0x0007
   5910 19            [11]  159 	add	hl, de
   5911 71            [ 7]  160 	ld	(hl), c
                            161 ;src/render.c:23: sprites[i].y_prev_B = sprites[i].y;
   5912 21 08 00      [10]  162 	ld	hl, #0x0008
   5915 19            [11]  163 	add	hl,de
   5916 EB            [ 4]  164 	ex	de,hl
   5917 DD 6E FE      [19]  165 	ld	l,-2 (ix)
   591A DD 66 FF      [19]  166 	ld	h,-1 (ix)
   591D 7E            [ 7]  167 	ld	a, (hl)
   591E 12            [ 7]  168 	ld	(de), a
   591F 18 12         [12]  169 	jr	00110$
   5921                     170 00104$:
                            171 ;src/render.c:25: sprites[i].x_prev_A = sprites[i].x;
   5921 21 05 00      [10]  172 	ld	hl, #0x0005
   5924 19            [11]  173 	add	hl, de
   5925 71            [ 7]  174 	ld	(hl), c
                            175 ;src/render.c:26: sprites[i].y_prev_A = sprites[i].y;
   5926 21 06 00      [10]  176 	ld	hl, #0x0006
   5929 19            [11]  177 	add	hl,de
   592A EB            [ 4]  178 	ex	de,hl
   592B DD 6E FE      [19]  179 	ld	l,-2 (ix)
   592E DD 66 FF      [19]  180 	ld	h,-1 (ix)
   5931 7E            [ 7]  181 	ld	a, (hl)
   5932 12            [ 7]  182 	ld	(de), a
   5933                     183 00110$:
                            184 ;src/render.c:10: for (i = 0; i < MAX_SPRITES; i++) {
   5933 04            [ 4]  185 	inc	b
   5934 78            [ 4]  186 	ld	a, b
   5935 D6 0A         [ 7]  187 	sub	a, #0x0a
   5937 DA 63 58      [10]  188 	jp	C, 00109$
   593A DD F9         [10]  189 	ld	sp, ix
   593C DD E1         [14]  190 	pop	ix
   593E C9            [10]  191 	ret
                            192 ;src/render.c:33: void deleteSprites(){
                            193 ;	---------------------------------
                            194 ; Function deleteSprites
                            195 ; ---------------------------------
   593F                     196 _deleteSprites::
   593F DD E5         [15]  197 	push	ix
   5941 DD 21 00 00   [14]  198 	ld	ix,#0
   5945 DD 39         [15]  199 	add	ix,sp
   5947 21 F5 FF      [10]  200 	ld	hl, #-11
   594A 39            [11]  201 	add	hl, sp
   594B F9            [ 6]  202 	ld	sp, hl
                            203 ;src/render.c:37: for (i = 0; i < MAX_SPRITES; i++) {
   594C DD 36 F5 00   [19]  204 	ld	-11 (ix), #0x00
   5950                     205 00107$:
                            206 ;src/render.c:38: if (sprites[i].id !=0) {
   5950 DD 4E F5      [19]  207 	ld	c,-11 (ix)
   5953 06 00         [ 7]  208 	ld	b,#0x00
   5955 69            [ 4]  209 	ld	l, c
   5956 60            [ 4]  210 	ld	h, b
   5957 29            [11]  211 	add	hl, hl
   5958 29            [11]  212 	add	hl, hl
   5959 09            [11]  213 	add	hl, bc
   595A 29            [11]  214 	add	hl, hl
   595B 09            [11]  215 	add	hl, bc
   595C 29            [11]  216 	add	hl, hl
   595D 01 AE 5D      [10]  217 	ld	bc,#_sprites
   5960 09            [11]  218 	add	hl,bc
   5961 DD 75 F9      [19]  219 	ld	-7 (ix), l
   5964 DD 74 FA      [19]  220 	ld	-6 (ix), h
   5967 7E            [ 7]  221 	ld	a, (hl)
   5968 DD 77 FB      [19]  222 	ld	-5 (ix), a
   596B B7            [ 4]  223 	or	a, a
   596C CA 1D 5A      [10]  224 	jp	Z, 00108$
                            225 ;src/render.c:39: if (!swap_memvideo){
   596F 3A 8E 5E      [13]  226 	ld	a,(#_swap_memvideo + 0)
   5972 B7            [ 4]  227 	or	a, a
   5973 20 1E         [12]  228 	jr	NZ,00102$
                            229 ;src/render.c:40: x = sprites[i].x_prev_B;
   5975 DD 6E F9      [19]  230 	ld	l,-7 (ix)
   5978 DD 66 FA      [19]  231 	ld	h,-6 (ix)
   597B 11 07 00      [10]  232 	ld	de, #0x0007
   597E 19            [11]  233 	add	hl, de
   597F 7E            [ 7]  234 	ld	a, (hl)
   5980 DD 77 FB      [19]  235 	ld	-5 (ix), a
                            236 ;src/render.c:41: y = sprites[i].y_prev_B;
   5983 DD 6E F9      [19]  237 	ld	l,-7 (ix)
   5986 DD 66 FA      [19]  238 	ld	h,-6 (ix)
   5989 11 08 00      [10]  239 	ld	de, #0x0008
   598C 19            [11]  240 	add	hl, de
   598D 7E            [ 7]  241 	ld	a, (hl)
   598E DD 77 F6      [19]  242 	ld	-10 (ix), a
   5991 18 1C         [12]  243 	jr	00103$
   5993                     244 00102$:
                            245 ;src/render.c:44: x = sprites[i].x_prev_A;
   5993 DD 6E F9      [19]  246 	ld	l,-7 (ix)
   5996 DD 66 FA      [19]  247 	ld	h,-6 (ix)
   5999 11 05 00      [10]  248 	ld	de, #0x0005
   599C 19            [11]  249 	add	hl, de
   599D 7E            [ 7]  250 	ld	a, (hl)
   599E DD 77 FB      [19]  251 	ld	-5 (ix), a
                            252 ;src/render.c:45: y = sprites[i].y_prev_A;
   59A1 DD 6E F9      [19]  253 	ld	l,-7 (ix)
   59A4 DD 66 FA      [19]  254 	ld	h,-6 (ix)
   59A7 11 06 00      [10]  255 	ld	de, #0x0006
   59AA 19            [11]  256 	add	hl, de
   59AB 7E            [ 7]  257 	ld	a, (hl)
   59AC DD 77 F6      [19]  258 	ld	-10 (ix), a
   59AF                     259 00103$:
                            260 ;src/render.c:50: sprites[i].width, sprites[i].height);
   59AF DD 7E F9      [19]  261 	ld	a, -7 (ix)
   59B2 DD 77 F7      [19]  262 	ld	-9 (ix), a
   59B5 DD 7E FA      [19]  263 	ld	a, -6 (ix)
   59B8 DD 77 F8      [19]  264 	ld	-8 (ix), a
   59BB DD 6E F7      [19]  265 	ld	l,-9 (ix)
   59BE DD 66 F8      [19]  266 	ld	h,-8 (ix)
   59C1 11 09 00      [10]  267 	ld	de, #0x0009
   59C4 19            [11]  268 	add	hl, de
   59C5 7E            [ 7]  269 	ld	a, (hl)
   59C6 DD 77 F7      [19]  270 	ld	-9 (ix), a
   59C9 DD 6E F9      [19]  271 	ld	l,-7 (ix)
   59CC DD 66 FA      [19]  272 	ld	h,-6 (ix)
   59CF 11 0A 00      [10]  273 	ld	de, #0x000a
   59D2 19            [11]  274 	add	hl, de
   59D3 7E            [ 7]  275 	ld	a, (hl)
   59D4 DD 77 F9      [19]  276 	ld	-7 (ix), a
                            277 ;src/render.c:49: cpct_px2byteM0(5,5), 
   59D7 21 05 05      [10]  278 	ld	hl, #0x0505
   59DA E5            [11]  279 	push	hl
   59DB CD 80 5C      [17]  280 	call	_cpct_px2byteM0
   59DE DD 75 FE      [19]  281 	ld	-2 (ix), l
   59E1 DD 36 FF 00   [19]  282 	ld	-1 (ix), #0x00
                            283 ;src/render.c:48: cpct_getScreenPtr(mem_start, x, y),
   59E5 2A 8B 5E      [16]  284 	ld	hl, (_mem_start)
   59E8 DD 75 FC      [19]  285 	ld	-4 (ix), l
   59EB DD 74 FD      [19]  286 	ld	-3 (ix), h
   59EE DD 66 F6      [19]  287 	ld	h, -10 (ix)
   59F1 DD 6E FB      [19]  288 	ld	l, -5 (ix)
   59F4 E5            [11]  289 	push	hl
   59F5 DD 6E FC      [19]  290 	ld	l,-4 (ix)
   59F8 DD 66 FD      [19]  291 	ld	h,-3 (ix)
   59FB E5            [11]  292 	push	hl
   59FC CD 87 5D      [17]  293 	call	_cpct_getScreenPtr
   59FF DD 74 FD      [19]  294 	ld	-3 (ix), h
   5A02 DD 75 FC      [19]  295 	ld	-4 (ix), l
   5A05 DD 66 F7      [19]  296 	ld	h, -9 (ix)
   5A08 DD 6E F9      [19]  297 	ld	l, -7 (ix)
   5A0B E5            [11]  298 	push	hl
   5A0C DD 6E FE      [19]  299 	ld	l,-2 (ix)
   5A0F DD 66 FF      [19]  300 	ld	h,-1 (ix)
   5A12 E5            [11]  301 	push	hl
   5A13 DD 6E FC      [19]  302 	ld	l,-4 (ix)
   5A16 DD 66 FD      [19]  303 	ld	h,-3 (ix)
   5A19 E5            [11]  304 	push	hl
   5A1A CD BA 5C      [17]  305 	call	_cpct_drawSolidBox
   5A1D                     306 00108$:
                            307 ;src/render.c:37: for (i = 0; i < MAX_SPRITES; i++) {
   5A1D DD 34 F5      [23]  308 	inc	-11 (ix)
   5A20 DD 7E F5      [19]  309 	ld	a, -11 (ix)
   5A23 D6 0A         [ 7]  310 	sub	a, #0x0a
   5A25 DA 50 59      [10]  311 	jp	C, 00107$
   5A28 DD F9         [10]  312 	ld	sp, ix
   5A2A DD E1         [14]  313 	pop	ix
   5A2C C9            [10]  314 	ret
                            315 	.area _CODE
                            316 	.area _INITIALIZER
                            317 	.area _CABS (ABS)
