# Banterhouse cover master v8 — Alberto model lock

Generated with the built-in image generation tool as a correction of the v7
background. The final Pitu layer was not generated: it was composited
deterministically from `assets/originals/pitu_export.png` after generation.

## Referenced images, in order

1. `banterhouse-cover-master-v7-alberto-lock-background.png`
2. `../references/creatas/alberto-original-model-sheet.png`
3. `../references/creatas/alberto-frontal-model-strip-4x.png`, a saved
   nearest-neighbour crop of the frontal model strip from image 2.
4. `../references/creatas/alberto-visual-reference.png`
5. `../alberto.png`

## Exact generation prompt

> Edit image 1 as a surgical correction of Alberto only, preserving the same 1448x1086 landscape cover.
>
> CRITICAL ANATOMY CORRECTION: In references 2, 3 and 4, the long white vertical columns beneath Alberto's nose and the large U-shaped outline around them are his ENORMOUS RECTANGULAR TOOTHY GRIN. They are teeth and mouth, NOT long hair. His hair is ONLY the short, compact solid-black glossy cap above the sunglasses, with a white angular part/highlight. He has no bob, no curtain hair, no shoulder-length hair and no black side masses below his ears.
>
> Replace only Alberto in the tall far-right panel of image 1. Keep every other element visually unchanged: joint-shaped BANTERHOUSE title, ember, paper texture, panel grid and borders, President at upper left, Art at lower left, Carlitos at upper middle-right, photocopier, loose papers, empty central white panel reserved for Pitu, exact composition, sparse monochrome ink style and 1448x1086 dimensions. No protagonist in the empty center. No new characters, balloons, labels, dialogue or copied text.
>
> Build Alberto literally from the original model sheet:
> - short rounded black hair cap ending around the tops of the ears, with one bold white angular shine/part;
> - large solid black sunglasses across the upper face, with small white triangular/diagonal reflections inside the black lenses; eyes invisible;
> - gigantic central vertical oval nose;
> - immediately below and around the nose, an enormous tall white U/rectangle smile occupying most of the lower head, divided into several long vertical teeth by thin black lines;
> - wide caricature head comprising roughly half his total height, over very narrow shoulders and a small compact body;
> - small expressive hands, short thin arms and legs, small shoes; deliberately non-athletic;
> - dark nearly black suit, white shirt and strictly BLACK tie.
>
> Pose him moving LEFT toward Pitu with a short hurried advertising-executive step, not a long athletic stride. One small hand should toss or offer two or three separate white briefing sheets leftward; the other can touch his tie or gesture. Papers may cross the panel boundary, but Alberto remains inside the far-right panel. Simplify realistic suit folds and hatching so his iconic face dominates.
>
> Match the established hand-drawn Spanish office-comic line: uneven fine black ink, flat black masses, lots of white paper, minimal shading, giant head and tiny body. Reference 5 is only a tiny CPC legibility check, not permission to change the original anatomy. Ignore the website overlay and all text/dialogue in references.

## Deterministic Pitu composition

- Source: full transparent `16×32` canvas from `pitu_export.png`.
- Scale: integer `24×` with nearest-neighbour, producing `384×768`.
- Position: `(445, 182)` on the `1448×1086` background.
- No crop, mirror, interpolation, recolour, regeneration or overpainting.
