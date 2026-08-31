# Banterhouse — sistema visual de 30 pantallas

Fecha de validación: 31 de agosto de 2026

## Resultado

La campaña jugable ya no reutiliza un fondo plano. Sus treinta coordenadas
`planta × sala` seleccionan una composición propia con nombre, paleta semántica
y landmark de agencia. Las tres fases del jefe reutilizan las coordenadas de la
décima planta como Antesala, Consejo y Proyección.

La dirección conserva las limitaciones de Mode 0: siluetas gruesas, masas de
color, blancos de viñeta, rótulos editoriales y objetos reconocibles a baja
resolución. No se almacenan treinta capturas de 16 KiB; la variedad procede de
datos compactos y de un compositor común.

## Pipeline

1. `assets/rooms/visuals.json` es la biblia ordenada de las 30 pantallas.
2. Cada entrada declara `paper`, `ink`, `accent`, `shadow`, rótulo, landmark y
   de 8 a 16 rectángulos decorativos.
3. `tools/build_room_visuals.py` valida y genera `src/room_visuals.c/.h`.
4. El build rechaza coordenadas duplicadas, labels no ASCII o demasiado largos,
   landmarks repetidos, falta de contraste, fondos escasos y geometría fuera
   del área jugable.
5. `tools/test_room_visuals.py` añade fixtures corruptos para demostrar que cada
   una de esas rutas falla de forma controlada.

El resultado actual contiene 30 rótulos, 30 landmarks únicos y 330 piezas de
decoración. Los datos inmutables viven en `_BH_GFX`, entre los sprites y el
código residente.

## Runtime y rendimiento

El primer renderer redibujaba 16 KiB, texto y todos los objetos cada tick. La
galería real midió cerca de 5 Hz y se consideró un fallo, aunque el overlay del
emulador siguiera mostrando 50 FPS de vídeo.

La versión final separa dos capas:

- la capa estática se recompone cuando cambian sala, inventario visible, café,
  HUD, mensaje, pausa o fase del jefe;
- Pitu, Alberto y los proyectiles guardan y restauran únicamente los píxeles
  que ocultan mediante los primitivos optimizados de CPCtelera.

El framebuffer visible permanece en `0xC000`; `0x8000–0x8240` se usa como área
oculta de save-under. El código empieza en `0x3D00`, después de `_BH_GFX`, y el
release medido termina en `0x6DEF`, con 4.624 bytes de margen hasta la pila.

La prueba final recorrió 4.350 frames lógicos en 173 segundos: **25,1 Hz** con
Caprice32 limitado al 100% de velocidad. Produjo exactamente 30 marcadores y 30
capturas. La hoja de contacto está en `docs/images/room-gallery.png`.

## Inventario de pantallas

| Planta | Sala 1 | Sala 2 | Sala 3 |
|---|---|---|---|
| 1 | Mesa Pitu | Estudio | Rincón Art |
| 2 | Copy | Pasillo | Centralita |
| 3 | Túnel Pantone | Mesa de Luz | Cuarto Oscuro |
| 4 | Repro | Fotocopia | Atrezo |
| 5 | Recepción | Pecera | Planning |
| 6 | Archivo | Premios | Terraza |
| 7 | Cocina | Estudio Noche | Montacargas |
| 8 | Cuentas | Despacho Alberto | Fax |
| 9 | Cliente | Preproducción | Auditorio |
| 10 | Antesala | Consejo | Proyección |

## Aceptación ejecutada

- generación determinista y fault tests de las 30 entradas;
- build limpio y paralelo idénticos;
- galería completa en CPC 6128 a 25,1 Hz;
- cinco campañas de diez niveles, incluida la secuencia completa del jefe;
- 400 ciclos de resource manager y 10.000 cambios de banco;
- rutas FDC normales, CRC corrupto, sector ausente y soak de 100 cargas;
- captura del loop musical y ocho efectos AY;
- margen residente superior a 4 KiB.

Las pruebas humanas con jugadores nuevos y la matriz de hardware físico siguen
siendo gates externos de producto; no se sustituyen por una afirmación de
automatización.
