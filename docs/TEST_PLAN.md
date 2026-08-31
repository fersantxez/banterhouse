# Plan de pruebas de Banterhouse

Este plan cubre desde la primera refactorización hasta el DSK final. El objetivo
no es demostrar solo que compila: debe detectar corrupción de memoria, softlocks,
ataques injustos, regresiones de canon y problemas de ritmo.

## 1. Entornos

| Entorno | Uso | Obligatorio |
|---|---|---|
| macOS ARM64 + Clang | Lógica pura, validadores y empaquetado. | En cada cambio. |
| SDCC 4.6 + CPCtelera local | Build real Z80. | En cada cambio. |
| Caprice32 ARM64 4.6 | Smoke, replays y perfilado principal. | En cada hito. |
| Caprice32 local + usuario | Sesiones observadas con control físico del juego. | Vertical slice, alpha y RC. |
| Segundo emulador compatible 6128 | Diferencias de timing, CRTC, AY y disco. | Desde alpha. |
| CPC 6128 real | Vídeo, joystick, audio y carga física. | Antes de publicar, si está disponible. |

La configuración PAL de 50 Hz es la autoridad. No se optimiza para un emulador
que ejecute el Z80 más rápido de lo debido.

## 2. Capas de prueba

1. **Validación estática:** assets, TMX, grafos, bancos y mapa de enlace.
2. **Unitarias host:** física, colisión, IA, passwords, progreso y boss.
3. **Integración Z80:** bancos, render, audio, input y carga de sala.
4. **Replay determinista:** secuencias de input con hashes de estado.
5. **Campaña funcional:** nivel por nivel, caminos normales y alternativos.
6. **Rendimiento y soak:** peor caso, pila, memoria y horas de juego.
7. **Juego manual de Codex:** cinco campañas reales en Caprice32.
8. **Playtest humano:** comprensión, justicia, dificultad y diversión.
9. **Compatibilidad de release:** arranque, medios y máquina real.

## 3. Automatización prevista

```text
make                 build normal
make clean-build     build serial desde cero
make parallel-build  build -j2 desde cero
make check           validadores + unitarias host + tamaños
make replay          golden replays en build debug
make matrix          10 niveles x 5 dificultades y resumen de cobertura
make smoke           arranque limitado en Caprice32
make playtest-build  DSK debug con selector de nivel, sala y dificultad
make sizes           memoria residente y bancos
make release         DSK reproducible sin flags debug
```

Ninguna de estas nuevas reglas existe todavía. M0 del plan de implementación
las crea antes de añadir gameplay.

## 4. Instrumentación debug

- Guard bytes antes y después de mapa, entidades, cola SFX y estado de nivel.
- Stack watermark en `0x3C00–0x3FFF`.
- Sentinelas diferentes en RAM1 y RAM4–RAM7.
- Borde por etapa: input, audio, lógica, IA, borrado y dibujo.
- Contadores de frame perdido, entidades, dirty tiles y cambios de banco.
- Últimos 32 eventos en ring buffer: sala, spawn, estado de Alberto, tiro, golpe,
  pickup y cambio de fase.
- Comando debug para mostrar cajas y línea de visión; nunca en release.
- Selector debug de nivel, sala, fase del jefe, dificultad y estado de Carga.
- Volcado compacto de perfil, tick y hash al pausar una sesión de usuario.
- Semilla fija para cualquier detalle pseudoaleatorio no jugable.

## 5. Validación de contenido

### Mapas

| ID | Comprobación | Resultado exigido |
|---|---|---|
| MAP-01 | Dimensiones TMX. | Exactamente 20×23. |
| MAP-02 | Tile IDs. | Todos entre 0 y 63. |
| MAP-03 | Spawn de Pitu. | Caja libre y dentro de área. |
| MAP-04 | Puertas. | Destino válido y vecino recíproco. |
| MAP-05 | Grafo de planta. | Tres salas alcanzables y bucle final. |
| MAP-06 | Objetivo. | Número y disciplina coinciden con GDD. |
| MAP-07 | Salto cian. | Origen y destino libres; distancia exacta. |
| MAP-08 | Patches. | No escriben fuera del mapa ni sobre Pitu. |
| MAP-09 | Waypoints. | Enlaces transitables por Alberto. |
| MAP-10 | Salida. | Alcanzable con cada estado persistente permitido. |

Se ejecuta además un flood fill por cada combinación de puertas y patches. Si
una combinación válida aísla objetivo o salida, el build falla.

### Gráficos

| ID | Comprobación | Resultado exigido |
|---|---|---|
| GFX-01 | Dimensiones. | Múltiplos compatibles con Modo 0 y renderer. |
| GFX-02 | Paleta. | Solo las 16 tintas del juego. |
| GFX-03 | Alpha. | Binario, sin píxeles semitransparentes. |
| GFX-04 | Máscara. | Tamaño y stride coinciden con metadata. |
| GFX-05 | Pitu. | Invariantes y píxeles bloqueados coinciden. |
| GFX-06 | Alberto. | Pelo corto, gafas, nariz, dientes, traje y corbata. |
| GFX-07 | Señales. | Color siempre acompañado de forma. |
| GFX-08 | Portada. | 160×200, BANTERHOUSE legible y una sola vez. |

### Bancos

- Cada binario ≤16.384 B; objetivo de contenido ≤14.336 B cuando sea posible.
- Offsets ordenados, dentro del banco y sin solapamiento.
- Hash de cada input y output en manifiesto.
- Resident high-water mark por debajo de `0x3C00`.
- El mismo árbol de fuentes produce hashes idénticos en dos builds limpios.

## 6. Unitarias host

La lógica se compila con tipos `u8/i8/u16` equivalentes y sin hardware.

### Movimiento y colisión

- `PHY-01`: caminar contra cada lado de un tile no penetra ni vibra.
- `PHY-02`: diagonal alternada termina en la posición prevista.
- `PHY-03`: coordenadas 0 y máximas no desbordan.
- `PHY-04`: puerta inválida no modifica sala ni spawn.
- `PHY-05`: transición válida usa el spawn opuesto correcto.
- `PHY-06`: salto válido recorre ocho frames y aterriza exactamente.
- `PHY-07`: salto con destino bloqueado no comienza.
- `PHY-08`: un patch nunca aparece debajo de una caja activa.
- `PHY-09`: briefing se destruye al primer tile sólido.
- `PHY-10`: invulnerabilidad de entrada dura doce ticks, no trece.

### Estado y progreso

- `STA-01`: cada pieza activa un único bit.
- `STA-02`: burnout conserva piezas y consume un café.
- `STA-03`: game over ocurre solo al agotar café.
- `STA-04`: checkpoint tras piezas 4, 8 y 12.
- `STA-05`: continue reinicia planta, no campaña.
- `STA-06`: password válido reconstruye nivel y progreso previstos.
- `STA-07`: un carácter alterado invalida o decodifica otro estado permitido,
  nunca memoria arbitraria.
- `STA-08`: recuperación de café no puede repetirse al reentrar.
- `STA-09`: chispas fuera de orden no bloquean salida.

### Dificultad

- `DIF-01`: solo se aceptan los cinco identificadores definidos; cualquier valor
  corrupto cae en Normal sin leer fuera de la tabla.
- `DIF-02`: los ocho parámetros de cada perfil coinciden byte a byte con el GDD.
- `DIF-03`: las máscaras de movimiento producen exactamente 4, 5, 6, 7 y 8
  pasos por cada ciclo de ocho decisiones.
- `DIF-04`: cambiar perfil no modifica geometría, piezas, flags de sala,
  velocidad de Pitu, límite de entidades ni solución del jefe.
- `DIF-05`: una petición desde pausa se aplica en la próxima transición y no
  altera un temporizador activo a mitad de tick.
- `DIF-06`: bajar tras burnout se aplica antes del respawn y conserva piezas.
- `DIF-07`: password codifica y restaura dificultad con checksum válido.
- `DIF-08`: cada perfil muestra el número correcto de huecos de Carga y cafés.
- `DIF-09`: todas las ayudas mantienen aviso sonoro y visual; ninguna mecánica
  imprescindible depende del marcador del mapa.
- `DIF-10`: puntuación, tablas y rango no desbordan `u16` y quedan etiquetados
  con su perfil.

### Grafo e IA

- `AI-01`: patrulla sigue vecinos autorizados.
- `AI-02`: ruido reemplaza temporalmente el destino.
- `AI-03`: Alberto no conoce una sala sin evento o visión.
- `AI-04`: entrar en sala aplica un segundo sin tiro.
- `AI-05`: detección exige línea de visión.
- `AI-06`: aviso dura exactamente 32/28/24/20/18 ticks según perfil.
- `AI-07`: solo se crea un briefing.
- `AI-08`: cooldown dura exactamente 75/65/55/48/40 ticks según perfil.
- `AI-09`: al perder visión visita última posición y sale.
- `AI-10`: spawn ocupado selecciona fallback seguro.
- `AI-11`: puerta privada del nivel 8 solo se usa tras activación.
- `AI-12`: todos los estados alcanzan otro estado; no hay bucle muerto.

### Jefe

- `BOS-01`: fases comienzan en estado conocido.
- `BOS-02`: cuatro paneles únicos conceden primer sello.
- `BOS-03`: patch grande/pequeño se aplica solo durante corte.
- `BOS-04`: dos controles válidos conceden segundo sello.
- `BOS-05`: briefing solo destruye la bandeja desde línea válida.
- `BOS-06`: fax siempre permite colocar a Alberto para ese tiro.
- `BOS-07`: burnout reinicia fase y conserva sellos anteriores.
- `BOS-08`: tercer sello dispara final una sola vez.
- `BOS-09`: 100 replays con rutas válidas terminan sin softlock.
- `BOS-10`: la ventana de control dura 100/85/70/60/50 ticks y nunca cambia la
  secuencia ni la solución de la fase.

## 7. Integración Z80

### Memoria y bancos

- `MEM-01`: escribir patrón distinto en cinco ventanas y releerlo.
- `MEM-02`: audio pagina RAM5 y vuelve a RAM1 cada tick.
- `MEM-03`: transición pagina RAM4 y restaura antes de dibujar.
- `MEM-04`: 100.000 cambios no modifican framebuffers.
- `MEM-05`: portada en RAM6 se libera lógicamente al empezar.
- `MEM-06`: jefe usa RAM7 y las copias de Pitu, Alberto, briefing y HUD coinciden
  con las versiones del banco común.
- `MEM-07`: guard bytes permanecen intactos tras campaña completa.
- `MEM-08`: pila conserva al menos 384 B en peor caso.

### Vídeo

- Ambos framebuffers contienen la misma sala tras entrada.
- Ningún sprite deja rastro al moverse en fondo no uniforme.
- Un sprite de cada tamaño se borra con su propio stride.
- El CRTC cambia de página una vez por frame presentado.
- HUD no parpadea al cambiar sala o banco.
- Parches modifican ambas páginas antes de devolver control.

### Entrada

- QAOP, cursores y joystick producen las mismas acciones.
- Teclas opuestas simultáneas cancelan el eje.
- Pulsación mantenida no reactiva una máquina sin soltar.
- Pausa congela lógica pero mantiene audio previsto o lo silencia limpiamente.
- Al volver de pausa no queda una acción fantasma.

### Audio

- Player llamado exactamente 50 veces por segundo en ejecución estable.
- SFX de alerta tiene prioridad sobre todos.
- Un SFX puede robar canal C sin cortar bajo ni corromper canción.
- Cambio de tema ocurre en transición, no durante render crítico.
- Stop/restart no deja un tono sostenido.

## 8. Replays dorados

Cada replay contiene versión, semilla, estado inicial y bits de input por tick.
Cada 25 ticks se guarda un hash de:

```text
nivel, sala, dificultad, Pitu, Alberto, briefing, carga, cafes,
piezas, flags de sala, boss y score
```

Replays mínimos:

1. Arranque, menú y nivel 1.
2. Cuatro puertas en ambos sentidos.
3. Teléfono atrae a Alberto entre salas.
4. Tres impactos en Normal, burnout y reaparición.
5. Salto cian válido e inválido.
6. Fotocopiadora y checkpoint 1.
7. Cristal, viento y luz.
8. Fax y puerta privada.
9. Doce piezas y entrada al Consejo.
10. Cada fase del Presidente.
11. Campaña completa sin impactos.
12. Campaña completa con continues y passwords.
13. Una campaña completa por cada dificultad.
14. Cambio permitido de dificultad y restauración por password.

Además hay un replay de finalización por cada par nivel/perfil: **10 × 5 = 50
casos obligatorios**. Los cinco del nivel 10 recorren las tres fases. Un informe
generado enumera caso, seed, ticks, impactos, burnouts, hash final y resultado;
una celda vacía hace fallar `make matrix`.

Cualquier cambio de hash requiere explicación y actualización deliberada; no se
acepta regenerar todos los goldens para ocultar una regresión.

## 9. Pruebas por nivel

| Nivel | Mecánica que debe demostrarse | Fallos específicos a buscar |
|---|---|---|
| 1 | Cobertura y línea de tiro. | Primer briefing puede golpear; objetivo no visible. |
| 2 | Teléfono y escondite. | Alberto no cambia destino o ve a través de cristal. |
| 3 | Salto contextual. | Destino ambiguo, dependencia solo del cian. |
| 4 | Ciclo de fotocopiadora. | Ruido sin aviso; checkpoint pierde piezas. |
| 5 | Patches de cristal. | Pitu emparedada o dos salidas cerradas. |
| 6 | Atajo y viento. | Ráfaga daña o empuja entidad equivocada. |
| 7 | Luz y visión. | Pitu ilegible; se aumenta otra dificultad a la vez. |
| 8 | Fax y atajo de Alberto. | Teletransporte, aparición encima de Pitu. |
| 9 | Proyector y persistencia. | Patch sin preview; persecución imposible de cortar. |
| 10 | Tres fases reutilizadas. | Regla nueva, fase reiniciada de más o softlock. |

Para cada planta se completan al menos estas rutas:

- Óptima con chispas en orden.
- Directa ignorando bonus.
- Ruta contraria por las tres puertas.
- Con Alberto atraído a cada sala.
- Tras burnout en cada habitación.
- Desde password de esa planta.

La cobertura se reparte sin multiplicar innecesariamente las partidas humanas:

- Automatización: las 50 combinaciones nivel/dificultad, todas las rutas de la
  lista anterior en Normal y campaña completa en cada perfil.
- Juego manual de Codex: cinco campañas completas, una por perfil, desde la
  portada hasta el final y sin reproducción automática.
- Playtest del usuario: campaña completa en Normal, niveles 1–2 en los cinco
  perfiles, niveles 8–10 en Muy difícil y jefe en los cinco perfiles.
- Alpha externo: al menos una observación humana de cada nivel; Fácil, Normal y
  Difícil deben estar representados y Muy fácil/Muy difícil se prueban con el
  público al que van dirigidos.

## 10. Rendimiento

### Umbrales

| Métrica | Objetivo | Fallo de release |
|---|---:|---:|
| Tick audio | ≤2 ms | >3 ms |
| Lógica + render peor caso | ≤36 ms típico | >40 ms repetido |
| Frecuencia de lógica | 25 Hz | <24 Hz sostenido |
| Transición de sala | ≤250 ms | >400 ms |
| Dirty tiles por entidad | Los necesarios por bbox | Área fija de Pitu usada para todos. |
| Entidades activas | ≤8 | >10 |
| Briefings | 1 | >1 |
| Pila libre | ≥384 B | <256 B |
| Banco | ≤16.384 B | Cualquier exceso |

Salas de peor caso:

- Nivel 4 con fotocopiadora, Pitu, Alberto, briefing, pieza y SFX.
- Nivel 7 durante cambio de luz.
- Nivel 9 con proyector y persecución persistente.
- Fase 3 del jefe con fax, briefing, patch y música.

Se mide con colores de borde y contadores, primero en Caprice32 y después en la
segunda implementación o máquina real.

## 11. Soak y corrupción

- Dos horas alternando salas sin completar nivel.
- 1.000 transiciones de puerta mediante replay.
- 1.000 pickups y resets de sala.
- 10.000 lanzamientos destruidos contra paredes.
- 100 campañas automáticas con input válido.
- Pausa/reanudación 500 veces.
- Música y SFX simultáneos durante 30 minutos.

Al final se verifican guards, stack, sentinelas bancarios, estado de CRTC y hash
de datos inmutables.

## 12. Juego manual y playtest humano

### Cualificación jugada por Codex — obligatoria y anterior al usuario

Estas pruebas forman parte de la entrega, no son una recomendación para después.
Se usa Caprice32 ARM64 y el DSK candidato producido por `make release`. El DSK
de `make playtest-build` queda reservado para aislar casos después, no para dar
por superada una campaña.

Codex controla directamente Pitu mediante el teclado del emulador. Cada acción
se decide observando la pantalla y el estado actual; un replay, macro de inputs,
bot, fast-forward o campaña simulada no cuenta como partida jugada. Se permiten
pausa y capturas, pero no warp, selector debug, invulnerabilidad, estado
inyectado ni salto de nivel.

Sobre un mismo release candidate se completan, en este orden:

| Sesión | Dificultad | Recorrido obligatorio | Resultado |
|---|---|---|---|
| C1 | Normal | Portada, niveles 1–10, jefe y final. | Base funcional completa. |
| C2 | Muy fácil | Portada, niveles 1–10, jefe y final. | Enseña y tolera errores. |
| C3 | Muy difícil | Portada, niveles 1–10, jefe y final. | Exigente sin daño obligatorio. |
| C4 | Fácil | Portada, niveles 1–10, jefe y final. | Escalón coherente entre C2 y C1. |
| C5 | Difícil | Portada, niveles 1–10, jefe y final. | Escalón coherente entre C1 y C3. |

Cada campaña empieza con `NUEVA PARTIDA`; no se usa password para omitir
contenido. Debe recoger las doce piezas, provocar y evitar briefings, usar al
menos una vez cada familia de interacción, sufrir un burnout controlado, probar
pausa/mapa, superar las tres fases del Presidente y ver el final completo.

Si aparece un P0/P1, la campaña se detiene, se corrige y se repite desde la
portada. Un cambio de motor, estado, mapa o dificultad invalida C1–C5; un cambio
puramente audiovisual repite la escena afectada y C1. El usuario no recibe una
build hasta que C1–C5 estén verdes en el mismo candidato.

### Sesiones posteriores con el usuario

El reparto de control evita mezclar inputs:

1. Codex demuestra que C1–C5 y la matriz automática están verdes, compila y abre
   Caprice32.
2. Codex selecciona nivel, sala, seed, dificultad y estado inicial desde el menú
   debug; verifica en pantalla el caso exacto.
3. Se hace una entrega explícita del control. El usuario juega con teclado o
   joystick y Codex no inyecta teclas durante ese intento.
4. Al terminar o encontrar un fallo, el usuario devuelve el control. Codex
   pausa, captura pantalla y estado, guarda replay y anota pasos observables.
5. Codex reinicia el checkpoint o prepara el siguiente caso. Ningún fallo se
   acepta solo de memoria: debe quedar replay o pasos, build, seed y perfil.

Para cada sesión de Codex o del usuario se copia
[`playtests/SESSION_TEMPLATE.md`](playtests/SESSION_TEMPLATE.md) como
`docs/playtests/AAAA-MM-DD-sesion-N.md` y se conserva:

- commit y hashes del DSK/bancos;
- emulador, configuración PAL, teclado o joystick;
- caso, seed, perfil, tiempos, impactos, burnouts y resultado;
- observaciones literales separadas de inferencias;
- capturas y replay asociados;
- defectos con severidad, pasos y estado de corrección.

Calendario mínimo, siempre posterior a C1–C5, con el usuario del proyecto:

| Sesión | Momento | Casos que se juegan aquí | Puerta |
|---|---|---|---|
| U1 Controles y escala | Tras C1–C5 | Laboratorio y niveles 1–2 en los cinco perfiles. | Sin input fantasma; diferencias perceptibles. |
| U2 Campaña | Tras U1 | Nueva partida hasta final en Normal, sin menú debug. | Final completo y sesión sin P0/P1. |
| U3 Extremos | Tras U2 | Niveles 8–10 en Muy difícil y jefe en los cinco perfiles. | Muy difícil es justo; ventanas escalan bien. |

Un fallo P0/P1 invalida la sesión, devuelve la build a la cualificación de Codex
y exige repetir C1–C5 antes de devolvérsela al usuario. Un cambio de balance
repite los casos afectados en las cinco dificultades y las campañas C
afectadas; un cambio de motor repite C1–C5 y U2 completa.

### Vertical slice

Cinco personas nuevas, sin instrucciones orales. Registrar:

- Tiempo hasta primer movimiento, pickup, interacción y uso consciente de ruido.
- Si explican correctamente por qué Alberto las encontró.
- Impactos que consideran injustos.
- Salas donde no vieron salida u objetivo.
- Tiempo y burnouts por nivel.
- Frases espontáneas y momentos de risa o frustración.

### Alpha

Al menos doce personas repartidas entre experiencia CPC y jugadores nuevos.

Criterios:

- 80 % completa nivel 1 en ≤5 minutos.
- 80 % identifica aviso de briefing antes del primer impacto.
- 70 % descubre una interacción de ruido sin leer manual.
- Ninguna mecánica depende exclusivamente del color.
- La mediana completa el jefe en cuatro intentos o menos.
- Ningún participante necesita dibujar un mapa externo.

Por dificultad:

- Muy fácil: 90 % de personas nuevas completa nivel 1 sin game over.
- Fácil: 80 % completa niveles 1–2 con un burnout o menos.
- Normal: conserva los criterios principales anteriores.
- Difícil: 70 % de jugadores experimentados completa el nivel asignado tras
  aprender su ruta, sin declarar impactos inevitables.
- Muy difícil: al menos tres jugadores expertos completan una planta tardía y
  uno completa el jefe; todos los impactos deben poder atribuirse a una decisión.

No se pregunta solo si «gusta». Se observan decisiones, errores, tiempo muerto y
si las reglas se pueden explicar después de jugar.

## 13. Canon y derechos

- Comparar cada nuevo frame de Pitu con su fuente canónica.
- Revisar Alberto contra la hoja completa, no contra una portada derivada.
- Presidente, Carlitos y Art necesitan aprobación de identidad a tamaño 1×.
- Confirmar que música, texto, layouts y gags son nuevos.
- Bloquear distribución pública si falta autorización para personajes literales.

## 14. Severidad

| Severidad | Ejemplos | Política |
|---|---|---|
| P0 | Corrupción, cuelgue, DSK no arranca, pérdida de estado. | Bloquea toda build. |
| P1 | Softlock, nivel imposible, golpe invisible, password incorrecto. | Bloquea hito y release. |
| P2 | Caída de frames repetida, pista deficiente, colisión molesta. | Cero conocidos antes de RC salvo excepción escrita. |
| P3 | Detalle visual, texto o timing menor. | Priorizar antes de publicación. |

## 15. Puertas de release

Un release candidate solo se etiqueta cuando:

- `make clean-build`, `parallel-build`, `check`, `replay` y `sizes` pasan.
- No hay P0, P1 ni softlocks conocidos.
- No hay P2 de gameplay conocido; cualquier P3 restante está enumerado.
- Las treinta pantallas se completan por rutas normal y alternativa.
- `make matrix` confirma los 50 pares nivel/dificultad y cinco campañas
  automáticas completas.
- Todos los passwords arrancan en el estado correcto.
- Peor caso mantiene 25 Hz y memoria dentro de presupuesto.
- Dos campañas completas consecutivas no alteran guards ni sentinelas.
- Audio funciona con SFX en las cuatro escenas de peor caso.
- Pitu y reparto pasan revisión canónica.
- DSK arranca en dos implementaciones; idealmente una es CPC 6128 real.
- C1–C5 fueron jugadas directamente por Codex, de portada a final y sobre el
  mismo candidato, antes de U1.
- U1–U3 están realizadas; U2 se completó en el build candidato y el jefe fue
  jugado por el usuario en los cinco perfiles.
- El informe final enlaza cada requisito a prueba, replay, sesión o excepción;
  no queda ninguna celda de cobertura en estado «no ejecutada».
- Manual, créditos, licencias, permisos y hashes acompañan al paquete.
