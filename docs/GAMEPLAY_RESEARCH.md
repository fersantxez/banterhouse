# Investigación de jugabilidad CPC aplicada a Banterhouse

Esta selección combina puntuaciones históricas, listas retrospectivas y juegos
cuyo diseño se parece al problema de Banterhouse. No se copian mapas,
personajes, gráficos, texto ni música: solo se trasladan abstracciones.

Como control de selección, [CPCWiki explica que su lista de mejores juegos usa
la media de reseñas de CPC Zone, CPC Game Reviews, Amstrad Action, Amstrad
Computer User, Amtix y Cent Pour Cent](https://www.cpcwiki.eu/index.php/Top_games).
La [tabla de puntuaciones de Amstrad Action](https://www.cpcwiki.eu/index.php/Amstrad_Action_ratings)
permite contrastar las notas originales.

## Síntesis

| Referente | Qué se adopta | Qué se rechaza |
|---|---|---|
| *Bruce Lee* | Pocas pantallas recontextualizadas por un perseguidor recurrente. | Enemigos que reaparecen mágicamente y combate cuerpo a cuerpo. |
| *Batman* / *Head Over Heels* | Grafo de salas, objetivos fragmentados, persistencia y cada sala como puzle. | Isometría, cientos de salas, checkpoints escasos y objetos esenciales opacos. |
| *Get Dexter* | Humor mediante objetos interactivos y curva que presenta una regla cada vez. | Inventario amplio y experimentación a ciegas. |
| *Bubble Bobble* | Pantalla fija legible y alternancia de tensión con recompensa exuberante. | Multitud de enemigos y temporizador global. |
| *Bomb Jack* | Orden de recogida sugerido para bonus, nunca obligatorio. | Memorización como requisito. |
| *La Abadía del Crimen* | Un personaje que sigue rutinas fuera de pantalla. | Horarios opacos y expulsión por incumplirlos. |
| *Rick Dangerous II* | Niveles con identidad, exploración, timing y reintento rápido. | Trampas invisibles y progreso mediante muerte. |
| *Prince of Persia* | Respuesta precisa y animación funcional al movimiento. | Físicas complejas y saltos de precisión para este alcance. |

## 1. Bruce Lee: perseguidor y escala

El diseño base trabaja con unas veinte cámaras y dos perseguidores recurrentes.
Una [revisión de la versión CPC destaca controles precisos y patrones
aprendibles](https://averypublicsociologist.blogspot.com/2020/01/bruce-lee-for-amstrad-cpc-464.html).

Aplicación:

- Treinta pantallas bastan si Alberto cambia la lectura de cada una.
- La geometría puede usarse para romper su línea de visión o desviar su ataque.
- Alberto mantiene habitación, destino y última posición conocida.

## 2. Batman y Head Over Heels: salas y persistencia

El [manual original de *Batman*](https://www.gamesdatabase.org/Media/SYSTEM/Amstrad_CPC/manual/Formated/Batman_-_1986_-_Ocean_Software_Ltd..pdf)
describe piezas del Batcraft, capacidades recuperables y Bat-signals que guardan
estado. *Head Over Heels* desarrolla la idea mediante personajes con habilidades
complementarias y salas que prueban combinaciones de pocas reglas.

La retrospectiva de GamesRadar destaca el diseño de niveles y carácter de
[*Head Over Heels*](https://www.gamesradar.com/best-amstrad-games/), y la misma
fuente elogia el equilibrio entre dificultad y disfrute de *Get Dexter*.

Aplicación:

- Doce piezas claramente agrupadas en cuatro disciplinas.
- Checkpoint cada cuatro piezas y código de planta.
- Una situación dominante por pantalla.
- Grafo separado de arte, colisiones y objetos.

No se adopta la cámara isométrica: orden de profundidad, colisiones ambiguas y
arte adicional no aportan nada esencial al bucle.

## 3. Bubble Bobble: tensión y placer

Su diseñador Fukio Mitsuji explicó que buscaba equilibrar tensión y placer, con
una acción central físicamente satisfactoria; la
[entrevista original está traducida en Shmuplations](https://shmuplations.com/bubblebobble/).

Aplicación:

- Alberto no ocupa todas las salas ni mantiene presión constante.
- Recoger creatividad usa destello, sonido AY, reacción de Pitu y HUD.
- Después de una persecución se programa un respiro o gag.
- El peor caso limita sprites y proyectiles aunque sobre RAM.

## 4. Bomb Jack: ruta experta opcional

En *Bomb Jack*, las bombas se pueden recoger en cualquier orden, pero seguir la
[secuencia iluminada concede un bonus](https://strategywiki.org/wiki/Bomb_Jack).

Aplicación:

- Cada planta ofrece tres chispas opcionales.
- Una indica la ruta eficiente y activa la siguiente.
- Romper el orden solo pierde puntuación; jamás bloquea la pieza o salida.

## 5. La Abadía del Crimen: mundo con rutina

El juego organiza personajes y obligaciones mediante un horario. La
[descripción histórica de Game Museum](https://gamemuseum.es/la-abadia-del-crimen/)
explica ese mundo reglado, concebido inicialmente alrededor del CPC 6128.

Aplicación:

- Alberto patrulla Cuentas, Recepción y reunión aunque Pitu no lo vea.
- Teléfono, fax, recogida o fotocopiadora sustituyen temporalmente su destino.
- El mapa y el sonido permiten predecirlo.

No hay horario que provoque game over. La rutina crea oportunidades, no tareas
que exijan una guía.

## 6. Rick Dangerous II: identidad y advertencia

*Rick Dangerous II* recibió 97 % en Amstrad Action y fue elegido juego de 1990
por revista y lectores; la propia revista destacó su mezcla de puzles,
exploración y timing en [Amstrad Action 68](https://acpc.me/ACME/LITTERATURE/REVUES/%5BENG%5D%5BAMSTRAD%5DAMSTRAD_ACTION/AMSTRAD_ACTION_068%5BOCR%5D.pdf).

Aplicación:

- Cada planta posee una mecánica identificable y una culminación.
- Entrada, aviso y recuperación forman parte de toda amenaza.
- El reintento desde sala o fase tarda segundos.

Regla absoluta: si la única forma de conocer un peligro es recibir el golpe, el
diseño falla. No habrá briefing al cruzar puerta, suelo letal oculto ni salto de
fe.

## 7. Prince of Persia y Get Dexter: control y curva

La lista retrospectiva de GamesRadar subraya que el Prince responde de forma
precisa a joystick y teclado, y califica la curva de *Get Dexter* como un
equilibrio entre dificultad y disfrute.

Aplicación:

- Velocidad y caja de colisión constantes.
- Doce ticks seguros al entrar en sala.
- El primer uso de cada regla ocurre sin castigo.
- El salto contextual valida destino antes de empezar.
- La dificultad combina reglas conocidas; no multiplica velocidad y entidades.

## 8. Reglas resultantes

1. El jugador ve al menos una ruta válida desde cada entrada.
2. La primera amenaza tarda un segundo en poder actuar.
3. El aprendizaje de una mecánica ocurre en tres pasos: demostración, práctica
   segura y combinación bajo presión.
4. Toda sala tiene salida de emergencia o cobertura alcanzable.
5. Solo una variable principal aumenta por planta.
6. Alberto no conoce información que el sistema no le haya comunicado.
7. Los objetos contextuales muestran su verbo antes de pulsar.
8. La recogida obligatoria es visible en mapa por zona.
9. Los checkpoints preservan experimentación y tiempo del jugador.
10. El jefe final examina reglas existentes; no estrena otra interfaz.

## 9. Referencias técnicas complementarias

- [Repositorio oficial de CPCtelera](https://github.com/lronaldo/cpctelera)
- [Paginación de memoria en CPCtelera](https://lronaldo.github.io/cpctelera/files/memutils/cpct_pageMemory-asm.html)
- [Arkos Player incluido con CPCtelera](https://lronaldo.github.io/cpctelera/files/audio/arkostracker-s.html)
- [EasyTilemaps de CPCtelera](https://lronaldo.github.io/cpctelera/files/easytilemaps/easytilemaps-h.html)

