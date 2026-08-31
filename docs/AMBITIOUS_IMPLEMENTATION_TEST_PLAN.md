# Banterhouse — plan completo de implementación y pruebas

Estado: plan operativo en ejecución para `AMBITIOUS_IMPROVEMENT_PLAN.md`

> Corte verificable (30 de agosto de 2026): A0 y A1 están implementadas para
> su alcance técnico. A2 dispone de kernel bajo, bancos, FDC, dos fondos y seis
> room packs, pero todavía no de campaña Expanded jugable. El estado, hashes y
> evidencias vigentes están en [`IMPLEMENTATION_STATUS.md`](IMPLEMENTATION_STATUS.md).
> Las cifras y carencias de la sección 2 se conservan como baseline congelada,
> no como descripción del árbol actual.

Base técnica: build actual, `DISK_RESOURCE_ARCHITECTURE.md`, canon de juego y planes de pruebas existentes

Objetivo: transformar el juego funcional actual en la edición DSK/128K de “tira de oficina jugable” sin perder una versión arrancable, medible y recuperable en ningún hito

## 1. Resultado que debe entregar este plan

La versión 1.0 debe contener:

- Diez plantas y treinta salas terminadas.
- Pitu canónica dentro del sistema visual de papel, tinta y color semántico.
- Alberto con aviso visual y sonoro siempre legible.
- Una identidad visual, mecánica y sonora diferenciada por planta.
- HUD, menú, mapa, briefings, jefe, final y créditos dentro del mismo lenguaje editorial.
- Recursos intercambiables desde DSK, caché explícita en 128K y carga sólo en puntos seguros.
- Cinco dificultades con las mismas reglas y soluciones, parametrizadas mediante datos.
- DSK Expanded como edición principal; DSK/CDT Classic conservados hasta RC.
- Build reproducible, matriz de regresión, pruebas de memoria, rendimiento, compatibilidad, canon y juego humano.

La duración A0–A6 se mantiene en **98–155 días-persona**. El trabajo de pruebas está incluido en cada fase; no existe una fase final destinada a descubrir por primera vez que el juego no cabe o no se entiende.

El Director's Cut A7 añade 20–35 días-persona y permanece fuera de v1.0.

## 2. Línea base congelada antes de la implementación: 30 de agosto de 2026

La referencia no es el prototipo histórico descrito al inicio de `IMPLEMENTATION_PLAN.md`, sino el estado actual del repositorio.

### 2.1 Lo que ya funciona

| Área | Evidencia actual |
|---|---|
| Build | `make`, `make clean-build`, `make parallel-build`, `make release` |
| Estática | `make check` valida fuente musical, AKS, fuente, Pitu y memoria |
| Campaña | Diez niveles lógicos, treinta habitaciones procedurales y jefe |
| Dificultad | Cinco perfiles ejecutados por `make matrix` |
| Vídeo | Mode 0 y doble framebuffer en `0x8000`/`0xC000` |
| Personajes | Pitu y Alberto dibujables en ambas direcciones |
| Audio | Tema AY, ocho SFX, prioridades y pruebas de ciclo de vida |
| Texto | Fuente residente 8×8 sin firmware |
| Medios | DSK y CDT arrancables mediante `LOADER.BAS` |
| Evidencias | Capturas, audio, logs, hashes y resultados bajo `artifacts/` |

Baseline medido durante esta auditoría:

- `make check`: PASS.
- High-water residente: `0x6B82`.
- Margen hasta vídeo/pila informado: 5.245 B.
- `obj/banterhouse.bin`: 25.429 B.
- `banterhouse.dsk`: 204.544 B de imagen de disco.
- `banterhouse.cdt`: 26.425 B.
- `game.c`: 840 líneas y concentra estado, mundo, IA, render, jefe y autotest.
- Las cinco evidencias conservadas de dificultad terminan en `BH_PASS`.

### 2.2 Gaps identificados en la baseline

| Gap | Consecuencia |
|---|---|
| Salas dibujadas proceduralmente | No pueden producirse treinta viñetas ricas sólo con datos |
| Código en `0x4000` | Impide usar RAM4–RAM7 como caché real |
| Sin `BHRES.BIN` ni lector FDC | El DSK todavía es medio de arranque, no almacén dinámico |
| `game.c` monolítico | Un cambio visual puede alterar IA, progreso o autotest |
| Sin unitarias host | La lógica sólo se comprueba dentro del binario Z80 |
| `make matrix` recorre cinco campañas dirigidas | Demuestra terminación, no todas las rutas ni equivalencia con juego manual |
| Sin replays de input con hashes | No hay detector fino de cambios de comportamiento |
| Sin comparación automática de capturas | La regresión visual depende de revisión manual |
| Sin profiler automatizado por sala | El gate de 25 Hz aún no se aplica a cada peor caso |
| Sin fault injection de disco | CRC, disco ausente y timeout sólo están diseñados |
| Sin suite CRTC/hardware | Un HUD multi-mode no puede promoverse a producto |

Varios gaps de esta tabla ya están cerrados. La clasificación actual vive en
`IMPLEMENTATION_STATUS.md`. No se debe marcar un elemento de `TEST_PLAN.md`
como implementado sólo porque está descrito allí: la evidencia ejecutada manda
sobre la intención documental.

## 3. Contratos no negociables

### 3.1 Producto

- v1.0 son diez plantas y treinta salas.
- Cada sala contiene `LANDMARK / VERBO / REGLA / GIRO / REMATE / SALIDA SEGURA`.
- No se añade combate, scroll continuo, segundo jugador ni física completa.
- No hay trampas invisibles, daño obligatorio ni solución dependiente de muerte previa.
- Una planta puede reducir detalle antes que perder lectura, rendimiento o reserva de disco.

### 3.2 Canon visual

- Pitu no se rediseña; cada frame nuevo pasa comparación de máscara y píxel.
- La paleta conserva los colores semánticos acordados.
- Negro, papel, cian, magenta y amarillo no pueden cambiar de significado entre plantas.
- Una información crítica combina forma, posición, animación, texto o sonido; nunca depende sólo de color.
- El reparto literal no se distribuye públicamente sin permiso.

### 3.3 Hardware

- Objetivo: Amstrad CPC 6128 clásico, PAL, 128K, DSK de 40 tracks.
- Lógica a 25 Hz; audio a 50 Hz.
- Framebuffers primarios en `0x8000` y `0xC000`.
- No se requieren CPC+, overscan, interlace ni raster estable para terminar el juego.
- El split Mode 1/Mode 0 y wipes CRTC son experimentos con fallback software/Mode 0.
- Ninguna carga de disco ocurre durante una decisión de gameplay.

### 3.4 Memoria y disco

- Núcleo y estado deben terminar por debajo de `0x4000` para la edición Expanded.
- RAM4 render ≤14 KiB; RAM5 habitación ≤14 KiB; RAM6 audio ≤12 KiB.
- RAM7 reserva ≤14 KiB para staging y ≤2 KiB para índice compacto.
- `BHRES.BIN` objetivo: 100–120 KiB; límite 130 KiB.
- Reserva DSK ≥10 KiB en v1.0.
- Recursos de v1.0 son de sólo lectura.
- Ningún puntero a una ventana bancaria sobrevive a `bank_pop()`.

### 3.5 Calidad

- `main` no recibe una integración que rompa Classic o Expanded.
- Cero P0/P1 para cerrar cualquier fase.
- Cero P2 de gameplay conocidos para RC salvo excepción firmada y con mitigación.
- Un resultado sin build ID, hash, entorno y evidencia no cuenta como prueba.

## 4. Variantes de build durante la migración

| Variante | Propósito | Artefacto |
|---|---|---|
| Classic | Oráculo de regresión y rollback | `banterhouse-classic.dsk` y CDT |
| Expanded | Producto DSK/128K con recursos | `banterhouse-expanded.dsk` |
| QA | Expanded con guards, telemetría y selectores | `banterhouse-qa.dsk` |
| Lab | Experimentos FDC/CRTC aislados | DSK no distribuible |

Flags iniciales:

```make
DISK_RESOURCES ?= 0
RESOURCE_LAYOUT ?= container
STORAGE_BACKEND ?= fdc
BH_VISUAL_V2 ?= 0
BH_QA ?= 0
```

Reglas:

- El valor `0` mantiene el comportamiento y los artefactos actuales hasta que Expanded sea RC.
- Lab no comparte nombre de salida con Classic o Expanded.
- Ningún experimento cambia el formato de save; v1.0 conserva passwords/checkpoints.
- Classic sólo se retira después de dos RC Expanded verdes y una prueba de hardware satisfactoria.
- CDT Classic se preserva; no se promete CDT Expanded.

## 5. Arquitectura de código objetivo

La separación se hace mediante extracciones que no cambian comportamiento. No se reescribe el juego completo de una vez.

```text
src/
  app/          arranque, estados globales y bucle principal
  core/         timing, input, bancos, asserts, debug y estado serializable
  world/        plantas, salas, transiciones, progreso y room scripts
  entity/       Pitu, Alberto, briefing y entidades ligeras
  systems/      colisión, interacción, IA, pickups y boss
  render/       compositor, tilemap, sprites, HUD, texto y transiciones
  storage/      FDC, contenedor, recursos, CRC y codecs
  audio/        player, escenas, SFX y bancos de audio
  data/         tablas residentes e IDs generados
assets-src/
  rooms/        TMX y propiedades de sala
  graphics/     PNG/XCF fuente y paletas
  dialogue/     textos y escenas
  audio/        AKS y manifest
assets/
  resources.yml
generated/
  resource_ids.h, índices, packs y reportes regenerables
tests/
  host/         lógica pura y parsers
  fixtures/     contenedores, mapas y corrupciones controladas
tools/
  packer, inspectores, capturas, replays y QA
```

El Makefile actual descubre subdirectorios de `src/` a un nivel; esta estructura respeta ese límite.

### 5.1 Estado de juego

Todo estado que afecte a un hash o replay se reúne progresivamente en structs explícitos:

```c
typedef struct {
   u8 level;
   u8 room;
   u8 difficulty;
   u8 carga;
   u8 cafes;
   u16 pieces;
   u16 room_flags;
   u16 tick;
} CampaignState;

typedef struct {
   PlayerState player;
   AlbertoState alberto;
   ProjectileState briefing;
   BossState boss;
   CampaignState campaign;
} GameState;
```

Condiciones:

- El renderer recibe estado y no modifica progreso.
- Input se traduce a un bitfield estable antes de actualizar lógica.
- IA no lee teclado ni dibuja.
- Cambio de sala prepara recursos y sólo hace commit tras éxito.
- Dificultad vive en una tabla; ningún mapa duplica cinco scripts.
- El autotest usa las mismas funciones públicas que el juego y declara cualquier colocación directa como fixture, no como movimiento equivalente.

### 5.2 Sala dirigida por datos

```text
RoomDesc
  id / level / palette
  tilemap / collision / decor / patches
  entries / safe_spawns / doors
  landmark / verb / rule / twist / payoff
  interactions / scripts / persistent_flags
  resource_dependencies / audio_scene
  test_route / worst_case_fixture
```

Una sala nueva no puede requerir editar `switch(level)` o `switch(room)` en el motor. Las excepciones del jefe se encapsulan en su controlador.

### 5.3 Render

Orden fijo:

1. Componer sala base en ambas páginas durante entrada.
2. Aplicar decorado/patch persistente.
3. Dibujar HUD y elementos editoriales.
4. Por tick, restaurar regiones sucias.
5. Dibujar props activos, NPC, Alberto, briefing y Pitu.
6. Presentar una única página.

El fondo no se redibuja completo durante gameplay. Cada sprite declara ancho, alto, stride, máscara y bounding box; no hereda las dimensiones de Pitu.

### 5.4 Recursos

Se adopta sin cambios el contrato de `DISK_RESOURCE_ARCHITECTURE.md`:

- Manifest `assets/resources.yml` con IDs explícitos y estables.
- Contenedor versionado `BHRES.BIN` con magic `BHRS`, build ID, índice, dependencias y CRC16.
- Compresión `none` o ZX7B según ahorro real.
- Slots de caché con propietario y generación; sin LRU.
- API `resource_load/get/unload`, `bank_push/pop` y `room_enter` transaccional.
- Cargas síncronas durante ascensor, puerta, briefing o corte.
- Backend FDC con timeout y retry limitado.

## 6. Mapa maestro de fases

| Fase | Días-persona | Acumulado | Resultado integrado |
|---|---:|---:|---|
| A0 — Baseline y laboratorio | 5–8 | 5–8 | Dirección elegida y oráculo congelado |
| A1 — Seams y prueba de disco | 8–12 | 13–20 | Código separable y dos recursos externos |
| A2 — Sistema visual y vertical slice | 15–24 | 28–44 | Seis salas finales sobre Expanded |
| A3 — Fábrica de contenido | 8–12 | 36–56 | Sala nueva sin tocar motor |
| A4 — Campaña completa | 35–55 | 71–111 | Plantas 1–9 y 27 salas terminadas |
| A5 — Consejo, escenas y audio | 15–24 | 86–135 | Nivel 10, final y audio completo |
| A6 — Alpha, RC y release | 12–20 | 98–155 | Paquete v1.0 reproducible y probado |

Dependencia crítica:

```text
BASELINE → SEAMS → FDC/RECURSOS → SLICE → PIPELINE → CAMPAÑA → JEFE → RC
                  └──────────── arte A0/A1 ────────────────┘
```

Arte puede explorar en paralelo, pero ningún asset masivo entra antes de los gates A0 y A2.

## 7. A0 — Baseline y laboratorio de estilo (5–8 días)

### 7.1 Implementación

1. Registrar commit, toolchain, configuración PAL y hashes de DSK/CDT/BIN.
2. Ejecutar y archivar `clean-build`, `parallel-build`, `check`, `matrix`, `audio-verify` y `release`.
3. Añadir un manifiesto de baseline con high-water, tamaños y hashes.
4. Capturar menú, HUD en ambas páginas, una sala, jefe, victoria y derrota.
5. Crear tres mockups convertidos a restricciones CPC: menú, “Todo clarísimo” y briefing.
6. Comparar HUD Mode 0 con split Mode 1/Mode 0 en un harness separado.
7. Medir tamaño raw/comprimido de cada mockup y worst-case de dibujo.
8. Elegir una sola paleta semántica, plantilla de sala y tratamiento de bocadillo.

### 7.2 Pruebas

- Dos builds limpios consecutivos producen los mismos payloads; se permite que la imagen DSK difiera sólo si se documenta el campo variable.
- Classic arranca desde DSK y CDT.
- Las cinco campañas actuales producen `BH_PASS`.
- Capturas de `0x8000` y `0xC000` contienen el mismo HUD.
- Pitu pasa el checker actual sobre cada fondo candidato.
- Mockups se revisan a 1×, monitor color, monitor verde y escala de grises.
- Cinco personas identifican en cinco segundos objetivo, salida e interacción del mockup de sala.
- El split se prueba al menos en CRTC 0, 1, 2 y 4 o se descarta.

### 7.3 Gate A0

- Baseline reproducible y localizable por build ID.
- Dirección visual aprobada con mediciones, no sólo con una imagen grande.
- Ninguna técnica experimental es requisito del renderer.
- Presupuesto preliminar cabe en 100–120 KiB de recursos.

Rollback: no cambia el juego. Los mockups rechazados quedan fuera del manifest.

## 8. A1 — Seams de código y prueba real de recursos (8–12 días)

### 8.1 Extracción sin cambio de comportamiento

Orden obligatorio:

1. Extraer estado de campaña y perfiles de dificultad.
2. Extraer input y bitfield de acciones.
3. Extraer renderer/HUD sin cambiar bytes visuales.
4. Extraer Pitu, Alberto y briefing.
5. Extraer progreso, cambio de sala y jefe.
6. Mantener adaptadores en `game.c` hasta que cada extracción pase regresión.
7. Añadir `game_state_hash()` y ring buffer de 32 eventos en QA.

No se combina esta extracción con un rediseño gráfico en el mismo cambio.

### 8.2 Packer y lector mínimo

1. Crear `assets/resources.yml` con dos fondos raw alineados a sector.
2. Generar un `BHRES.BIN` pequeño con magic, versión, build ID, tamaños y CRC.
3. Añadir inspector host que liste y extraiga cada entrada.
4. Verificar round-trip byte a byte.
5. Insertar el contenedor primero en un DSK Lab de 40 tracks y verificar contigüidad.
6. Implementar lector FDC de un sector con timeout, retry y error visible.
7. Implementar `storage_read_range()` sin paginar `0x4000` todavía.
8. Mostrar dos fondos consecutivos desde DSK en la página oculta, sustituyendo el primero.
9. Detener/silenciar AY antes del I/O y restaurarlo después.

### 8.3 Pruebas

- Las extracciones mantienen hashes de estado para fixtures de menú, nivel 1, transición, burnout y jefe.
- Classic conserva capturas baseline donde no haya cambio autorizado.
- Cien ciclos de carga alternan ambos fondos sin cambiar estado, página no objetivo ni guards.
- Magic, versión, build ID y CRC incorrectos producen error recuperable.
- Disco ausente y timeout terminan en reintento limitado; nunca en wait infinito.
- Audio no deja nota sostenida al entrar o salir del loader.
- Stack conserva al menos 256 B en el harness.
- La prueba pasa en Caprice32 y CPC 6128 real antes de convertir el loader en dependencia de producto.

### 8.4 Gate A1

- `game.c` deja de poseer al menos estado, input y render.
- Dos fondos no aparecen dentro del núcleo y se muestran desde DSK sin volver a BASIC.
- `DISK_RESOURCES=0` restaura Classic sin parches manuales.
- Toda lectura FDC tiene timeout y código de error.

Rollback: compilar Classic; conservar packer/inspector como tooling sin activar el runtime.

## 9. A2 — Sistema visual y vertical slice Expanded (15–24 días)

### 9.1 Núcleo bajo y bancos

1. Construir `BHBOOT.BIN` y relocalizar `BHKERN.BIN` bajo `0x4000`.
2. Reservar estado, sector buffer, guards y al menos 1 KiB de pila.
3. Implementar `bank_push/pop` con profundidad comprobada.
4. Escribir y releer patrones distintos en RAM4–RAM7.
5. Añadir `ResourceHandle {bank,address,size,generation}`.
6. Cargar índice compacto en RAM7 y copiar descriptor antes de paginar.
7. Implementar codecs `none` y ZX7B con staging no solapado.
8. Crear slots: render RAM4, room RAM5, audio RAM6, staging/índice RAM7.

### 9.2 Sistema visual común

1. Integrar tiles `PAPER/INK/ARCH/OFFICE/ACTION`.
2. Implementar compositor de room pack para ambas páginas.
3. Integrar HUD editorial, menú, pausa/storyboard y transición de viñeta.
4. Implementar feedback de pickup, alerta, impacto, checkpoint y burnout.
5. Añadir poses de aviso/recuperación de Alberto y telegraph en puerta.
6. Añadir retrato/bocadillo mínimo y dos NPC de fondo.
7. Mantener Pitu canónica; sólo se permiten frames funcionales aprobados.

### 9.3 Vertical slice

- Plantas 1 y 2 completas: seis salas.
- Cada sala usa un room pack y descriptor propio.
- Art y Carlitos dirigen escenas sin nueva IA general.
- Teléfono, cobertura, escondite, pickup, salida y Carga funcionan.
- Briefing inicial y dos variaciones musicales.
- Cambio de planta carga pack de área durante ascensor/cartela.

### 9.4 Pruebas

- 10.000 cambios de banco sin corrupción en emulador.
- Cien `resource_load/unload` por cada tipo inicial: screen, room, tiles, sprite y texto.
- Dependencia ausente, ciclo, tamaño excesivo, CRC malo y generación caducada fallan de forma controlada.
- Cien transiciones entre seis salas preservan estado y componen ambas páginas.
- Las seis salas pasan test estático de spawn, puertas, ruta, salida segura y working set.
- Pitu/Alberto se distinguen en las cuatro familias de fondo.
- Peor sala mantiene ≤40 ms; objetivo ≤36 ms.
- Audio tick ≤2 ms objetivo y nunca >3 ms repetido.
- Una persona nueva completa ambas plantas sin explicación oral.
- Cuatro de cinco testers identifican objetivo/salida/interacción en cinco segundos.
- Todas las personas detectan el primer aviso de Alberto antes del lanzamiento.

### 9.5 Gate A2

- Expanded supera el slice en Caprice32 y CPC real.
- Classic sigue compilando y completando sus cinco campañas.
- Ningún recurso excede su slot; quedan ≥10 KiB proyectados de DSK.
- Aprobación explícita del lenguaje visual antes de crear las otras 24 salas.

Rollback: publicar el slice como demo Expanded y mantener campaña Classic completa.

## 10. A3 — Fábrica de contenido y QA de datos (8–12 días)

### 10.1 Tooling

Implementar:

- Conversor TMX → tilemap, colisión, spawns, puertas, interacciones y patches.
- Compilador de room scripts con opcodes limitados y presupuesto por tick.
- Packer determinista de `BHRES.BIN`.
- Generador de `resource_ids.h` y descriptores.
- Inspector/extractor del contenedor.
- Verificador de DSK: 40 tracks, extents contiguos, capacidad y build ID.
- Informe por recurso: raw, comprimido, ratio, destino, dependencias y working set.
- Preview automático color/verde/gris a tamaño 1×.
- Captura automatizada de cada sala en ambas páginas.
- Linter de textos para ancho, líneas, glifos y vocabulario reservado.

### 10.2 Esquema de sala

El build rechaza:

- Mapa distinto de 20×23 o tile fuera de rango.
- Spawn fuera de zona libre o sin fallback seguro.
- Puerta sin destino válido/recíproco cuando corresponda.
- Salida u objetivo inalcanzable.
- Dependencia sólo de color.
- Interacción sin estado inicial/final.
- Patch que encierre a Pitu o cierre todas las salidas.
- Landmark ausente o fuera del presupuesto visual.
- Texto que exceda bocadillo o use glifo inexistente.
- Recurso, working set, índice o disco por encima de límite.
- ID duplicado, retirado/reutilizado o dependencia cíclica.

### 10.3 Unitarias host

Separar lógica pura de CPCtelera y cubrir:

- Movimiento saturado y colisión en bordes.
- Entrada/salida y cooldown de puerta.
- Línea de visión, cobertura y escondite.
- Máquina/ruido y selección de destino de Alberto.
- Estados de aviso, tiro, búsqueda, recuperación y salida.
- Carga, café, burnout y persistencia.
- Piezas, checkpoint/password y progresión.
- Cinco perfiles y límites de tablas.
- Tres fases del boss mediante controlador sin render.
- Parser del manifest, DAG, codecs, CRC y asignador de slots.

Las unitarias usan tablas de casos y pruebas de fronteras; no duplican todo el motor en otra implementación.

### 10.4 Gate A3

- Borrar `generated/` y reconstruir produce exactamente los mismos outputs.
- Una séptima sala entra desde fuente editable sin modificar código del motor.
- `make resource-check`, `make host-tests` y `make screenshots` son parte de `make check` Expanded.
- Los errores de autoría fallan antes de arrancar el emulador y explican recurso/campo.

Rollback: seguir produciendo con las herramientas validadas del slice; no añadir salas manuales al binario.

## 11. A4 — Migración de la campaña completa (35–55 días)

Se produce por lotes. Ningún lote comienza si el anterior tiene P0/P1 o excede presupuesto.

### 11.1 Lote C1 — Plantas 3 y 4

- Túnel Pantone, mesa de luz, cuarto oscuro, repro y fotocopiadora.
- Salto contextual y ciclo de máquina con anticipación.
- Primer storyboard/checkpoint.
- Prueba de patches, ruta segura y transición de área.

### 11.2 Lote C2 — Plantas 5 a 7

- Reunión, premios y noche.
- Cristal con dos configuraciones seguras.
- Viento que mueve papel, no Pitu.
- Luz que modifica visión sin cambiar canon.
- Cameo del Presidente y segundo checkpoint.

### 11.3 Lote C3 — Plantas 8 y 9

- Ranking, fax remoto, atajo privado y proyector.
- Persistencia visible de Alberto entre hasta tres habitaciones.
- Preview de patches antes de que cambien una ruta.
- Doce piezas y desbloqueo del Consejo.

### 11.4 Pruebas por cada sala

Automáticas:

- Descriptor y manifest válidos.
- Ruta principal, ruta experta y retorno desde cada puerta.
- Entrada segura y fallback de spawn.
- Objetivo alcanzable antes y después de patches.
- Burnout y reentrada desde cada habitación.
- Hash de estado para ruta normal y alternativa.
- Captura color/verde/gris y ambas páginas.
- Working set, tamaño comprimido y peor frame.

Manuales:

- Test de lectura de cinco segundos.
- Primera exposición a la regla sin daño obligatorio.
- El tester puede explicar causa de detección/impacto.
- El gag no bloquea input ni debe releerse en reintento.
- Sala distinguible por landmark a tamaño 1×.

### 11.5 Pruebas por cada lote

- `make clean-build`, `parallel-build`, `check`, `resource-check` y `matrix`.
- Campaña Expanded desde nueva partida hasta el último nivel del lote.
- Inicio desde cada checkpoint/password del lote.
- Ruta óptima, ruta directa y ruta contraria en Normal.
- Una pasada de las plantas del lote en las cinco dificultades.
- 1.000 transiciones automatizadas acumuladas sin guards alterados.
- Capturas revisadas contra biblia visual y repetición de landmarks.
- Informe de disco conserva ≥10 KiB de reserva.

### 11.6 Gate A4

- Plantas 1–9 completables desde nueva partida y cada checkpoint.
- Veintisiete salas distinguibles por captura y navegación.
- Las doce piezas y flags persistentes coinciden en Classic/Expanded donde las reglas no cambiaron.
- Ninguna planta repite la misma combinación de regla y remate.
- Los cinco perfiles son vencibles sin daño obligatorio.

Rollback: congelar en el último lote completo. Nunca integrar una planta con salas a medio arte o sin rutas verificadas.

## 12. A5 — Consejo, final, escenas y audio completo (15–24 días)

### 12.1 Jefe

1. Extraer `BossState` y controlador independiente de Alberto.
2. Componer Presidente como fondo y overlays mínimos.
3. Fase 1: cuatro paneles únicos y entrada anunciada.
4. Fase 2: patches `GRANDE/PEQUEÑO` sólo durante corte seguro.
5. Fase 3: fax, alineación de briefing y bandeja destructible.
6. Checkpoint por fase al consumir café.
7. Sellos, stingers y feedback sin texto durante la ventana activa.

### 12.2 Escenas y UI final

- Briefing de entrada de cada planta.
- Intermedios de tres paneles como máximo.
- Final, expediente de estadísticas y créditos.
- Menú, pausa, passwords y derrota con el mismo sistema editorial.
- Skip inmediato y relectura del último briefing desde pausa.

### 12.3 Audio

- Audio común y packs por área en RAM6 si el gate bancario es estable.
- Cinco motivos/temas y stingers finales.
- Prioridades: alerta > impacto > pickup > transición > decoración.
- Cambio de tema sólo durante corte/transición.
- Silencio deliberado durante I/O; no se promete streaming entre ticks.
- Sustituir o licenciar la fuente musical actual antes de RC público.

### 12.4 Pruebas

- Cien replays válidos de cada fase del jefe sin softlock.
- Cada fase se completa en cinco dificultades con la misma solución.
- Burnout reinicia sólo la fase acordada y conserva sellos previos.
- Patches nunca encierran a Pitu ni alteran la página visible a medias.
- Cincuenta cambios de escena/audio sin banco incorrecto ni nota colgada.
- Pausa/reanudación 500 veces en escena, gameplay y jefe.
- Todos los textos caben, hacen skip y pueden releerse.
- Final se dispara una sola vez; estadísticas y dificultad coinciden con estado.
- Retratos y NPC pasan canon a 1×.

### 12.5 Gate A5

- Campaña completa desde portada hasta créditos en Expanded.
- Las cinco dificultades terminan mediante automatización y una pasada manual de Normal.
- Jefe mantiene 25 Hz en su peor fase.
- Audio y escenas caben dentro de RAM6, staging y presupuesto DSK.

Rollback: usar jefe funcional actual con presentación A1; reducir poses/escenas antes que modificar campaña.

## 13. A6 — Alpha, RC y release (12–20 días)

### 13.1 Congelaciones

- Feature freeze al entrar en alpha.
- Content freeze tras cerrar los doce playtests.
- String freeze antes de manual/packaging final.
- Toolchain y manifest freeze en RC1.
- Después de RC1 sólo entran fixes con caso reproducible y análisis de invalidación.

### 13.2 Optimización

1. Medir, no adivinar: borde por input, audio, lógica, IA, restore y draw.
2. Registrar peor frame por sala/fase.
3. Reducir overdraw y dirty regions.
4. Mover a ensamblador sólo hotspots demostrados.
5. Repetir captura y hash tras cada optimización.
6. Conservar fallback de efectos CRTC.

### 13.3 Compatibilidad

- Caprice32 con 128K/PAL.
- Segundo emulador independiente.
- CRTC 0/1/2/4 si existe split o wipe dependiente del CRTC.
- Monitor color y verde.
- Teclado QAOP, cursores y joystick real.
- CPC 6128 real: arranque, disco frío/caliente, audio, vídeo y campaña representativa.
- DSK cambiado/ausente/write-protected en rutas de error de sólo lectura.

### 13.4 Playtest

- Vertical slice: cinco personas nuevas.
- Alpha: doce personas entre experiencia CPC y jugadores nuevos.
- Sesión del usuario: campaña Normal y extremos definidos en `TEST_PLAN.md`.
- Registrar tiempos, rutas, impactos injustos percibidos, burnouts, dudas y momentos de risa/frustración.
- Separar observación literal, inferencia y acción tomada.

### 13.5 Gate de release

El RC sólo se etiqueta si:

- Todos los targets rápidos y extendidos están verdes.
- Cero P0/P1 y cero P2 de gameplay conocidos.
- Las treinta salas completan rutas principal y alternativa.
- Las 50 combinaciones nivel/dificultad tienen caso ejecutado y resultado.
- Cinco campañas completas Expanded, una por dificultad, terminan sobre el mismo candidato.
- Una campaña manual Normal va de portada a créditos sin selector debug.
- Peor frame ≤40 ms repetido; objetivo típico ≤36 ms.
- Stack, guards, bancos, CRC y handles permanecen correctos tras soak.
- DSK arranca en dos implementaciones, una de ellas CPC real si está disponible.
- Pitu, Alberto, NPC, textos, música y derechos pasan revisión.
- Reserva DSK ≥10 KiB.
- Manual, créditos, licencias, hashes, mapa de memoria e informe QA acompañan al paquete.

Rollback de release: DSK/CDT Classic y demo Expanded del último gate verde. No se publica un Expanded inestable para cumplir una fecha.

## 14. Estrategia completa de pruebas

### 14.1 Pirámide aplicada al CPC

| Capa | Frecuencia | Qué detecta |
|---|---|---|
| Validación estática | Cada cambio | Assets, manifest, mapas, memoria y texto inválidos |
| Unitarias host | Cada cambio de lógica/tooling | Fronteras, estados y formatos |
| Build Z80 | Cada integración | Link, ABI, mapa, código real |
| Integración Caprice32 | Cada integración relevante | Vídeo, bancos, input, audio y disco |
| Replays/hash | Cada cambio de motor/contenido | Regresión determinista |
| Capturas goldens | Cada cambio visual | Canon, páginas, HUD y composición |
| Matriz | Cada lote/hito | Niveles, dificultad y progreso |
| Rendimiento/soak | Hito, alpha y RC | Timing, stack y corrupción tardía |
| Manual/humano | Slice, alpha y RC | Lectura, justicia, ritmo y diversión |
| Hardware | A1, A2, alpha y RC | FDC, CRTC, joystick, AY y monitor reales |

### 14.2 Targets existentes que se conservan

```text
make clean-build
make parallel-build
make check
make sizes
make matrix
make audio-verify
make release
```

`make matrix` actual se renombra conceptualmente como `campaign-smoke`: sus colocaciones directas prueban progresión y terminación, pero no sustituyen rutas de input.

### 14.3 Targets que deben añadirse

```text
make host-tests          lógica pura, parsers y codecs
make resources           genera BHRES.BIN e IDs
make resource-check      manifest, DAG, CRC, round-trip, slots y DSK
make resource-report     tamaños por recurso/área/banco
make expanded-dsk        build DSK/128K
make expanded-smoke      arranque y dos salas en Caprice32
make replay              replays dorados y hashes
make matrix              10 niveles × 5 dificultades
make screenshots         capturas estáticas de ambas páginas
make visual-check        pixel diff, canon y previews color/verde/gris
make performance         fixtures de peor frame
make soak                campañas/transiciones/bancos prolongados
make qa                  suite de hito sin playtest humano
make rc                  build limpio + suite completa + paquete de evidencia
```

La evolución de `make matrix` debe preservar un target rápido separado para no convertir cada cambio de texto en una espera innecesaria.

### 14.4 Programación de suites

| Evento | Suite mínima |
|---|---|
| Cambio de documento | Links/formato; sin build salvo contrato técnico |
| Asset fuente | `resource-check`, visual y tamaño |
| Room data | Host, recurso, replay de sala y captura |
| Lógica | Host, build Z80, smoke y replays afectados |
| Banco/loader | Todo lo anterior + fault injection + soak bancario |
| Audio | Check AKS, ciclo de vida, peor frame y captura WAV |
| Cierre de lote | Clean/parallel/check/matrix/performance |
| Alpha | Suite QA + segundo emulador + playtest |
| RC | Suite completa desde checkout limpio + hardware |

## 15. Catálogo mínimo de pruebas automatizadas

### 15.1 Build y reproducibilidad

- `BLD-01`: build serial desde árbol limpio.
- `BLD-02`: build paralelo desde árbol limpio.
- `BLD-03`: dos builds iguales producen BIN, recursos e IDs idénticos.
- `BLD-04`: no quedan outputs QA dentro de release.
- `BLD-05`: build ID coincide entre kernel, contenedor e informe.
- `BLD-06`: outputs generados se regeneran sin edición manual.
- `BLD-07`: Classic y Expanded usan nombres distintos.

### 15.2 Recursos y disco

- `RES-01`: magic/versión correctos.
- `RES-02`: ID explícito, único y estable.
- `RES-03`: DAG sin ciclos ni dependencia ausente.
- `RES-04`: round-trip raw/ZX7B byte a byte.
- `RES-05`: CRC de payload e índice.
- `RES-06`: límites de staging y destino.
- `RES-07`: alias AMSDOS válido cuando exista.
- `RES-08`: contenedor contiguo y primer sector correcto.
- `RES-09`: DSK usa 40 tracks y conserva reserva.
- `RES-10`: build ID incorrecto se rechaza.
- `RES-11`: recurso truncado/corrupto no hace commit.
- `RES-12`: load/unload invalida generaciones antiguas.
- `RES-13`: retry tiene máximo conocido.
- `RES-14`: error restaura banco, AY, página y sala previa.

### 15.3 Memoria y bancos

- `MEM-01`: linker no solapa núcleo, estado, buffers o pila.
- `MEM-02`: patrones diferentes sobreviven en RAM4–RAM7.
- `MEM-03`: 10.000 `bank_push/pop` restauran configuración.
- `MEM-04`: profundidad excesiva de stack bancario falla en QA.
- `MEM-05`: guards de mapa, entidades, audio e índice intactos.
- `MEM-06`: stack high-water conserva margen acordado.
- `MEM-07`: handle de generación vieja no se usa.
- `MEM-08`: framebuffer no objetivo conserva checksum durante I/O.
- `MEM-09`: room pack y audio no compiten por ventana.
- `MEM-10`: campaña completa conserva hashes de datos inmutables.

### 15.4 Mapas y sala

- `MAP-01`: 20×23 y tile IDs válidos.
- `MAP-02`: spawn y fallback libres.
- `MAP-03`: puertas/destinos consistentes.
- `MAP-04`: objetivo y salida alcanzables.
- `MAP-05`: ruta segura sin daño obligatorio.
- `MAP-06`: patches preservan al menos una salida.
- `MAP-07`: interacción tiene estados y cooldown.
- `MAP-08`: flags persistentes no colisionan.
- `MAP-09`: dependencia visual no usa sólo color.
- `MAP-10`: landmark y test fixture declarados.

### 15.5 Lógica, IA y dificultad

- `LOG-01`: movimiento se satura en límites.
- `LOG-02`: colisión usa bbox interior correcta.
- `LOG-03`: puerta concede gracia y evita rebote inmediato.
- `AI-01`: Alberto sólo sabe lo observado/señalado.
- `AI-02`: aviso precede siempre al briefing.
- `AI-03`: ruido cambia destino durante tiempo limitado.
- `AI-04`: pérdida de visión lleva a última posición.
- `AI-05`: spawn ocupado usa fallback.
- `AI-06`: todos los estados tienen salida.
- `DIF-01`: tabla contiene exactamente cinco perfiles.
- `DIF-02`: sólo cambian campos autorizados.
- `DIF-03`: Alberto nunca supera la velocidad máxima de Pitu.
- `DIF-04`: cada solución funciona en los cinco perfiles.
- `PRO-01`: pieza se persiste antes del feedback.
- `PRO-02`: burnout conserva/descarta sólo lo especificado.
- `PRO-03`: checkpoint restaura nivel, dificultad y piezas.

### 15.6 Render y canon

- `VID-01`: ambas páginas componen la misma sala.
- `VID-02`: sprite no deja rastro en fondo no uniforme.
- `VID-03`: cada sprite usa su stride/bbox.
- `VID-04`: HUD no parpadea al cambiar página/banco.
- `VID-05`: patch modifica ambas páginas durante corte.
- `VID-06`: Pitu pasa máscara/píxel en todos sus frames.
- `VID-07`: texto cabe y usa glifos existentes.
- `VID-08`: información crítica sigue visible en gris/verde.
- `VID-09`: golden estático sólo cambia con aprobación explícita.
- `VID-10`: frame animado compara regiones estables y máscara permitida.

### 15.7 Audio e input

- `AUD-01`: player recibe 50 ticks/s.
- `AUD-02`: alerta conserva máxima prioridad.
- `AUD-03`: SFX roba sólo el canal previsto.
- `AUD-04`: stop/restart no deja nota.
- `AUD-05`: load silencia y restaura escena correcta.
- `AUD-06`: cincuenta cambios de escena no corrompen banco.
- `INP-01`: QAOP, cursores y joystick mapean las mismas acciones.
- `INP-02`: opuestos cancelan el eje.
- `INP-03`: acción mantenida no redispara sin soltar.
- `INP-04`: pausa no deja input fantasma.

### 15.8 Jefe y final

- `BOS-01`: fase inicia en estado conocido.
- `BOS-02`: paneles únicos conceden primer sello.
- `BOS-03`: patches sólo se aplican durante corte.
- `BOS-04`: controles válidos conceden segundo sello.
- `BOS-05`: bandeja sólo se destruye desde línea válida.
- `BOS-06`: fax siempre permite preparar la solución.
- `BOS-07`: burnout reinicia la fase acordada.
- `BOS-08`: tercer sello dispara final una vez.
- `BOS-09`: cien rutas válidas terminan sin softlock.

## 16. Replays, hashes y capturas

### 16.1 Formato de replay

Cada replay guarda:

```text
format_version / build_id / seed / difficulty / initial_fixture
input_bits_per_tick
state_hash cada 25 ticks
final_result / tick_count / impacts / burnouts
```

El hash incluye:

```text
level, room, difficulty, Pitu, Alberto, briefing, carga, cafes,
pieces, room_flags, boss, score, resource_generations
```

Un cambio de hash exige clasificarlo como corrección intencional, cambio de diseño aprobado o regresión. No se regeneran todos los goldens sin revisión de diff.

### 16.2 Cobertura mínima de replays

- Arranque, menú y primera sala.
- Cuatro puertas y retornos.
- Cada familia de máquina.
- Aviso, tiro, impacto, cooldown y búsqueda de Alberto.
- Burnout y reentrada en cada planta.
- Checkpoint/password de cada planta.
- Ruta normal y alternativa de las treinta salas.
- Tres fases del jefe.
- Campaña completa por dificultad.
- Fallos de disco en cambio de sala/planta.

### 16.3 Capturas

Por sala:

- Estado de entrada.
- Landmark y objetivo activos.
- Aviso de Alberto.
- Estado tras interacción/patch.
- Ambas páginas de vídeo.
- Color, verde y gris.

Las escenas estáticas admiten comparación pixel-perfect. Las animadas usan máscara de regiones variables y comparan HUD, bordes, fondo y posiciones esperadas.

## 17. Rendimiento, soak y fault injection

### 17.1 Umbrales

| Métrica | Objetivo | Bloqueo |
|---|---:|---:|
| Audio tick | ≤2 ms | >3 ms repetido |
| Lógica + render típico | ≤36 ms | — |
| Lógica + render | ≤40 ms | >40 ms repetido |
| Frecuencia lógica | 25 Hz | <24 Hz sostenido |
| Pila libre | ≥384 B objetivo | <256 B |
| RAM4/RAM5 | ≤14 KiB | Exceso |
| RAM6 | ≤12 KiB | Exceso |
| Índice RAM7 | ≤2 KiB | Exceso |
| Recurso staging | ≤14 KiB | Exceso sin chunks diseñados |
| Reserva DSK | ≥10 KiB | Menor |

La latencia de carga se mide en disco frío y caliente sobre hardware. Se presenta mediante ascensor/cartela; no se fija un número ficticio antes de medir la unidad real.

### 17.2 Fixtures de peor caso

- Planta 4: fotocopiadora, Pitu, Alberto, briefing, pickup y SFX.
- Planta 7: cambio de luz y fondo oscuro.
- Planta 9: proyector, patch y persecución persistente.
- Jefe fase 3: fax, briefing, patch, HUD y música.
- Cambio de planta: carga de room, UI, texto y audio.

### 17.3 Soak

- Dos horas alternando salas.
- 1.000 transiciones de puerta.
- 1.000 pickups/resets.
- 10.000 briefings destruidos contra paredes.
- 10.000 cambios de banco.
- 100 campañas automáticas válidas antes de release.
- 500 pausas/reanudaciones.
- Treinta minutos de música y SFX simultáneos.
- Cincuenta ciclos de carga/cambio de escena.

Al final se revisan guards, pila, bancos, CRTC, AY, handles, CRC y hash de datos inmutables.

### 17.4 Fallos inyectados

- Magic, versión o build ID incorrectos.
- CRC de índice o payload corrupto.
- Payload truncado.
- Dependencia inexistente o cíclica.
- Recurso mayor que slot.
- Sector ilegible y timeout.
- Disco ausente/cambiado.
- Error antes y después de escribir la página oculta.
- Stack bancario desbalanceado.
- Handle de generación vieja.

Cada fallo debe dejar un estado recuperable, mensaje residente y banco/página/audio conocidos.

## 18. Juego manual y pruebas humanas

### 18.1 Regla de evidencia

Se copia `docs/playtests/SESSION_TEMPLATE.md` por sesión y se registra:

- Build ID, commit y hashes.
- Emulador/máquina, CRTC, monitor e input.
- Sala, seed, dificultad y estado inicial.
- Tiempo, ruta, impactos, burnouts y resultado.
- Observaciones literales separadas de interpretación.
- Capturas/replay y defectos asociados.

### 18.2 Vertical slice

Cinco personas nuevas, sin instrucciones orales:

- Cuatro identifican objetivo, salida e interacción en cinco segundos.
- Todas perciben el aviso antes del primer briefing.
- Mediana del nivel 1 <5 minutos.
- Nadie describe una aparición o impacto como aleatorio.
- Al menos tres usan una máquina de ruido voluntariamente.

### 18.3 Alpha

Doce personas repartidas entre nuevas y expertas en CPC:

- ≥80 % completa nivel 1 en ≤5 minutos.
- ≥80 % identifica aviso antes del primer impacto.
- ≥70 % descubre una interacción sistémica sin manual.
- Ninguna regla crítica depende sólo de color.
- Mediana vence al jefe en ≤4 intentos en Normal.
- Muy difícil es completado por al menos tres testers expertos en una planta tardía y por uno en el jefe.

### 18.4 Cualificación de RC

Sobre el mismo candidato:

1. Automatización completa y 50 celdas nivel/dificultad verdes.
2. Campaña manual Normal desde `NUEVA PARTIDA` hasta créditos.
3. Campañas completas dirigidas en las otras cuatro dificultades.
4. Usuario completa campaña Normal y prueba jefe en los cinco perfiles.
5. Hardware real ejecuta arranque, carga, peor escena y recorrido representativo.

No se usa warp, invulnerabilidad o selector debug para declarar completada una campaña manual.

## 19. Gestión de defectos e invalidación

### 19.1 Severidad

| Nivel | Ejemplos | Política |
|---|---|---|
| P0 | Cuelgue, corrupción, DSK no arranca, pérdida de estado | Detener integración |
| P1 | Softlock, sala imposible, golpe invisible, password erróneo | Bloquea fase/RC |
| P2 | Frame drop repetido, pista mala, colisión injusta | Corregir antes de RC |
| P3 | Texto, pixel o timing menor | Registrar y priorizar |

### 19.2 Qué se repite tras un cambio

| Cambio | Pruebas invalidadas |
|---|---|
| Texto/asset estático | Recurso, captura y escenas afectadas |
| Room data | Sala, rutas, capturas, nivel × 5 perfiles |
| IA/dificultad | Unitarias, replays afectados, matriz completa |
| Estado/progreso | Todos los replays y campañas |
| Renderer/bancos | Capturas, memoria, performance, soak y campañas |
| Loader/packer | Round-trip, fault injection, DSK, hardware y campañas |
| Audio player | Audio, performance, pausa, cargas y campañas |
| Toolchain/linker | Clean/parallel, reproducibilidad y suite completa |

Un P0/P1 hallado en playtest devuelve el build a QA técnica antes de entregarlo de nuevo.

## 20. Definition of Ready y Definition of Done

### 20.1 Sala lista para producción

- Ficha completa con seis campos de diseño.
- Mockup aprobado a 1×.
- Ruta principal, experta y salida segura dibujadas.
- Recursos/dependencias y estimación de working set.
- Fixture de prueba y criterio de cinco segundos.
- Texto/gag original y revisión de derechos si usa personaje literal.

### 20.2 Sala terminada

- Fuente editable, room pack y manifest integrados.
- Validadores, unitarias y replays verdes.
- Ambas páginas, color/verde/gris revisadas.
- Peor frame y memoria dentro de gate.
- Cinco dificultades completables.
- Primera exposición sin daño obligatorio.
- Evidencia enlazada en el informe del lote.

### 20.3 Fase terminada

- Todos los entregables presentes.
- Gate ejecutado sobre build limpio.
- P0/P1 = 0.
- Presupuestos actualizados.
- Rollback probado o todavía compilable.
- Decisiones aceptadas reflejadas en los documentos canónicos.

## 21. Evidencia y trazabilidad

Estructura propuesta:

```text
artifacts/qa/<build-id>/
  manifest.json
  builds/
  resources/
  unit/
  replays/
  screenshots/
  performance/
  soak/
  hardware/
  playtests/
  release-report.md
```

`manifest.json` contiene commit, toolchain, flags, hashes, fecha, entorno y estado de cada suite.

El informe de release enlaza cada requisito a uno de estos estados:

- `PASS`: evidencia adjunta.
- `FAIL`: defecto abierto.
- `WAIVED`: excepción explícita, responsable, riesgo y mitigación.
- `N/A`: justificación; no se usa para evitar una prueba difícil.

No puede quedar ninguna celda `NOT RUN` en RC.

## 22. Matriz de trazabilidad

| Requisito | Implementación principal | Pruebas/evidencia | Gate |
|---|---|---|---|
| R01 — Treinta salas únicas | Room packs, descriptores y lotes C1–C3 | `MAP-*`, capturas, rutas y matriz | A4 |
| R02 — Pitu canónica | Sprite set común y frames aprobados | `VID-06`, overlay de canon, revisión 1× | A0/A2/RC |
| R03 — Alberto justo y legible | Estados, telegraph de puerta y motivo AY | `AI-01..06`, replays y playtest | A2/A4 |
| R04 — Lenguaje visual unificado | Tiles comunes, HUD, storyboard y escenas | `VID-*`, color/verde/gris y test 5 s | A2/A5 |
| R05 — Recursos desde DSK | Packer, FDC, `BHRES.BIN` y handles | `RES-*`, fault injection y CPC real | A1–A3 |
| R06 — Uso seguro de 128K | Núcleo bajo, slots RAM4–RAM7 y guards | `MEM-*`, 10.000 cambios y soak | A2/RC |
| R07 — Cinco dificultades | Tabla de perfiles y soluciones compartidas | `DIF-*`, 50 celdas y campañas | A4/RC |
| R08 — 25 Hz y audio 50 Hz | Dirty render, límites de entidades y player | Performance, `AUD-*`, peores fixtures | A2/A5/RC |
| R09 — Jefe y final completos | `BossState`, tres fases, escenas y créditos | `BOS-*`, 100 rutas/fase y campañas | A5 |
| R10 — Errores recuperables | `room_enter` transaccional, timeout y retry | `RES-10..14`, fallos de disco | A1/A2/RC |
| R11 — Build reproducible | Manifests, IDs y outputs deterministas | `BLD-*`, clean/parallel y hashes | A0/A3/RC |
| R12 — Release distribuible | Licencias, manual, DSK y evidencias | Informe RC, hardware y derechos | A6 |

Un requisito sólo cambia a `PASS` cuando su gate contiene evidencia de todas las pruebas de la fila. Terminar el código no basta.

## 23. Riesgos principales y respuesta

| Riesgo | Señal | Respuesta |
|---|---|---|
| Núcleo no baja de `0x4000` | Linker >`0x35FF` | Extraer datos fríos; overlay sólo tras medición |
| Loader FDC inestable | Timeout o diferencia en CPC real | Mantener Classic; corregir F1 antes de bancos |
| Arte desborda packs | RAM4/RAM5 >14 KiB | Compartir tiles, reducir poses, comprimir |
| Fondo de tinta oculta juego | Fallo de test 5 s/gris | Reducir trama, reservar masa negra |
| Refactor cambia reglas | Hash/replay diverge | Extracción más pequeña y adaptador temporal |
| Matriz “pasa” sin jugar rutas | Sólo `BH_PASS` dirigido | Replays de input y rutas por sala |
| Split CRTC fragmenta compatibilidad | Diferencias por CRTC | Fallback Mode 0 y retirar split |
| Audio compite con FDC/bancos | Nota colgada o frame >40 ms | Silencio durante I/O; audio residente si hace falta |
| Treinta salas repiten solución | Mismo verbo/remate | Revisión de lote y no crear nueva IA |
| Derechos/música bloquean release | Sin permiso en alpha | Sustituir antes de RC, no después |

## 24. Primeras dos semanas de ejecución

### Días 1–2

- Congelar baseline y hashes.
- Ejecutar suites actuales y archivar evidencia.
- Crear manifest QA y nomenclatura de build.
- Inventariar globals/funciones de `game.c` y seams de extracción.

### Días 3–5

- Producir/convertir los tres mockups A0.
- Medir tamaños y legibilidad.
- Ejecutar harness Mode 0/split.
- Elegir dirección visual y cerrar A0 si pasa.

### Días 6–7

- Extraer `CampaignState`, perfiles e input sin cambio visual.
- Añadir hash de estado y fixtures del comportamiento actual.
- Repetir Classic check/matrix/capturas.

### Días 8–10

- Crear manifest/packer mínimo y `BHRES.BIN` de dos fondos.
- Añadir inspector, CRC, build ID y verificador de contigüidad.
- Construir DSK Lab sin alterar Classic.

### Días 11–12

- Implementar lector FDC de un sector y timeouts.
- Mostrar primer fondo en página oculta.
- Añadir fault injection de CRC/disco ausente.

### Días 13–14

- Alternar los dos fondos, restaurar audio/estado y ejecutar cien ciclos.
- Medir stack y checksums de páginas.
- Preparar prueba CPC real y decisión go/no-go de A1.

Al final de estas dos semanas debe existir una respuesta objetiva a las dos preguntas críticas: “¿la dirección visual funciona a tamaño CPC?” y “¿podemos sustituir recursos desde DSK sin dañar el juego?”. Si cualquiera es negativa, se corrige ese fundamento antes de producir contenido.

## 25. Documentos de autoridad

En caso de contradicción:

1. `PITU_CANON.md` decide el modelo de Pitu.
2. `GAME_DESIGN.md` decide reglas, progreso y alcance.
3. `DISK_RESOURCE_ARCHITECTURE.md` decide formato, bancos y contratos de carga.
4. `AMBITIOUS_IMPROVEMENT_PLAN.md` decide dirección artística y experiencia objetivo.
5. Este documento decide orden de implementación, integración y gates.
6. `TEST_PLAN.md` aporta el catálogo detallado histórico de casos; la evidencia ejecutada decide el estado real.

Las decisiones aprobadas en A0/A2 se promueven a los documentos canónicos. Este plan no convierte por sí mismo un experimento en requisito de producto.
