# Audio de Banterhouse — tema MIDI y eventos AY

## Procedencia

La música principal se deriva del archivo entregado por el usuario
`music/source/banterhouse-theme.mid` (SHA-256
`66fbb74e2dad5beec272eeddd3ac36507ed164e8a7480863c3f775ad1b38b2cf`).
Sus metadatos internos identifican la obra como `RASPBERRY BERET`, artista
`Prince`, e incluyen letra sincronizada. La autorización de redistribución no
ha sido verificada de forma independiente; debe resolverse antes de publicar
este DSK/CDT. La compilación no incorpora el MIDI ni la letra: solo una
reducción de datos AY generada a partir de los primeros 28 compases.

La composición original anterior queda preservada en
`music/archive/banterhouse-briefing-chase.aks` y no participa en el build.

## Fuentes y reproducción

- MIDI congelado: `music/source/banterhouse-theme.mid`.
- Contrato de arreglo: `music/banterhouse-theme-arrangement.json`.
- Tema editable Arkos Tracker 1.0: `music/banterhouse-theme.aks`.
- Banco SFX editable Arkos Tracker 1.0: `music/banterhouse-sfx.aks`.
- Exportaciones CPCtelera: `src/banterhouse-theme.s/.h` y
  `src/banterhouse-sfx.s/.h`.
- Conversión: `AKS2DATA`/`cpct_aks2c`; el banco de efectos usa `SET_SFXONLY`.
- Reproducción: Arkos Player, AY-3-8912 a 1 MHz, una llamada a
  `cpct_akp_musicPlay()` por frame PAL de 50 Hz.
- No hay samples, MIDI en ejecución ni firmware `SOUND`.

Arkos Tracker 1.0 no importa archivos SMF. `tools/midi_smf.py` analiza el MIDI
sin dependencias y `tools/generate_aks.py` cuantiza y reduce sus voces sobre el
esquema del editor. Ambos `.aks` siguen siendo editables en Arkos y se recrean
con `make music-source`.

## Arreglo del tema

El MIDI fuente es SMF0, 4/4, 60 BPM, una pista, cinco canales GM, 5143 notas y
una polifonía máxima de 13 voces. La reducción CPC usa:

- 125 BPM (`speed 6`) y rejilla de semicorcheas.
- 14 patrones de 32 filas: 28 compases y 53,76 segundos en la primera vuelta.
- Introducción de cuatro compases; loop desde el patrón 2 al 13.
- Bucle estable de 24 compases y 46,08 segundos.
- `CUT` explícito en A, B y C al final del patrón 13.

| Canal | Contenido |
|---|---|
| A | Voz superior priorizada de los canales melódicos del MIDI, normalizada al registro AY. |
| B | Voz más grave del canal de bajo GM. |
| C | Bombo, caja, hi-hat y dos huecos de pluck por compás. |

El canal C contiene al menos seis filas vacías por patrón para admitir efectos.
A y B nunca son robados, por lo que la melodía y el bajo sobreviven a cualquier
evento de gameplay.

Instrumentos del tema: `Empty`, `Elastic MIDI Bass`, `Electric Neon Lead`,
`Clean Guitar Pluck`, `Electro Kick`, `Paper Snare` y `Neon Hat`.

## Banco SFX y prioridades

El banco de efectos es independiente del tema, tal como recomienda Arkos
Tracker. `cpct_akp_SFXInit()` recibe `0x1EA0`; cambiar los instrumentos de la
canción ya no altera la numeración de los sonidos del juego.

| Prioridad | Instrumento | Evento y punto lógico |
|---:|---|---|
| 1 | Screen Swipe | Cambio correcto de sala o nivel en `room_edge()`. |
| 1 | Office Action | Café o teléfono en `interact()`. |
| 2 | Idea Pickup | Idea, panel o recogida de jefe. |
| 2 | Briefing Shot | Creación del proyectil en `launch_briefing()`. |
| 3 | Alberto Alert | Aviso previo y alarma del jefe. |
| 4 | Contact Crunch | Impacto aceptado por `player_hit()`, después del periodo de gracia. |
| 5 | Client Victory | Pantalla final de victoria. |
| 5 | Campaign Defeat | Pantalla final de derrota. |

Todos los SFX usan el canal C. Un efecto solo sustituye al actual si su prioridad
es igual o mayor. `cpct_akp_SFXGetInstrument()` libera la prioridad al acabar;
la pista C de la música continúa en el siguiente frame. El cambio de pantalla
se dispara por estado lógico, nunca por `cpct_setVideoMemoryPage()`, que cambia
de framebuffer cada frame.

Pausa y parada ejecutan `cpct_akp_SFXStopAll()` y `cpct_akp_stop()`. Reanudar
reinicializa ambos punteros, evitando notas o ruido colgados.

## Mapa de memoria del release

| Rango | Bytes | Contenido |
|---|---:|---|
| `0x0800–0x1181` | 2434 | Tema MIDI reducido a datos Arkos. |
| `0x1182–0x12FF` | 382 libres | Margen antes de sprites invertidos. |
| `0x1300–0x1AFF` | 2048 | Sprites invertidos. |
| `0x1B00–0x1E6B` | 876 | Fuente residente. |
| `0x1E6C–0x1E91` | 38 | Trabajo del renderer. |
| `0x1EA0–0x1F6F` | 208 | Banco Arkos SFX-only. |
| `0x2000–0x305D` | 4190 | Sprites, logo y paleta. |
| `0x4000–0x6B82` | — | Código y datos residentes. |
| `0x6B83–0x7FFF` | 5245 disponibles | Pila y margen previo a vídeo. |
| `0x8000–0xBFFF` | 16384 | Framebuffer inferior. |
| `0xC000–0xFFFF` | 16384 | Framebuffer superior. |

`make sizes` calcula un high-water de `0x6B82` y exige al menos 4096 bytes de
margen. `make check` rechaza solapamientos del tema con `0x1300`, del banco SFX
con `0x2000`, cualquier high-water `>= 0x8000` y cualquier `_INITIALIZED` o
`_INITIALIZER` no vacío.

## Verificación

```bash
make parallel-build
make check
tools/run_audio_test.sh
make matrix
make release
```

La prueba de audio ejecuta Caprice32 como CPC 6128 a velocidad PAL real y
captura 75,42 segundos a 44,1 kHz/16-bit estéreo: una primera vuelta completa,
el cruce de loop, los ocho SFX, una colisión de prioridades, pausa, reanudación
y parada. Artefacto validado:
`artifacts/audio/midi-theme-events.MEV67v/audio.wav`, SHA-256
`9283ee17edcdd4b9e2f6289fdc9939d801371e628c0c010646385a409dbac6c4`.

La matriz automatizada completa los diez niveles, las tres fases del jefe y la
pantalla final en las cinco dificultades. Su `trap` y la prueba de audio dejan
siempre un build release después de ejecutar variantes de test.
