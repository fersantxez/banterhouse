# Banterhouse - marcador editorial: implementación y pruebas

Fecha de cierre: 31 de agosto de 2026
Plataforma: Amstrad CPC 6128, Mode 0, 160×200
Estado: implementado, validado y publicado con el release

## Resultado

El marcador técnico original se ha sustituido por una banda editorial de
160×16 píxeles inspirada en la claridad de los grandes juegos españoles de 8
bits. Conserva toda la información jugable y añade una firma visual permanente:

```text
BANTER  *07/12  |||--  CAFE 3  08450
HOUSE
```

El panel real se compone de:

- wordmark completo `BANTER/HOUSE` en dos líneas;
- ideas recuperadas entre `00/12` y `12/12`;
- hasta cinco hojas de Carga, adaptadas a la dificultad;
- taza y número de cafés de reserva;
- puntuación de cinco cifras, de `00000` a `65535`.

## Layout aprobado

Las coordenadas horizontales están expresadas en bytes de Mode 0; cada byte son
dos píxeles visibles.

| X | Ancho | Módulo | Peor caso |
|---:|---:|---|---|
| 0 | 14 | Logo | sprite 28×14 px |
| 15 | 24 | Ideas | `*12/12` |
| 40 | 9 | Carga | cinco hojas con separación negra |
| 51 | 8 | Café | taza y `9` |
| 60 | 20 | Score | `65535` |

Separadores verticales en `x=14,39,50,59` y una regla inferior desde `x=15`
construyen la jerarquía. Ningún módulo invade el siguiente ni escribe fuera de
los 80×16 bytes del HUD.

## Identidad visual

El logo no usa la fuente general 8×8. Es un sprite preempaquetado de 196 bytes,
con 28×14 píxeles visibles:

- `BANTER` en blanco;
- `HOUSE` en magenta;
- remate cian;
- papel negro común a todo el panel.

Esta solución ocupa menos memoria residente que una segunda microfuente con su
renderer y sigue siendo legible a escala 1×. Las hojas, la taza, los números y
los separadores mantienen información por forma además de color.

## Arquitectura implementada

### Estado y formato

`src/hud_model.h/.c` define el modelo puro usado por las pruebas host y las
rutinas compartidas de formato decimal. `bh_hud_digits2` y `bh_hud_digits5`
son las mismas funciones que enlaza el Z80, por lo que los límites probados no
son una reimplementación paralela.

El renderer obtiene:

- ideas desde la máscara de piezas de campaña;
- límite de Carga desde el perfil de dificultad;
- Carga, cafés y score desde `BHCampaignState`.

### Invalidación y coste

El panel comparte la clave de composición estática existente. `score` se añadió
explícitamente a `BHRenderKey`: un cambio de score obliga a recomponer el panel
en el mismo frame lógico. En reposo, el renderer continúa restaurando sólo los
píxeles ocultos por Pitu, Alberto y el briefing; no redibuja 16 KiB por tick.

No se añadió una segunda caché ni animaciones decorativas. El análisis de enlace
demostró que esa versión reducía el margen de pila por debajo del gate de 4 KiB.
La implementación distribuida mantiene el panel estático, conserva el coste de
render anterior y protege el margen obligatorio.

### Memoria

| Métrica | Release final | Gate |
|---|---:|---:|
| High-water residente | `0x6FCD` | `< 0x7000` |
| Margen a `0x8000` | 4.146 B | `>= 4.096 B` |
| Logo empaquetado | 196 B | exacto |
| Framebuffer visible | `0xC000` | sin cambio |
| Save-under oculto | `0x8000–0x8240` | sin solape |

El build falla si el margen baja de 4.096 bytes. El requisito no se relajó para
aceptar el HUD.

## Pruebas añadidas

### Unitarias host

`tests/host/test_hud_model.c` cubre score `0`, `9`, `10`, `99`, `100`, `999`,
`1000`, `9999`, `10000` y `65535`; ideas vacías, parciales y completas; límites
defensivos de Carga y cafés; y perfiles con límites de Carga distintos.

Se ejecutan desde `tools/run_host_tests.sh` y forman parte de `make check` y
`make qa`.

### Layout y enlace

`tools/test_hud.py` valida:

- 196 bytes exactos en el logo;
- llamada de sprite 14×14 bytes/píxeles verticales;
- geometría completa con los valores máximos;
- 30 rótulos de sala dentro de pantalla;
- score presente en la clave de invalidación;
- segmento gráfico en `0x2000`;
- margen residente mínimo de 4 KiB.

`tools/test_font.py` comprueba también las cadenas máximas `*12/12`, `9` y
`65535` en ambas bases de framebuffer.

### Golden visual real

`make hud-verify` realiza una build instrumentada, arranca el DSK mediante
`LOADER.BAS` en Caprice32 configurado como CPC 6128 de 128K, entra en la primera
sala, toma una captura y la compara píxel a píxel con:

```text
tests/visual/hud-score-panel.png
SHA-256 f1a6a117c5a1bd305a722086b587ad599b81169759ccaebda1b2bf34e51a155f
```

El helper restaura siempre una release normal, incluso si la comparación falla.

### Integración y regresión

La aceptación ejecutada incluye:

- build limpia serial y paralela idénticas;
- cinco campañas completas de diez niveles;
- jefe final en las cinco dificultades;
- 10.000 ciclos de push/pop en RAM4–RAM7;
- kernel integrado de bancos, FDC, CRC y CRTC;
- carga FDC normal, CRC corrupto y sector ausente;
- reel de audio real de 75,6 segundos;
- 400 ciclos del resource manager;
- golden visual del marcador;
- release DSK y CDT restaurada al terminar.

## Comandos de aceptación

```sh
make release
make check
make hud-verify
make qa
make fdc-soak
```

## Criterios de cierre

- `BANTER/HOUSE` se reconoce a escala 1×: PASS.
- Ideas, Carga, cafés y score se leen sin abrir pausa: PASS.
- Los valores máximos caben sin solapamiento: PASS.
- Un cambio de score invalida el panel: PASS.
- El panel funciona en salas normales y jefe: PASS por matriz de campaña.
- El rendimiento estable de 25 Hz no se degrada: PASS.
- El margen residente conserva al menos 4 KiB: PASS, 4.146 bytes.
- Manual, README, ZIP, web y descargas usan la misma release: PASS tras
  empaquetado y validación pública.

Las pruebas humanas con jugadores nuevos y CPC físicos siguen siendo gates
externos; no se sustituyen por automatización ni bloquean la coherencia del
release de software publicado.
