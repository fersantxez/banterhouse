# Plan de implementación de Banterhouse

Plan de principio a fin para una persona desarrolladora con apoyo puntual de
arte, level design, música y pruebas. Las duraciones son jornadas de desarrollo,
no fechas comprometidas. Ordenan dependencias: no se produce contenido sobre
una base de memoria todavía inestable.

Estimación total orientativa: **80–110 jornadas**, aproximadamente 16–22 semanas
a tiempo completo. El vertical slice debe existir en 33–45 jornadas. La cifra
incluye balance de cinco dificultades, sesiones de usuario y regresión final;
no trata las pruebas como trabajo posterior al juego.

## 1. Estado de partida

El commit base `2fbbab2` compila y produce:

- `banterhouse.bin`: 13.614 B.
- DSK y CDT arrancables.
- Modo 0, doble buffer, Pitu, colisión básica y cambio de pantalla.

No existen todavía IA, briefing, objetivo, daño, HUD funcional, audio, jefe ni
tests. Solo hay un mapa de 20×23 reutilizado. `AI()` y `collisions()` están
vacías.

Bloqueos conocidos:

- El código está en `0x4000`, justo donde deben paginarse RAM4–RAM7.
- Solo quedan 2.054 B entre datos y pila.
- `TEMP_X/TEMP_Y` escriben en `0xFFFE/0xFFFF`, dentro de vídeo.
- La salida izquierda y varios índices pueden desbordar.
- El tercer frame de Pitu se sobrescribe y el renderer asume su tamaño.
- El build limpio paralelo tiene una carrera al generar `tileset-03.h`.
- No hay validación automática de mapas, bancos, sprites o memoria.

## 2. Arquitectura de destino

```text
src/
  core/       main loop, estados, timing, input, bancos y asserts
  world/      niveles, habitaciones, carga, grafo y persistencia
  entity/     Pitu, Alberto, briefing y entidades genéricas
  systems/    física, colisión, IA, interacción, pickups y boss
  render/     tilemap, sprites, dirty tiles, HUD y transiciones
  audio/      player Arkos y cola de efectos
  data/       descriptores residentes mínimos
assets-src/   fuentes editables y TMX
generated/    bancos y cabeceras regenerables
tests/host/   lógica compilable en el Mac
tools/        validadores y empaquetado
```

Los archivos generados no se editan a mano. La lógica pura no incluye
`cpctelera.h`; recibe structs pequeños y puede probarse con Clang en el Mac.

## 3. Hitos

| Hito | Jornadas | Resultado | Puerta de salida |
|---|---:|---|---|
| M0 Baseline reproducible | 2–3 | Build y smoke fiables. | Serial y paralelo limpios; binario medido. |
| M1 Memoria 128K | 6–9 | Residente bajo `0x4000`, bancos cargados. | Sentinelas de RAM4–7 intactos; pila medida. |
| M2 Motor estable | 6–8 | Entidades, colisión, puertas y doble buffer fiables. | Diez minutos de replay sin corrupción. |
| M3 Movimiento, interacción y dificultad | 6–9 | Control final, salto contextual y cinco perfiles. | Sala de pruebas completa con teclado y joystick en los cinco perfiles. |
| M4 Pipeline de contenido | 4–6 | TMX, bancos, validadores y descriptores. | Un mapa se regenera desde cero y pasa `make check`. |
| M5 Vertical slice L1–L2 | 11–14 | Seis salas, Alberto, briefing y dos piezas. | Tester nuevo completa ambos niveles sin explicación; sesión local registrada. |
| M6 Primer acto L3–L4 | 6–8 | Salto, repro y primer storyboard. | Código de nivel y checkpoint correctos. |
| M7 Segundo acto L5–L7 | 8–10 | Cristal, viento, luz y segundo storyboard. | Plantas completas dentro de presupuesto. |
| M8 Tercer acto L8–L9 | 7–9 | Fax, atajo de Alberto y campaña completa. | Doce piezas y progresión verificadas. |
| M9 Jefe y final L10 | 7–10 | Presidente, tres fases y final. | Cien replays deterministas y las cinco dificultades sin softlock. |
| M10 Arte y audio final | 7–10 | Assets CPC, música, SFX, portada y finales. | Canon, paleta y mezcla aprobados. |
| M11 Alpha y optimización | 12–16 | Juego completo equilibrado y matriz QA cerrada. | Cero P0/P1/P2 de gameplay; 50 combinaciones nivel/dificultad y playtests completos. |
| M12 Release | 4–6 | DSK, manual, evidencias y paquete reproducible. | Dos emuladores o un emulador y CPC real. |

## 4. M0 — Baseline reproducible

1. Registrar versiones de CPCtelera, SDCC y Caprice32.
2. Corregir dependencias Make para que `make clean && make -j2` espere a los
   headers generados.
3. Añadir `make check`, `make smoke` y `make sizes`.
4. Guardar tamaño de `_CODE`, `_DATA`, final de BSS y margen de pila.
5. Añadir build `DEBUG=1` con borde de timing, asserts y guard bytes.
6. Eliminar el uso de `Esc` como progresión o aislarlo tras `DEBUG`.

Entrega: el prototipo existente, sin nuevas mecánicas, arranca de forma
reproducible en el Mac.

## 5. M1 — Memoria y cargador 128K

1. Mover `Z80CODELOC` a `0x0100` o primera dirección baja validada.
2. Reservar explícitamente `0x3C00–0x3FFF` para pila.
3. Separar gráficos de `graphics.c` en binarios de banco.
4. Implementar `bank_set()` y `bank_restore_game()` alrededor de
   `cpct_pageMemory`.
5. Crear prueba de sentinelas para RAM1 y RAM4–RAM7.
6. Implementar bootstrap DSK que, con firmware activo, cargue los bancos y luego
   entregue control al motor sin firmware.
7. Mantener DSK como única ruta obligatoria; documentar la futura carga CDT.

Puertas:

- Código, datos y pila no tocan `0x4000`.
- Cada banco mide ≤16.384 B.
- Cambiar de banco 100.000 veces no altera framebuffers ni sentinelas.
- Stack watermark deja al menos 384 B libres en la prueba de peor caso.

## 6. M2 — Motor estable

1. Sustituir scratch absoluto por variables residentes.
2. Usar coordenadas firmadas o saturadas antes de aplicar movimiento.
3. Validar `tileCell()` y todas las lecturas del mapa.
4. Sustituir la cuadrícula implícita de 9×8 por vecinos explícitos.
5. Separar definición inmutable de sprite y estado mutable de entidad.
6. Generalizar ancho, alto, stride, direcciones y frames.
7. Reemplazar rangos ordinales de tiles por `tile_flags[64]`.
8. Reparar dirty-tile redraw y guardar posición anterior por framebuffer.
9. Dibujar cada sala completa en ambos buffers solo durante la transición.

API mínima:

```text
entity_spawn(type, x, y, direction)
entity_update_all()
collision_move(entity, dx, dy)
room_enter(room_id, spawn_id)
room_apply_persistent_state()
render_begin_frame() / render_end_frame()
```

## 7. M3 — Movimiento, interacción y dificultad

1. Movimiento a velocidad constante y diagonal alternada.
2. Caja interior de Pitu separada del sprite.
3. Doce ticks seguros al entrar.
4. Puertas con spawn validado y cooldown de retorno.
5. Sistema de un único contexto activo con icono.
6. Cobertura y escondite con comprobación de línea de visión.
7. Salto contextual de ocho frames con tabla de posiciones.
8. Pausa y mapa de tres nodos.
9. Añadir `DifficultyId` y una tabla residente constante de cinco perfiles.
10. Mover a Alberto con máscaras de ocho bits (`4/8` a `8/8`), sin divisiones.
11. Parametrizar visión, aviso, cooldown, persistencia, Carga, cafés, ayuda de
    mapa y ventana del jefe; ninguna otra regla consulta la dificultad.
12. Añadir selector de inicio, cambio entre plantas, opción de bajar tras
    burnout y perfil dentro del password.
13. Redibujar el HUD al cambiar el límite de Carga sin reservar otro sprite.

Sala de laboratorio:

- Cuatro paredes y cuatro puertas.
- Dos muebles de cobertura.
- Un teléfono.
- Un hueco cian válido y otro destino bloqueado.
- Un pickup y un tile peligroso anunciado.

No se avanza hasta que cien recorridos grabados producen la misma posición y
estado final. La misma secuencia se repite en los cinco perfiles y solo difieren
los campos expresamente incluidos en la tabla.

## 8. M4 — Pipeline de contenido

### TMX

Cada mapa contiene capas o propiedades para:

- `tiles`: 20×23.
- `collision`: flags o derivación validada.
- `spawns`: Pitu, Alberto, pickup y efectos.
- `doors`: dirección, destino y spawn.
- `interactions`: tipo, estado persistente y objetivo.
- `nav`: waypoints y enlaces de Alberto.
- `patches`: listas usadas por luz, cristal, proyector y jefe.

### Build

1. Convertir TMX a binario de 8 bits.
2. Comprimir cada mapa con ZX7B y registrar offset/tamaño.
3. Generar `LevelDesc` y `RoomDesc` desde una fuente legible.
4. Empaquetar bancos con error duro al superar 16 KiB.
5. Generar manifiesto con hashes y tamaños.
6. Validar imágenes antes de `cpct_img2tileset`.

Entrega: borrar `generated/`, ejecutar una orden y obtener exactamente los mismos
bancos y cabeceras.

## 9. M5 — Vertical slice de niveles 1 y 2

Contenido obligatorio:

- Seis pantallas conectadas en dos triángulos.
- Concepto I y Copy I.
- Art y Carlitos estáticos.
- Alberto global y sus estados locales completos.
- Un briefing, Carga, tres cafés y burnout.
- Cobertura, teléfono, escondite y salida de nivel.
- HUD, pausa, código de nivel y puntuación provisional.
- Música provisional y SFX de pieza, alerta, lanzamiento e impacto.

Prueba de salida con cinco personas que no conozcan el código:

- Cuatro de cinco entienden el objetivo sin explicación externa.
- Todas identifican el aviso antes del primer lanzamiento.
- Mediana del nivel 1 inferior a cinco minutos.
- Nadie atribuye un impacto a azar o teletransporte.
- Al menos tres usan voluntariamente el teléfono para desviar a Alberto.
- Los cinco perfiles se recorren en la sala de laboratorio; Muy fácil permite
  aprender y Muy difícil sigue siendo vencible sin recibir un impacto inevitable.
- Codex juega los niveles 1–2 directamente en Caprice32, sin reproducción
  automática, y deja grabación de inputs, notas y defectos reproducibles.

Si falla, se corrige el bucle antes de producir niveles 3–10.

## 10. M6 — Niveles 3 y 4

- Crear Túnel Pantone, Mesa de luz y Cuarto oscuro.
- Validar cinta cian con forma además de color.
- Añadir Repro, Fotocopiadora y Atrezo.
- Implementar máquina con ciclo visible: reposo, aviso, ruido y cooldown.
- Completar Arte I y Maqueta I.
- Montar la primera fila de storyboard.
- Generar, mostrar y aceptar el primer password/checkpoint.

Puerta: empezar desde el código del nivel 4, terminarlo, sufrir burnout y
conservar las cuatro piezas correctas.

## 11. M7 — Niveles 5 a 7

- Parches de cristal con dos configuraciones seguras.
- Ráfagas de terraza que desplazan papeles, no a Pitu.
- Atajo de archivo de sentido único.
- Luz/penumbra que modifica visión, no paleta de Pitu.
- Cameo del Presidente en nivel 5.
- Segundo checkpoint tras Maqueta II.

Cada nuevo sistema se implementa como datos y pequeños estados. Si exige una
nueva IA, se rediseña la sala.

## 12. M8 — Niveles 8 y 9

- Fax remoto y destino de ruido fuera de pantalla.
- Puerta privada de Alberto con demostración previa.
- Paneles de proyector y vista previa de patches.
- Persistencia de Alberto hasta tres habitaciones.
- Concepto III, Arte III, Copy III y Maqueta III.
- Campaña completa y desbloqueo del nivel 10.

Puerta: las nueve primeras plantas son completables desde nueva partida y desde
cada código, con las mismas máscaras de progreso previstas.

## 13. M9 — Jefe final

1. Construir Presidente como fondo y overlays mínimos.
2. Implementar controlador de boss separado de la IA de Alberto.
3. Fase 1: cuatro paneles y entrada anunciada de Alberto.
4. Fase 2: dos configuraciones de mesa mediante patches durante corte.
5. Fase 3: fax, alineación del briefing y bandeja destructible.
6. Guardar fase alcanzada al consumir café.
7. Añadir tres sellos, stingers y final de tres viñetas.
8. Aplicar exclusivamente la ventana de jefe y los parámetros compartidos del
   perfil; no crear cinco scripts ni cinco arenas.

No se acepta una fase que dependa de un comportamiento emergente no
determinista. Las posiciones de fax, bandeja y línea de tiro se validan por
datos. Cada fase debe completarse mediante replay en los cinco perfiles.

## 14. M10 — Arte y audio final

### Arte

- Validar cada frame de Pitu por máscara y píxel canónico.
- Rediseñar el sprite CPC de Alberto desde la hoja completa.
- Convertir NPC a tiles con detalles animados.
- Construir 64 tiles comunes y parches por nivel.
- Redibujar portada a 160×200; no reducir automáticamente el máster.
- Crear storyboard, game over, passwords y final.

### Audio

- Componer temas originales en Arkos Tracker 3.
- Exportar a la dirección bancaria elegida.
- Integrar música y SFX compartiendo instrumentos.
- Prioridad: alerta > impacto > pickup > puertas > decoración.
- Medir el tick de audio con y sin efecto.

## 15. M11 — Alpha, balance y optimización

1. Congelar sistemas; solo contenido, números y bugs.
2. Ejecutar la matriz completa de `TEST_PLAN.md`.
3. Medir cada nivel, peor sala y cada fase del jefe.
4. Reducir overdraw, número de dirty tiles y llamadas C costosas.
5. Pasar a ASM únicamente los hotspots medidos.
6. Ajustar aviso, cooldown, persistencia y rutas de Alberto por telemetría de
   replays, no por intuición.
7. Revisar texto, contraste, formas y canon.
8. Hacer pruebas de campaña completa y passwords.
9. Codex juega en Caprice32 una campaña completa por cada dificultad, con input
   decidido durante la partida y sin replay, warp, invulnerabilidad ni selector
   debug. Las cinco deben ir de portada a final sobre el mismo candidato.
10. Corregir cualquier fallo encontrado y repetir las campañas afectadas; si
    cambia motor o estado global, repetir las cinco.
11. Solo después de esas cinco campañas, ejecutar las sesiones con el usuario:
    yo preparo build y caso, el usuario toma los controles y yo registro los
    resultados entre intentos.
12. Cerrar la matriz de 10 niveles por 5 dificultades antes de declarar RC.

Objetivo de balance:

- Nivel 1: 0–1 burnout en primer intento.
- Niveles 2–4: mediana ≤2.
- Niveles 5–7: mediana ≤3.
- Niveles 8–9: mediana ≤4.
- Jefe: la mayoría alcanza fase 2 en primer intento y vence en ≤4 intentos.

Los objetivos anteriores describen Normal. Además:

- Muy fácil: una persona nueva aprende en el nivel 1 sin game over y dispone de
  tiempo para leer cada aviso.
- Fácil: tolera errores, pero ruido, cobertura y rutas siguen siendo útiles.
- Difícil: exige planificar y usar interacciones, sin ataques inevitables.
- Muy difícil: una persona experta puede completar cada nivel y el jefe sin
  daño obligatorio; Alberto nunca es más rápido que Pitu.
- Cambiar de perfil modifica solo los valores documentados y no los mapas,
  objetivos, final ni rendimiento máximo.

## 16. M12 — Release

- Build limpio y reproducible desde README.
- DSK con nombre AMSDOS probado y autoarranque documentado.
- CDT experimental solo si supera la misma campaña de smoke.
- Manual: historia, controles, carga, mapa, créditos y permisos.
- Archivo de símbolos, mapa de memoria y hashes conservados junto a la versión.
- Prueba en Caprice32 y segunda implementación; preferible CPC 6128 real.
- Adjuntar informe de cobertura, hashes de los replays y actas de las sesiones
  locales; no basta una afirmación manual de que «se ha probado».
- Etiqueta de versión, changelog y paquete de fuentes conforme a licencias.

## 17. Riesgos y respuestas

| Riesgo | Indicador temprano | Respuesta |
|---|---|---|
| Residente >16 KiB | `_CODE/_DATA` cruzan `0x3C00`. | Sacar datos, reducir funciones CPCtelera o crear overlay de menú. |
| Banco de mundo >14 KiB | Mapa medio comprimido >350 B. | Simplificar tiles o dividir mapas entre RAM4 y RAM7. |
| Audio rompe render | Picos o sprites corruptos al paginar. | Audio en bucle principal, sección crítica y restauración asertada. |
| Alberto parece injusto | Tester no explica por qué fue detectado. | Aumentar aviso, sonido direccional y persistencia visible. |
| Salto se siente arbitrario | Se intenta fuera de cintas. | Mejor affordance o eliminarlo de esa sala. |
| Contenido se vuelve repetitivo | Salas se resuelven igual. | Una combinación nueva por planta, no más entidades. |
| Personajes pierden identidad | Sprite no pasa overlay de modelo. | Bloquear integración hasta aprobación canónica. |
| Derechos incompletos | No hay autorización antes de RC. | No distribuir públicamente personajes literales hasta resolverlo. |

## 18. Regla de control de alcance

La versión 1.0 son diez niveles y treinta pantallas. La arquitectura puede
admitir más, pero no se inicia un nivel 11, modo alternativo, compatibilidad 464,
scroll, segundo jugador ni físicas completas hasta publicar un release candidate
que cumpla todos los criterios de prueba.
