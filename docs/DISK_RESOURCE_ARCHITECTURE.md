# Arquitectura de recursos en disco para Banterhouse

Estado: arquitectura implementada hasta el slice técnico Expanded; migración de producto pendiente

Repositorio auditado: `/Users/fer/dev/banterhouse`

Rama y referencia: `main` en `ed4fdbe21be7554ab209e64357fb8756ff3c16c4`

Fecha de la auditoría: 2026-08-30

## 0. Corte de implementación

La auditoría de la sección 3 queda congelada como evidencia de partida. Desde
esa referencia se han implementado y probado:

- Contenedor `BHRES.BIN` v1 con ocho recursos, IDs estables, dependencias,
  build ID `0x173B6D8B`, CRC16 y alineación física a sector.
- Lector directo uPD765 con seek, transferencias multitrack, tres intentos y
  estados de error acotados.
- Fault injection de payload corrupto y sector ausente.
- Gestor de slots RAM4–RAM7 con generaciones y commit transaccional.
- Kernel bajo integrado que carga dos fondos, muestra ambas páginas CRTC y
  valida un room pack en RAM5.
- 10.000 cambios de banco y un soak de 100 cargas de pantalla en Caprice32.

El release descargable sigue siendo Classic. El DSK Expanded actual es un
artefacto de laboratorio, no la campaña completa. El estado normativo se
mantiene en [`IMPLEMENTATION_STATUS.md`](IMPLEMENTATION_STATUS.md).

## 1. Decisión ejecutiva

La edición ampliada debe adoptar una arquitectura híbrida:

1. `LOADER.BAS` y AMSDOS siguen arrancando una imagen de carga y un bootstrap pequeño en `0x4000`.
2. El bootstrap carga el núcleo temporalmente en RAM7, desactiva el firmware, lo copia y lo ejecuta en los 16 KiB bajos.
3. Un lector propio y **solo de lectura** accede por sectores a `BHRES.BIN`, un contenedor AMSDOS colocado de forma contigua y determinista en el DSK.
4. Los 64 KiB adicionales se usan como cuatro bancos de trabajo de 16 KiB: render, habitación, audio y entrada/caché.
5. Los dos framebuffers de 16 KiB se mantienen en `0x8000` y `0xC000`.
6. Los recursos son datos cargables. Los overlays de código se posponen hasta que habitaciones, gráficos y audio funcionen de forma estable.
7. La release monolítica actual sigue siendo el build predeterminado y la edición CDT estable. La edición ampliada se activa con un flag y produce otro artefacto DSK.

Esta solución añade complejidad en un solo componente acotado —el lector FDC—, pero evita tres problemas más difíciles de controlar: reactivar un firmware cuyo espacio de trabajo ya ha sido usado como framebuffer, mantener docenas de archivos AMSDOS y renunciar al doble búfer. No se propone un sistema de streaming continuo ni un scheduler asíncrono.

La primera prueba implementable no requiere todavía paginación: el lector localiza el contenedor por su sector físico, carga un fondo externo en una página de vídeo, lo muestra, lo sustituye por un segundo fondo y verifica que estado, pila, audio y la otra página no cambian. La paginación llega después, en la fase 3.

## 2. Convención de evidencia

Este documento usa tres etiquetas:

- **[V] Verificado**: observado en la referencia indicada, en el mapa del linker, en el DSK/CDT o ejecutando las pruebas.
- **[I] Inferencia de diseño**: conclusión sustentada por los datos actuales, todavía no implementada.
- **[E] Experimento requerido**: depende de tiempos, comportamiento del emulador o hardware real y necesita una prueba aislada.

Los presupuestos futuros son límites de diseño, no tamaños ya medidos. Deben convertirse en gates automáticos antes de activar el build ampliado.

## 3. Auditoría de la arquitectura de partida (`ed4fdbe`)

### 3.1 Material revisado y validación

Se revisaron completos los documentos, configuración, loader, fuentes y headers solicitados. También se inspeccionaron el mapa del linker, los símbolos generados de audio y gráficos, las herramientas de validación, el contenido CP/M del DSK y la secuencia del CDT.

Resultados sobre la referencia auditada:

| Comprobación | Resultado |
|---|---:|
| `make parallel-build` | **[V]** Correcto |
| `make check` | **[V]** Correcto: paleta, MIDI, AKS, fuente y checks estáticos |
| `make matrix` | **[V]** Correcto: cinco campañas automatizadas, dificultades 0–4, diez niveles cada una |
| Estado Git tras las pruebas | **[V]** Limpio |
| Hash final de DSK frente al inicial | **[V]** Idéntico |
| Hash final de CDT frente al inicial | **[V]** Idéntico |

`make matrix` ofrece buena cobertura de regresión funcional, pero no equivale a cincuenta partidas manuales: usa la automatización y los teletransportes de `BH_AUTOTEST`. Debe conservarse como gate, no presentarse como validación de interacción humana o de disco real.

El compilador todavía emite warnings heredados sobre prototipos/declaraciones y una translation unit vacía. No impiden el build auditado, pero los módulos nuevos de storage/resources deben nacer sin warnings para no ocultar errores de ABI o de truncado de tamaños.

Se encontraron descripciones históricas en `GAME_DESIGN.md`, `IMPLEMENTATION_PLAN.md` y `TEST_PLAN.md` que ya no representan el ejecutable. Por ejemplo, la paginación propuesta en el diseño no existe en runtime y varias carencias descritas por el plan ya fueron implementadas. Para esta arquitectura mandan el código, `obj/banterhouse.map` y los artefactos generados.

### 3.2 Arranque y artefactos

`dsk_files/LOADER.BAS` hace actualmente:

```basic
MEMORY &3FFF
LOAD "LOADING.SCR",&C000
RUN "BANTERHO.BIN"
```

Antes de entrar en C, BASIC/AMSDOS carga la pantalla y el único binario. En `main.c`, el juego coloca la pila en `0x7FFF` y llama a `cpct_disableFirmware()`. El valor retornado, necesario para restaurar el handler anterior, se descarta.

**[V] Contenido útil del DSK actual:**

| Nombre AMSDOS | Contenido | Payload | Asignación CP/M |
|---|---|---:|---:|
| `BANTERHO.BIN` | Ejecutable monolítico | 25.429 B | 25 KiB |
| `LOADER.BAS` | Arranque BASIC | 265 B | 1 KiB |
| `LOADING.SCR` | Pantalla de carga | 16.384 B | 17 KiB con header |

El directorio tiene cinco entradas/extents ocupados y 43 bloques de 1 KiB asignados. El fichero DSK mide 204.544 B porque incluye cabeceras del formato de imagen y 42 tracks descritos; ese tamaño no es la capacidad útil del disco. Un DATA format físico estándar ofrece 40 tracks × 9 sectores × 512 B, con 2 KiB de directorio: **178 KiB asignables a ficheros**. Los tracks 40 y 41 no deben usarse en la edición para hardware real, aunque la imagen actual los describa.

El CDT actual no contiene `LOADER.BAS` ni `LOADING.SCR`; lleva un único bloque monolítico llamado `Game`. Por tanto, la inclusión de ficheros en `dsk_files` no crea automáticamente una versión equivalente en cinta.

### 3.3 Mapa de memoria actual

El binario plano empieza en `0x0800`, termina en el último byte emitido en `0x6B54` y mide 25.429 B. Su tamaño incluye huecos entre áreas absolutas; no son todos datos residentes significativos.

| Rango | Tamaño | Uso actual | Evidencia |
|---|---:|---|---|
| `0x0000–0x07FF` | 2.048 B | Vectores, firmware y hueco no emitido | **[V]** Configuración/mapa |
| `0x0800–0x1181` | 2.434 B | Tema Arkos | **[V]** Símbolos generados |
| `0x1182–0x12FF` | 382 B | Hueco | **[V]** Binario/mapa |
| `0x1300–0x1AFF` | 2.048 B | Cuatro espejos de sprites, construidos en runtime | **[V]** `graphics.c` |
| `0x1B00–0x1E6B` | 876 B | Bitmap e índice de fuente | **[V]** `font.h`/mapa |
| `0x1E6C–0x1E91` | 38 B | Trabajo del renderer de fuente | **[V]** mapa |
| `0x1E92–0x1E9F` | 14 B | Hueco | **[V]** mapa |
| `0x1EA0–0x1F6F` | 208 B | SFX Arkos | **[V]** símbolos generados |
| `0x1F70–0x1FFF` | 144 B | Hueco | **[V]** mapa |
| `0x2000–0x305D` | 4.190 B | Cuatro frames fuente y logo | **[V]** área `_BH_GFX` |
| `0x305E–0x3FFF` | 4.002 B | Hueco antes del código | **[V]** mapa |
| `0x4000–0x6B54` | 11.093 B | Código | **[V]** área `_CODE` |
| `0x6B55–0x6B82` | 46 B | Datos persistentes C | **[V]** área `_DATA` |
| `0x6B83–0x7FFF` | 5.245 B | Margen total para pila y crecimiento | **[V]** high-water real |
| `0x8000–0xBFFF` | 16.384 B | Framebuffer A | **[V]** código de render |
| `0xC000–0xFFFF` | 16.384 B | Framebuffer B | **[V]** código de render |

Los 5.245 B no son una “pila reservada” medida: son todo el espacio disponible entre los datos y `0x8000`. La pila crece hacia abajo desde `0x7FFF` y todavía no hay un centinela que mida su máximo real.

### 3.4 Qué permanece residente hoy

**[V] Siempre accesible durante gameplay:**

- Código, estado global y pila.
- Fuente y renderer de texto.
- Frames de Pitu y Alberto y sus copias invertidas.
- Paleta y lógica de render.
- Reproductor Arkos, tema y SFX actuales.
- Los dos framebuffers.

**[V] No necesita ser residente durante toda la partida:**

- El logo, usado en menú/final.
- Pantallas completas y transiciones futuras.
- Datos de habitaciones futuras, decorados, retratos y cutscenes.
- Canciones de otras áreas, que todavía no existen.

El despacho y el jefe se dibujan de forma procedural cada frame; no existe aún un fondo o tilemap activo cargado desde disco. `render.c` sigue siendo un placeholder y la mayor parte del render vive en `game.c`.

### 3.5 Restricciones críticas confirmadas

1. **La RAM extra está totalmente sin usar.** No hay llamadas a `cpct_pageMemory`, gestor de bancos ni lector de disco en runtime. **[V]**
2. **Código y pila ocupan la ventana normal de paginación.** Las configuraciones `RAMCFG_4..7` sustituyen `0x4000–0x7FFF`; con el mapa actual paginarían fuera el código que está ejecutándose y la pila. **[V]**
3. **La VRAM sólo puede estar en los 64 KiB primarios.** Un recurso en RAM expandida debe copiarse o descomprimirse a `0x8000`/`0xC000` para mostrarse. **[V]**
4. **Reactivar el firmware no es seguro en el juego actual.** CPCtelera documenta que el firmware usa aproximadamente `0xA6FC–0xBFFF`, dentro del framebuffer A; además `main.c` no conserva el handler retornado por `cpct_disableFirmware()`. Esa función sólo reemplaza el handler IM1: no es por sí sola una operación de deshabilitar ROMs. **[V]**
5. **AMSDOS añade más estado.** Su manual oficial indica que reserva `0x500` bytes dinámicamente y advierte que `CAS IN DIRECT` no debe sobrescribir sus variables. **[V]**
6. **El audio no se actualiza por una ISR propia.** `bh_audio_tick()` se llama desde el bucle a 50 Hz. Esto permite serializar paginación y audio, pero una carga bloqueante congelará la música. **[V]**

Estas restricciones hacen inviable añadir simplemente `resource_load()` sobre AMSDOS manteniendo el mapa y el doble búfer actuales.

## 4. Comparación de alternativas

| Alternativa | Ventajas | Riesgos/límites en Banterhouse | Complejidad | Decisión |
|---|---|---|---:|---|
| Firmware/AMSDOS en runtime | Nombres, directorio y errores ya resueltos; buen prototipo | Workspace dentro de framebuffer A; firmware desactivado y handler perdido; buffer de 2 KiB para `CAS IN OPEN`; hasta 64 entradas de directorio | Media por la integración real | Sólo laboratorio/fallback |
| Lector FDC propio, sólo lectura | Compatible con firmware apagado y doble búfer; acceso determinista; sin workspace AMSDOS | Motor, seek, polling, timeouts, retries y errores deben implementarse y probarse en hardware | Media-alta, pero acotada | **Recomendado para DSK ampliado** |
| Un fichero AMSDOS por recurso | Fácil de inspeccionar y sustituir | 8.3, slack de 1 KiB, múltiples extents, límite de 64 entradas, apertura costosa | Baja | Sólo F0/F1 si acelera una prueba |
| Un contenedor indexado | Poca fragmentación, IDs estables, verificación global, mejor secuencialidad | Requiere packer e índice; el build debe garantizar ubicación física | Media | **Recomendado** |
| Varios contenedores por familia | Actualizaciones parciales y posible cinta por capítulos | Más localizadores y extents; poca ganancia en un solo DSK | Media | No inicialmente |
| Pantallas completas | Carga y display simples; ideales para carga/cutscene | 16 KiB cada una; poca reutilización; no caben como staging junto al índice | Baja | Para transiciones/cutscenes |
| Tilemap + tiles + decorado | Escala a muchas habitaciones; compone ambos buffers | Renderer y pipeline más complejos; exige límites de working set | Media | **Para gameplay** |
| Compresión por recurso | Aumenta contenido de disco; ZX7B ya está en el toolchain | Pico fuente+destino, CPU y solapamiento; no todo comprime bien | Media | Sí, decidida por métricas |
| 64 KiB extra como bancos | Working sets claros y caché de área | Sólo una página de 16 KiB visible en `0x4000`; punteros se invalidan al cambiar banco | Media | **Sí, tras relocalizar núcleo** |
| Overlays de código | Libera núcleo para minijuegos/jefes | ABI, linker, trampolines, punteros y recuperación mucho más frágiles | Alta | Posponer; no F0–F4 |
| Streaming continuo | Puede ocultar latencia | El 765 usa PIO por polling; compromete audio/frame; complejidad innecesaria por habitaciones discretas | Alta | No |
| Precarga síncrona en transición | Simple, transaccional y estilizable | Pausa música durante lectura | Baja | **Sí** |

### Por qué no AMSDOS como backend de producción

El manual oficial ofrece un camino válido: un loader bajo puede reinicializar AMSDOS con `KL INIT BACK`, fijar su workspace y llamar a `CAS IN OPEN`, `CAS IN DIRECT` y `CAS IN CLOSE`. También sería posible preservar/restaurar el área de firmware en un banco expandido. Ambos caminos son correctos como experimento, pero en Banterhouse conservan una dependencia sobre el rango que el framebuffer A usa deliberadamente y complican cada transición.

El lector FDC no necesita firmware ni RAM oculta. Su alcance se limita a DATA format, una cara, 40 tracks, nueve sectores de 512 B y lectura. No implementará CP/M, búsqueda de nombres, borrado ni escritura.

### Por qué un contenedor y no un filesystem nuevo

No se necesita un filesystem general. `BHRES.BIN` seguirá apareciendo como fichero AMSDOS para que las herramientas y el DSK sean convencionales. El build lo insertará primero y comprobará que sus bloques sean contiguos. El runtime conoce su sector inicial y resuelve offsets mediante el índice interno. Si la contigüidad falla, el build falla; no se intenta seguir cadenas CP/M en el CPC.

## 5. Arquitectura propuesta

### 5.1 Capas

```text
room_enter / escenas / audio
            |
       resource manager
       IDs, deps, caché, CRC
            |
       storage_read_range
            |
    backend FDC de sólo lectura
            |
 BHRES.BIN contiguo en DATA DSK
```

El resource manager no conoce tracks ni sectores. El backend no conoce habitaciones, sprites o audio. Esta separación permite mantener un backend AMSDOS de prueba o uno secuencial para cinta sin contaminar el modelo de recursos.

### 5.2 Bootstrap del núcleo bajo

Un núcleo enlazado en `0x0100` no se puede cargar directamente allí con el BASIC actual: pisaría memoria baja y jumpblocks mientras AMSDOS/BASIC aún están ejecutando. El arranque ampliado usa `BHBOOT.BIN`, un bootstrap no residente enlazado en `0x4000`:

1. BASIC reserva como ahora con `MEMORY &3FFF`, carga `LOADING.SCR` en la VRAM primaria de `0xC000`, carga `BHBOOT.BIN` en `0x4000` y lo ejecuta.
2. `BHBOOT` conserva firmware/AMSDOS, usa `0x8000–0x87FF` como buffer de 2 KiB fuera de su workspace y pagina RAM7 en `0xC000` mediante `RAMCFG_1`.
3. Llama a `CAS IN OPEN`, `CAS IN DIRECT` y `CAS IN CLOSE` para cargar `BHKERN.BIN` en el `0xC000` visible para la CPU, que en ese momento es RAM7. El CRTC sigue mostrando la pantalla de carga de la RAM primaria.
4. Vuelve a `RAMCFG_0`, silencia AY, guarda el handler retornado por `cpct_disableFirmware()` si el bootstrap lo necesita para diagnosticar un fallo y deshabilita explícitamente ambas ROMs. Coloca temporalmente la pila en `0x7FFF`.
5. Pagina otra vez RAM7 en `0xC000`, lee ya la RAM subyacente, copia el núcleo enlazado para `0x0100` a su destino bajo y vuelve a `RAMCFG_0`.
6. Coloca la pila definitiva en `0x3FFF` y salta al entry point bajo. `BHBOOT` y la copia temporal de RAM7 quedan descartables.

`RAMCFG_1` mantiene RAM0/RAM1/RAM2 en `0x0000–0xBFFF` y sólo sustituye `0xC000–0xFFFF` por RAM7, por lo que el bootstrap en `0x4000`, su pila temporal y el workspace de firmware no desaparecen. **[E]** La secuencia completa debe validarse primero con un kernel canario y errores AMSDOS antes de usarla en F3.

El bootstrap sólo usa AMSDOS durante el arranque. Después del salto, el núcleo no vuelve a reactivar firmware y el lector FDC read-only es dueño del disco.

### 5.3 Mapa de memoria objetivo

#### RAM primaria, siempre visible

| Rango | Presupuesto | Uso propuesto | Gate de build |
|---|---:|---|---|
| `0x0000–0x00FF` | 256 B | RST/IM1, vectores, pequeño gate de hardware | No recursos |
| `0x0100–0x35FF` | 13.568 B | Núcleo, renderer, audio player, resource manager, FDC, descompresor y constantes calientes | Código+rodata ≤ 13.568 B |
| `0x3600–0x37FF` | 512 B | Buffer de un sector | Exactamente 512 B, alineado |
| `0x3800–0x39FF` | 512 B | Estado persistente y descriptor copiado del índice | Informe separado |
| `0x3A00–0x3BFF` | 512 B | Temporales, CRC, guards y error de carga | Sin datos persistentes ocultos |
| `0x3C00–0x3FFF` | 1.024 B | Pila con patrón de high-water | Fallo si quedan < 256 B intactos |
| `0x4000–0x7FFF` | 16.384 B | Ventana de RAM4–RAM7 | Nunca código/pila residente |
| `0x8000–0xBFFF` | 16.384 B | Framebuffer A | VRAM primaria |
| `0xC000–0xFFFF` | 16.384 B | Framebuffer B | VRAM primaria |

El código actual ocupa 11.093 B y los datos C 46 B. Quedan aproximadamente 2,4 KiB dentro del presupuesto del núcleo para FDC, recursos y descompresión, antes de optimizaciones. **[E]** El linker real decidirá si cabe; si no, se moverán logo, tablas frías y lógica de menú a recursos antes de plantear overlays.

#### RAM expandida, visible en `0x4000–0x7FFF`

Se usarán únicamente `RAMCFG_4`, `RAMCFG_5`, `RAMCFG_6`, `RAMCFG_7` y `RAMCFG_0`. Así `0x0000–0x3FFF`, ambos framebuffers y el núcleo nunca desaparecen.

| Banco físico | Rol inicial | Presupuesto útil | Contenido típico |
|---|---|---:|---|
| RAM4 | Working set de render | ≤ 14 KiB | Sprites activos y espejos, fuente, UI, tiles activos |
| RAM5 | Habitación/caché | ≤ 14 KiB | Tilemap, decorado, colisiones, tablas de sala, siguiente pack si cabe |
| RAM6 | Audio | ≤ 12 KiB | Canción y SFX del área; espacio de expansión reservado |
| RAM7 | Entrada e índice | 14 KiB staging + 2 KiB índice | Recurso comprimido, índice compacto, transición/logo descartable |

En RAM7, el staging usa `0x4000–0x77FF` (14.336 B) y el índice `0x7800–0x7FFF` (2.048 B) cuando ese banco está paginado. Los recursos comprimidos mayores que el staging se guardan sin comprimir, se dividen en chunks o se rechazan en build.

RAM4 no debe convertirse en un vertedero “residente”. Con los datos actuales, sprites fuente + espejos + fuente ocupan unos 5 KiB; incluso incluyendo el logo serían unos 7 KiB. Hay margen para UI y tiles, pero el informe de working set debe impedir superar 14 KiB.

### 5.4 Reglas de paginación

1. `bank_push(RAMx)` guarda en software la configuración actual y pagina con interrupciones brevemente deshabilitadas.
2. `bank_pop()` restaura exactamente la configuración anterior; no asume siempre `RAMCFG_0`.
3. La profundidad será pequeña y comprobada; overflow/underflow es fatal en debug.
4. El registro es write-only: la variable `current_bank` es la fuente de verdad.
5. Ningún puntero a `0x4000–0x7FFF` sobrevive a un `bank_pop()`.
6. Antes de entrar al bucle normal o dibujar, el código verifica que el banco esperado está mapeado.
7. `bh_audio_tick()` pagina RAM6, ejecuta el player y restaura el banco anterior. Durante I/O el audio está detenido.

Hasta F5, tema y SFX pueden seguir en memoria primaria si simplifica la migración. El mapa objetivo de RAM6 es el destino, no un prerrequisito de la primera pantalla externa.

### 5.5 Uso de los framebuffers

- Para pantallas completas, la carga/descompresión termina en la página oculta y sólo después cambia el CRTC.
- Para habitaciones, se cargan tilemap y tiles en bancos, se compone la escena en A y B y luego se reanuda el juego.
- No se conserva una tercera copia de un fondo completo. El renderer actual redibuja el mundo; si se introduce dirty rendering, la fuente debe ser tilemap/decorado, no otro buffer de 16 KiB.
- Una pantalla raw de 16 KiB se lee directamente por sectores a VRAM. Una comprimida se lee a RAM7, valida y se descomprime a la página oculta.

### 5.6 Overlays, sólo si las métricas los justifican

Un overlay futuro se enlazaría para `0x4000`, se cargaría en RAM7 y se invocaría desde un trampoline residente bajo `0x4000`. Su ABI sólo aceptaría valores, IDs y direcciones de RAM primaria; nunca punteros a otro banco. Antes de llamarlo se detienen cargas y audio, se pagina RAM7, se ejecuta y se restaura la configuración incluso ante error. El overlay no puede llamar a `resource_load()` mientras él mismo ocupa el banco de staging.

Cada overlay tendría versión de ABI, tamaño, entry point, CRC y lista explícita de servicios residentes importados. No se permite estado estático que deba sobrevivir a su descarga. Esta opción sólo se abre si, después de extraer datos fríos, el núcleo no cabe o un minijuego aislado aporta suficiente valor. No forma parte de la ruta crítica F0–F4.

## 6. Formato de recursos

### 6.1 Fuente de verdad

Se propone `assets/resources.yml` como manifest de build. Los IDs son explícitos y estables; no se derivan de hashes ni del orden alfabético.

Rangos iniciales: `0x01xx` pantallas, `0x02xx` habitaciones, `0x03xx` sprites/tiles, `0x04xx` retratos/UI, `0x05xx` texto/escenas, `0x06xx` audio y `0x07xx` overlays futuros. Así, por ejemplo, `RESOURCE_BACKGROUND_AGENCY`, `RESOURCE_ROOM_RECEPTION`, `RESOURCE_SPRITES_PITU` y `RESOURCE_PORTRAIT_ALBERTO` conservan su número aunque cambie su fichero fuente o compresión. Los IDs retirados no se reutilizan dentro de la misma versión mayor.

```yaml
format_version: 1
resources:
  - id: 0x0101
    symbol: RESOURCE_BACKGROUND_AGENCY
    amsdos_alias: BGAGENCY.SCR
    type: background_screen
    source: assets/screens/agency.png
    converter: img2cpc_screen
    codec: zx7b
    target: hidden_framebuffer
    cache: discardable
    dependencies: []

  - id: 0x0201
    symbol: RESOURCE_ROOM_RECEPTION
    amsdos_alias: RMRECEPT.BIN
    type: room_pack
    source: assets/rooms/reception.tmx
    codec: zx7b
    target: ram5
    cache: room
    dependencies:
      - RESOURCE_SPRITES_PITU
      - RESOURCE_TILESET_AGENCY
```

`amsdos_alias` sólo es obligatorio para el modo experimental de ficheros sueltos. Debe ser ASCII mayúsculo, máximo 8+3 y único. El modo contenedor sólo expone `BHRES.BIN`.

### 6.2 Tipos iniciales

| Tipo | Destino normal | Política |
|---|---|---|
| `background_screen` | Página de vídeo oculta | Descartable |
| `room_pack` | RAM5 | Por habitación |
| `tileset` | RAM4/RAM5 | Por área o habitación |
| `sprite_set` | RAM4 | Personaje/área |
| `portrait_set` | RAM4/RAM7 | Por escena |
| `ui_pack` | RAM4 | Área o residente |
| `text_pack` | RAM5/RAM7 | Escena/idioma |
| `audio_song` | RAM6 | Por área |
| `audio_sfx` | RAM6 | Por área/residente |
| `cutscene_frame` | Página oculta | Descartable |
| `overlay` | RAM7/ventana acordada | Futuro, ejecutable |
| `save_schema` | No cargable desde contenedor | Metadato de build |

### 6.3 Contenedor `BHRES.BIN`

El formato será little-endian y versionado:

```text
[cabecera BHRS]
[índice de entradas]
[lista de dependencias]
[padding hasta sector]
[payload 1 alineado]
[payload 2 alineado]
...
```

Cabecera mínima:

| Campo | Tamaño | Propósito |
|---|---:|---|
| Magic `BHRS` | 4 B | Rechazar disco/formato incorrecto |
| Versión | 1 B | Compatibilidad de formato |
| Flags | 1 B | Codec/edición |
| Número de entradas | 2 B | Límite del índice |
| Offset de índice | 3 B | Dentro del contenedor |
| Offset de datos | 3 B | Primer payload |
| Build ID | 4 B | Emparejar núcleo y recursos |
| CRC de cabecera/índice | 2 B | Detectar corrupción |

Cada entrada de disco contiene, como mínimo:

- `id` de 16 bits.
- Tipo y flags (`resident`, `cacheable`, `discardable`, `executable`).
- Offset de 24 bits en el contenedor.
- Tamaño almacenado y tamaño descomprimido de 16 bits.
- Codec (`none`, `zx7b`; otros requieren versión nueva).
- Clase de destino, banco preferido, dirección/alineación si es fija.
- Offset y número de dependencias.
- CRC16 del payload descomprimido.

El índice rico vive en disco. Al arrancar se transforma en un índice compacto de hasta 2 KiB en RAM7. El build falla si no cabe. Para cada load, el descriptor requerido se copia a una estructura baja antes de cambiar de banco; no se conserva un puntero al índice.

### 6.4 Alineación y compresión

- Payloads raw destinados a VRAM se alinean a 512 B para permitir lectura directa.
- Un payload ZX7B debe caber completo en los 14 KiB de staging y descomprimirse sin solapamiento no validado.
- Se selecciona compresión sólo si el ahorro supera el padding, el índice y un umbral configurable; punto inicial: al menos 128 B o 10 %.
- El packer descomprime de vuelta cada recurso y compara bytes/CRC como parte del build.
- Pantallas que compriman mal se guardan raw. No se fuerza un codec por uniformidad.

### 6.5 Dependencias y caché

Las dependencias forman un DAG validado. `room_enter(RECEPTION)` puede expandir a tiles, sprites, UI, texto y audio, pero la carga se ordena por destino para minimizar cambios de banco.

Políticas iniciales:

- `resident`: núcleo o working set común; no se expulsa salvo cambio de campaña.
- `area`: permanece mientras se está en una planta/zona.
- `room`: se sustituye al entrar en otra habitación.
- `scene`: válido durante briefing/cutscene.
- `discardable`: puede sobrescribirse inmediatamente.

No se implementará LRU en la primera versión. Cuatro bancos no justifican un cache general: se usan slots con dueño explícito y generación.

## 7. API de runtime

Una API C realista, con implementaciones críticas en ensamblador:

```c
typedef u16 ResourceId;

typedef enum {
   RES_OK = 0,
   RES_NOT_FOUND,
   RES_WRONG_BUILD,
   RES_IO_ERROR,
   RES_BAD_CRC,
   RES_NO_MEMORY,
   RES_BAD_FORMAT,
   RES_DEPENDENCY_ERROR
} ResourceStatus;

typedef struct {
   u8  bank;
   u16 address;
   u16 size;
   u8  generation;
} ResourceHandle;

ResourceStatus resource_load(ResourceId id, ResourceHandle* out);
ResourceStatus resource_preload(ResourceId id);
void           resource_unload(ResourceId id);
ResourceStatus resource_get(ResourceId id, ResourceHandle* out);
ResourceStatus room_enter(u16 room_id);

u8   bank_push(u8 ram_config);
void bank_pop(void);
```

`resource_get()` no devuelve un puntero crudo. El caller valida el handle/generación, pagina el banco, usa la dirección y restaura antes de retornar.

### 7.1 Semántica síncrona

Todas las cargas de F0–F5 son síncronas. `resource_preload()` significa “cargar ahora en su slot sin hacerlo activo”, no lanzar I/O asíncrono. Sólo se llama en puntos seguros:

- Tras confirmar un ascensor, puerta o fin de diálogo.
- Con la lógica de juego pausada.
- Con una cartela/fondo ya visible.
- Con audio parado y AY silenciado.
- Con el banco actual guardado.

Se puede encender el motor antes, mientras todavía se muestra un diálogo, porque eso no requiere transferir sectores. Leer sectores intercalados con frames queda como **[E]** de F5.

### 7.2 Transacción de `room_enter`

1. Validar ID y dependencias sin modificar `current_room`.
2. Mostrar/fundir a una transición residente.
3. Encender o mantener motor; detener audio en un límite de tick y silenciar AY.
4. Cargar todos los packs en slots no activos o descartables; comprobar tamaños y CRC.
5. Si todo es correcto, actualizar el estado de habitación de una sola vez.
6. Componer ambos framebuffers.
7. Restaurar `RAMCFG_0` o el banco de render acordado, iniciar la nueva música y reanudar lógica.
8. Apagar el motor tras un timeout de inactividad, no después de cada sector.

Si falla una dependencia, `current_room` no cambia. Se restaura el banco, se muestra un mensaje residente de error y se permite reintentar o volver a la habitación anterior. Si una pantalla se estaba cargando directamente a VRAM y su CRC falla, permanece oculta; se redibuja desde el room pack anterior antes de quitar el fundido.

### 7.3 Backend FDC mínimo

El CPC usa un NEC 765A sin INT, DMA ni terminal count conectados; las transferencias son PIO por polling. El backend sólo necesita:

- Control de motor en `0xFA7E`.
- Main Status Register en `0xFB7E`.
- Data Register en `0xFB7F`.
- `SPECIFY` en modo non-DMA, `SENSE DRIVE STATUS`, `RECALIBRATE`, `SENSE INTERRUPT STATUS`, `SEEK` y `READ DATA` MFM.
- Timeouts en todas las esperas de RQM/fase; nunca un bucle infinito.
- Lectura de exactamente un sector haciendo `EOT == R`, seguida de los siete bytes de resultado.
- Validación de ST0/ST1/ST2 y CHRN; `N=2` para 512 B.
- Hasta tres intentos: relectura, seek y recalibrate+seek. Después, error recuperable.

Para DATA format, la conversión lineal es nueve sectores por track, IDs `0xC1..0xC9`, tracks `0..39`. El build genera las constantes del primer sector y el skip de la cabecera AMSDOS; el runtime no las adivina.

**[E]** Deben medirse el spin-up y los timeouts. La documentación indica que el tiempo de aceleración no está garantizado. Se comienza con un retardo conservador, se mantiene el motor encendido durante la transición y se prueba en una unidad de 3 pulgadas real, no sólo en Caprice32/Gotek.

## 8. Pipeline de build y DSK

### 8.1 Builds separados

El build estable no cambia de significado:

```make
DISK_RESOURCES ?= 0
RESOURCE_LAYOUT ?= container
STORAGE_BACKEND ?= fdc
```

- `DISK_RESOURCES=0`: binario/DSK/CDT monolíticos actuales.
- `DISK_RESOURCES=1`: núcleo relocalizable y `banterhouse-expanded.dsk`.
- Un posible `STORAGE_BACKEND=amsdos` sólo compila el harness aislado.

No se debe reutilizar el mismo nombre de salida mientras ambos caminos diverjan.

### 8.2 Flujo propuesto

1. Convertir PNG a pantalla/tiles/sprites con las herramientas CPCtelera existentes.
2. Convertir tilemaps, colisiones, textos y diálogos a formatos binarios propios, versionados.
3. Mantener la conversión AKS actual, pero emitir canciones/SFX como payloads del manifest.
4. Ejecutar el codec por recurso y conservar raw si no cumple el umbral.
5. Validar dependencias, IDs, aliases 8.3 y working sets.
6. Construir `BHRES.BIN`, su header C de IDs y un informe JSON/Markdown.
7. Construir `BHKERN.BIN` para `0x0100`, `BHBOOT.BIN` para `0x4000` y verificar ambos mapas.
8. Crear un DATA DSK de 40 tracks e insertar **primero** `BHRES.BIN`; después `BHKERN.BIN`, `BHBOOT.BIN`, pantalla de carga y loader en orden explícito.
9. Parsear el DSK terminado y comprobar contigüidad, sector inicial, extents, capacidad y que ningún byte usado cae en tracks 40–41.
10. Ejecutar tests de round-trip y, en el build ampliado, el smoke test de Caprice32.

Insertar primero el contenedor hace que empiece en el primer bloque de fichero después de los 2 KiB de directorio. No se confiará sólo en esa expectativa: el verificador extrae las allocation units del directorio y comprueba que son monótonas y contiguas. El sector inicial generado y el magic `BHRS` deben coincidir.

### 8.3 Gates automáticos

El build ampliado falla ante:

- ID o alias duplicado, dependencia ausente o ciclo.
- Recurso mayor que su slot/destino.
- Comprimido mayor de 14 KiB sin estrategia de chunks.
- Working set RAM4 > 14 KiB, habitación RAM5 > 14 KiB, audio RAM6 > 12 KiB o índice RAM7 > 2 KiB.
- Núcleo por encima de `0x35FF`, sector buffer movido o menos de 1 KiB reservado para pila.
- Solapamiento entre áreas del linker o recurso y memoria reservada.
- DSK por encima de 178 KiB asignables, más de 64 directory entries, contenedor fragmentado o uso de tracks no garantizados.
- CRC/round-trip incorrecto.
- `Build ID` del núcleo distinto al contenedor.

Targets futuros:

```text
make resources
make resource-check
make resource-report
make expanded-dsk
make expanded-smoke
```

`make sizes` debe seguir informando el high-water primario y añadir tamaño por banco, tipo, codec, habitación y disco.

## 9. Presupuesto de disco y RAM

### 9.1 Disco

Capacidad útil estándar: 178 KiB en bloques de 1 KiB, sin contar los 2 KiB del directorio.

| Componente ampliado | Objetivo | Límite recomendado |
|---|---:|---:|
| `LOADER.BAS` | 1 KiB asignado | 1 KiB |
| `LOADING.SCR` | 17 KiB asignados | 17 KiB |
| `BHBOOT.BIN` | 1–2 KiB | 2 KiB |
| `BHKERN.BIN` compacto | 13–14 KiB | 15 KiB asignados; payload ≤ 15.104 B |
| `BHRES.BIN` incluido índice/header | 100–120 KiB | 130 KiB |
| Save preasignado opcional | 0 inicialmente | 2 KiB |
| Holgura/crecimiento | 20–43 KiB según contenido | mínimo 10 KiB al publicar |

Con los ficheros actuales quedan aproximadamente 135 KiB de bloques libres. Externalizar gráficos/audio y empaquetar el núcleo debería recuperar parte de los 25 KiB actuales, pero esto es **[I]** hasta enlazar el primer núcleo bajo. La release debe reservar al menos 10 KiB para correcciones, índices y diferencias de compresión.

### 9.2 RAM

| Categoría | RAM simultánea objetivo | Nota |
|---|---:|---|
| Núcleo+constantes | ≤ 13.568 B | Incluye loaders/codecs |
| Estado+temporales+sector | 1.536 B | Excluye pila |
| Pila | 1.024 B reservados | Medir high-water |
| Render activo | ≤ 14 KiB en RAM4 | 2 KiB de guard/margen |
| Habitación | ≤ 14 KiB en RAM5 | Un slot explícito |
| Audio | ≤ 12 KiB en RAM6 | Player permanece bajo |
| Staging | 14 KiB en RAM7 | Fuente comprimida |
| Índice | ≤ 2 KiB en RAM7 | Compactado al arrancar |
| Vídeo | 32 KiB | Dos páginas primarias |

No se suman todos estos rangos como si fueran libres contiguos. En cada momento el Z80 sólo ve uno de RAM4–RAM7 en `0x4000–0x7FFF`.

## 10. Experiencia de carga

Las transiciones deben cubrir la latencia real, no prometer un objetivo arbitrario de 250 ms antes de medir una unidad física.

| Contexto | Presentación | Acción técnica |
|---|---|---|
| Cambio de planta | Ascensor, luces y número de piso | Pre-spin del motor; load de pack de área al cerrar puertas |
| Briefing | Cartela “Cargando briefing” o proyector | Retratos/textos a RAM4/RAM5 |
| Nueva habitación | Puerta, fundido o barrido | Cargar room pack y componer ambos buffers |
| Recursos administrativos | Fotocopiadora procesando | Carga de UI/inventario/minijuego |
| Mensaje/llamada | Fax dibujándose | Carga de texto y retrato |
| Error de disco | “El becario ha archivado mal el expediente” | Reintentar/cancelar sin cambiar estado |
| Cambio de volumen futuro | Gag de “cara B” | Sólo si un segundo disco llega a ser imprescindible |

F0–F4 detienen la música durante la transferencia y la reanudan/reinician después. El motor puede calentarse mientras continúa el diálogo. En F5 se puede experimentar con un sector por bloque y un tick de audio entre sectores, pero nunca pausar una transferencia de sector a mitad.

## 11. Posibilidades jugables y coste

Las cifras son rangos iniciales **[I]** por unidad de contenido, suponiendo compresión medida y un único working set activo. “Carga” es percepción esperada relativa; sólo el benchmark real dará segundos.

| Posibilidad | RAM activa | Disco por unidad | Carga | Producción gráfica/audio | Complejidad código |
|---|---:|---:|---|---|---|
| Más plantas/departamentos | 6–14 KiB de área/sala | 8–20 KiB/planta | 1 transición | Media-alta | Media |
| Fondo distinto por habitación | 4–10 KiB tiled o 16 KiB screen | 3–10 KiB comp.; hasta 16 KiB raw | 1 pack | Alta | Media |
| Exteriores de Madrid | 8–14 KiB por zona | 10–25 KiB/zona | 1–2 packs | Alta | Media |
| Briefings | 3–8 KiB | 2–8 KiB/escena | Corta | Media | Baja-media |
| Retratos en diálogo | 1–4 KiB visibles | 1–3 KiB/personaje | Cacheable | Alta | Baja |
| Más personajes | 2–6 KiB/set animado | 2–6 KiB/set | Al entrar área | Alta | Media |
| Minijuego específico | 8–14 KiB datos; overlay futuro 4–8 KiB | 10–25 KiB | Transición larga | Alta | Alta |
| Jefe con recursos propios | 8–14 KiB + audio | 10–25 KiB | Cartela previa | Alta | Media-alta |
| Cutscene | Sin RAM extra sobre VRAM+staging | 3–12 KiB/frame comp.; 16 KiB raw | Por escena/frame | Muy alta | Media |
| Inventario visual | 1–3 KiB gráficos + decenas de bytes de estado | 1–3 KiB | Inicial/área | Media | Baja-media |
| Variaciones de dificultad | Decenas–centenas de bytes | <1 KiB/tabla | Ninguna adicional | Baja | Baja |
| Música por área | 3–8 KiB en RAM6 | 3–8 KiB/tema | En transición | Alta composición | Media |
| Finales alternativos | Pantalla/escena activa | 5–20 KiB/final | Al final | Alta | Baja-media |
| Secretos opcionales | 4–14 KiB cuando activos | 3–15 KiB/secreto | Puerta/transición | Media-alta | Media |
| Guardado | 128–512 B de snapshot | 1–2 KiB por slots | Lectura/escritura explícita | Nula | Alta por fiabilidad |

Prioridad de contenido: fondos/room packs, retratos, música por área y finales ofrecen la mejor variedad por complejidad. Overlays, minijuegos grandes y guardado deben esperar a que el lector read-only y los bancos sean rutinarios.

## 12. Guardado como sistema independiente

El contenedor de recursos nunca se escribe. Un save futuro usa `BHSAVE.DAT` o un disco de datos separado, con dos slots copy-on-write:

```text
magic + versión + sequence + tamaño + estado serializado + CRC
```

Se elige el slot válido con mayor `sequence`; se escribe el otro y sólo se considera activo tras validar su CRC. El schema contiene IDs lógicos, no punteros, direcciones ni números de banco.

La arquitectura FDC inicial es deliberadamente read-only. Implementar escritura de sectores dentro del juego eleva mucho el riesgo de corromper el disco. Las opciones de F6 son, en este orden:

1. Mantener passwords/checkpoints y no guardar en disco.
2. Utilidad separada que vuelve a un entorno AMSDOS seguro y guarda `BHSAVE.DAT`.
3. Backend de escritura propio, sólo si se demuestra transaccional en disco real.

La protección de escritura, disco lleno, disco cambiado y save de versión desconocida deben ser fallos recuperables. No se reserva F6 como obligación de producto.

## 13. Estrategia DSK/CDT

### 13.1 Matriz de ediciones

| Edición | Runtime | Contenido | Estado recomendado |
|---|---|---|---|
| DSK Classic | Monolítico actual | Juego estable actual | Mantener y regresionar |
| CDT Classic | Bloque `Game` actual | Juego estable actual | Mantener como cassette principal |
| DSK Expanded | Núcleo + `BHRES.BIN` | Contenido ampliado | Nueva edición principal |
| CDT Expanded | Secuencial por capítulos | Subconjunto o contenido reordenado | Opcional, posterior |

La cinta no ofrece acceso aleatorio práctico. Un `resource_load(id)` arbitrario no puede prometer la misma semántica sobre CDT. Si se crea CDT Expanded, sus packs se ordenan por capítulo/planta y el backend sólo permite avanzar al siguiente bloque; volver atrás exigiría rebobinar y no debe ocultarse al jugador.

Recomendación: publicar DSK Expanded como edición ampliada canónica y conservar CDT Classic monolítico. Sólo crear CDT Expanded cuando el contenido se pueda estructurar en pocos bloques lineales sin empobrecer el juego.

### 13.2 Rollback de release

- `DISK_RESOURCES=0` permanece predeterminado hasta terminar F4.
- Los nombres de los artefactos ampliados son distintos.
- Ninguna fase sustituye el DSK/CDT estable; se comparan hashes y campañas contra él.
- Si una fase falla, se desactiva el flag y se publica Classic sin cherry-picks destructivos ni conversión irreversible de assets.

## 14. Plan de pruebas

### 14.1 Host/build

- Round-trip de todos los converters y codecs.
- CRC conocido de cabecera, índice y payloads.
- Tests de IDs, aliases, DAG, packing y alineación.
- Parser independiente del DSK: 40 tracks útiles, sectores `C1..C9`, directory/extents, contigüidad del contenedor.
- Test con contenedor truncado, magic/version/build ID erróneos y recurso corrupto.
- Comparación del mapa con los límites primarios y bancarios.

### 14.2 Caprice32

- Mantener `make check` y `make matrix` para Classic y, desde F4, para Expanded.
- Instrumentar un modo `BH_RESOURCE_AUTOTEST` con contadores de loads, retries, CRC y banco actual.
- Llenar la pila con patrón al arrancar y reportar high-water.
- Rodear estado y buffers bajos con canarios.
- Calcular checksums de la página de vídeo no objetivo antes/después.
- Verificar que cada salida de error restaura `RAMCFG_0`/banco esperado y silencia o reinicia audio.
- Simular DSK ausente/corrupto y confirmar timeout: el juego nunca queda esperando RQM indefinidamente.

### 14.3 CPC 6128 real

La aceptación de un backend de disco no puede depender sólo del emulador.

- CPC 6128 con unidad de 3 pulgadas y disco escrito físicamente.
- Segunda pasada con Gotek/flashfloppy, registrada por separado.
- Arranque en frío y caliente; motor inicialmente parado y ya girando.
- Repetir cambios de habitación al menos 100 veces.
- Retirar/reinsertar disco durante una transición y comprobar retry/cancel.
- Probar disco write-protected; el lector no debe intentar escritura.
- Sesión de al menos 30 minutos con audio y cambios de banco.
- Medir por recurso: spin-up, lectura, descompresión, total, retries y error rate.
- Comprobar AY sin notas colgadas, estado de partida, input, pila y ambos framebuffers tras cada carga.

No se fijará un SLA definitivo antes de esas medidas. Como criterio inicial, una transición debe terminar sin timeout y ser coherente con su animación; el informe real establecerá objetivos P50/P95 por clase.

## 15. Prueba mínima implementable

Este es el handoff concreto para el siguiente agente. No requiere todavía mover el núcleo bajo ni usar RAM expandida.

### Preparación

1. Añadir `DISK_RESOURCE_EXPERIMENT=1`; el valor `0` no cambia ningún artefacto.
2. Crear un `BHRES.BIN` mínimo con dos screens raw de 16 KiB, alineadas a sector, magic/build ID y CRC.
3. Insertarlo primero en un DSK experimental de 40 tracks y generar `BHRES_FIRST_TRACK`, `BHRES_FIRST_SECTOR` y `BHRES_AMSDOS_SKIP`.
4. Implementar el lector de un sector con timeout/retry y luego `storage_read_range()`.
5. Deshabilitar explícitamente ambas ROMs y verificar readback de VRAM; `cpct_disableFirmware()` por sí sola no cubre este contrato.
6. Mantener código/pila actuales; el lector directo no usa firmware ni pagina `0x4000`.

### Secuencia de runtime

1. Arrancar el núcleo y entrar en un modo de prueba con un contador de estado visible.
2. Rellenar guards de pila y memoria; obtener checksum de estado y framebuffer B.
3. Detener audio en un tick, silenciar AY, mostrar/fundir una cartela residente.
4. Leer `RESOURCE_BACKGROUND_1` directamente a la página oculta, validar CRC y mostrarla.
5. Reanudar audio; esperar input y demostrar que el contador de estado continuó, sin reinicio.
6. Detener audio, **sobrescribir el mismo destino** con `RESOURCE_BACKGROUND_2` —éste es el descarte explícito—, validar y mostrar.
7. Restaurar audio y comprobar guards, estado, stack high-water, banco `RAMCFG_0` y checksum de toda memoria no objetivo acordada.

### Criterios de aceptación

- Ninguno de los dos fondos aparece dentro del binario del núcleo.
- Ambos se muestran desde el DSK sin volver a BASIC ni reiniciar.
- El segundo sustituye al primero; no quedan ambos residentes.
- CRC, build ID y tamaños son correctos.
- El contador/estado persistente mantiene su valor.
- El guard de pila no se corrompe y deja al menos 256 B de margen medido.
- La página de vídeo no objetivo conserva su checksum durante cada load.
- El audio queda silencioso durante I/O, no deja notas colgadas y vuelve a sonar después.
- Tras éxito y error, el banco lógico sigue siendo `RAMCFG_0`.
- Un sector corrupto o disco ausente produce retry limitado y una pantalla de error, nunca un cuelgue.
- Se reproduce en Caprice32 y al menos un CPC 6128 real.

Este experimento valida exactamente el camino crítico sin mezclar aún tilemaps, caché o overlays.

## 16. Hoja de ruta incremental

### Fase 0 — Medición y pruebas aisladas

Trabajo:

- Congelar baseline de hashes, mapa, DSK/CDT y campañas.
- Medir stack real con patrón.
- Crear packer/inspector mínimo y un lector de sector FDC en harness.
- Probar magic/build ID/CRC y errores/timeouts.
- Opcional y time-boxed: un harness AMSDOS de un solo framebuffer para comparar tamaño/latencia; no condiciona producción.

Aceptación:

- El lector obtiene dos veces un sector canario conocido en Caprice32 y CPC real.
- Ningún wait de FDC carece de timeout.
- Se documentan tamaños de código y tiempos frío/caliente.
- `make parallel-build`, `make check`, `make matrix` y hashes Classic siguen correctos.

Rollback: desactivar/eliminar del build el target experimental; no hay cambios en runtime Classic.

### Fase 1 — Dos pantallas externas desde DSK

Trabajo: implementar la prueba mínima de la sección 15 con el contenedor ya definitivo en pequeño.

Aceptación: todos los criterios de la sección 15, incluidos error path, audio, stack, estado, framebuffer y hardware real.

Rollback: `DISK_RESOURCE_EXPERIMENT=0`; el loader y artefactos Classic permanecen intactos.

### Fase 2 — Sistema genérico de recursos

Trabajo:

- Manifest completo, IDs generados, índice, dependencias, CRC y API.
- Packer, informe y validadores DSK/RAM.
- Cargar screen, sprite set, texto y room pack a destinos explícitos.
- Mantener cargas síncronas y slots estáticos.

Aceptación:

- 100 ciclos de load/unload con recursos de al menos cuatro tipos.
- Fallos de ID, versión, CRC y capacidad probados.
- Ningún caller conserva punteros bancables; análisis estático/checks lo verifican en las APIs.
- Build determinista: mismo input produce mismo contenedor y DSK.

Rollback: mantener F1 como demo fija o volver a Classic mediante flag; formato versionado permite descartar el contenedor nuevo.

### Fase 3 — Caché en memoria expandida

Trabajo:

- Relocalizar núcleo, datos y pila por debajo de `0x4000`.
- Añadir `bank_push/pop`, guards y slots RAM4–RAM7.
- Migrar primero sprites/fuente; después habitación y staging. Audio puede seguir primario.

Aceptación:

- Bootstrap RAM7 → memoria baja verificado con error path; mapa cumple cada límite de la sección 5.3.
- Tests escriben patrones distintos en RAM4–RAM7 y los recuperan sin alterar RAM primaria.
- 10.000 cambios de banco en emulador y sesión de 30 minutos real sin corrupción.
- Matrix completa con stack high-water y generación de handles verificadas.

Rollback: build F2 sin paginación; no cambiar el formato de recursos por la caché.

### Fase 4 — Habitaciones y fondos intercambiables

Trabajo:

- Definir room pack tiled, tiles, decorado, colisión y dependencias.
- Implementar `room_enter()` transaccional y componer ambos buffers.
- Introducir ascensor/puerta/fundidos con métricas.

Aceptación:

- Agencia mínima con al menos tres habitaciones de fondos distintos.
- 100 transiciones encadenadas, incluidas vueltas atrás y fallo de disco.
- Estado de campaña y dificultad no cambia salvo commit explícito.
- Classic y Expanded superan la matrix; DSK real cumple 40 tracks y presupuesto.

Rollback: seleccionar renderer procedural/Classic mediante flag y conservar los room packs sin usarlos.

### Fase 5 — Audio, escenas y contenido ampliado

Trabajo:

- Llevar canción/SFX de área a RAM6 y paginar en `bh_audio_tick()`.
- Añadir retratos, briefings, cutscenes y música por área.
- Evaluar, no asumir, lectura de un sector entre ticks o pre-spin durante diálogo.
- Evaluar overlays sólo si el núcleo incumple su gate tras extraer datos fríos.

Aceptación:

- 50 cambios de música/escena sin nota colgada ni handle inválido.
- Carga/error siempre restaura banco y estado del player.
- Presupuestos por área y DSK visibles en CI.
- Cualquier overlay tiene ABI, checksum y prueba de retorno; si no, queda fuera.

Rollback: audio residente de F4 y escenas reducidas; cada familia de recurso puede desactivarse en manifest.

### Fase 6 — Guardado, si resulta viable

Trabajo:

- Serialización versionada independiente.
- Dos slots, sequence y CRC.
- Prototipo AMSDOS separado o backend de escritura sólo tras revisión específica.

Aceptación:

- Power-loss simulado entre cada paso deja al menos un slot válido.
- Disco lleno, cambiado, ausente y write-protected son recuperables.
- Save de versión vieja se migra o rechaza con mensaje; nunca corrompe recursos.
- 100 ciclos save/load en emulador y hardware real.

Rollback: passwords/checkpoints; el lector de recursos permanece read-only y el juego no depende de un save.

## 17. Riesgos y decisiones abiertas

| Riesgo/pregunta | Estado | Experimento/mitigación |
|---|---|---|
| El núcleo nuevo no cabe bajo `0x3600` | **[E]** | Enlazar F0/F2; extraer logo/tablas/lógica fría antes de overlays |
| Latencia de motor y unidad real | **[E]** | Benchmark frío/caliente; mantener motor durante transición |
| Compatibilidad exacta del lector 765 | **[E]** | Caprice32 + unidad 3" + Gotek; timeouts/recalibrate |
| Ratio ZX7B de arte final | **[E]** | Informe por asset; raw fallback |
| Audio desde RAM6 dentro de 50 Hz | **[E]** | Medir ciclo y guard de banco en F5 |
| Índice compacto ≤ 2 KiB | **[I]** | Límite de entradas y descriptor compacto; split por grupos si no cabe |
| Guardado fiable | **[E]** | F6 opcional; passwords como rollback |
| CDT ampliado útil | **[I]** | Prototipo lineal sólo tras fijar contenido DSK |

## 18. Fuentes técnicas

Fuentes primarias/oficiales utilizadas:

- [Amstrad DDI-1 User Manual](https://cpctech.cpcwiki.de/docs/manual/ddi-1.pdf): headers AMSDOS, `0x500` bytes de workspace, estrategia de loader bajo, errores, 512 B/sector, 40 tracks, nueve sectores DATA, bloques de 1 KiB y 64 entradas.
- [Amstrad CPC464/664/6128 Firmware — sección 1](https://cpctech.cpcwiki.de/docs/manual/s968se01.pdf): organización del firmware y AMSDOS/cassette manager.
- [Amstrad CPC464/664/6128 Firmware — sección 2](https://cpctech.cpcwiki.de/docs/manual/s968se02.pdf): mapa de memoria del firmware y pantalla por defecto.
- [Amstrad CPC464/664/6128 Firmware — jumpblocks](https://cpctech.cpcwiki.de/docs/manual/s968se14.pdf): contratos y entry points `CAS IN OPEN`, `CAS IN DIRECT` y `CAS IN CLOSE`.
- [Amstrad CPC464/664/6128 Firmware — apéndice de vídeo](https://cpctech.cpcwiki.de/docs/manual/s968ap12.pdf): organización de la pantalla de 16 KiB y bancos visibles por el CRTC.
- [NEC µPD765 data sheet](https://www.bitsavers.org/components/nec/_dataSheets/uPD765_Data_Sheet_Dec78.pdf): fases de comando/ejecución/resultado, comandos, EOT y registros de estado del controlador.

Fuentes técnicas contrastadas con el código del proyecto/toolchain:

- [CPC RAM paging](https://cpctech.cpcwiki.de/docs/rampage.html): configuraciones de RAM primaria/secundaria y restricción de vídeo a los primeros 64 KiB.
- [CPC floppy controller](https://cpctech.cpcwiki.de/docs/fdc.html): puertos, polling, motor y conexiones ausentes del NEC 765A.
- `.tools/cpctelera/cpctelera/src/memutils/cpct_pageMemory.asm`: tabla exacta de `RAMCFG_0..7` usada por la versión local de CPCtelera.
- `.tools/cpctelera/cpctelera/src/firmware/cpct_removeInterruptHandler.s`: handler retornado por `cpct_disableFirmware()` y rango RAM de firmware advertido por CPCtelera.

Las páginas técnicas no oficiales se usan para concretar el cableado/puertos del CPC y se validarán contra comportamiento real en F0. Las decisiones de formato AMSDOS y geometría se apoyan en el manual Amstrad.
