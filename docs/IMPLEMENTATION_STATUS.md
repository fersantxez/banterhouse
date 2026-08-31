# Banterhouse — estado verificable de implementación

Fecha de corte: 31 de agosto de 2026

Este documento describe el alcance de software demostrado. Un `PASS` significa
que existe una ejecución reproducible; las pruebas físicas y humanas se listan
por separado.

## Resultado automatizado actual

| Área | Estado | Evidencia / criterio |
|---|---|---|
| Build release | PASS | Build limpio serial y paralelo idénticos byte a byte |
| Campaña visual | PASS | 30 pantallas, 30 landmarks únicos y 330 elementos de fondo |
| Rendimiento visual | PASS | 4.350 frames en 173 s: 25,1 Hz al 100% de velocidad CPC |
| Galería real | PASS | 30 marcadores y 30 capturas, incluidas tres fases del boss |
| Estado/input/render | PASS | Estado explícito, renderer de sólo lectura y unitarias host |
| Recursos | PASS | `BHRES.BIN` v1, IDs generados, dependencias y CRC16 |
| Disco/FDC | PASS | Lectura multitrack, retry acotado, CRC corrupto y sector ausente |
| Bancos 128K | PASS | RAM4–RAM7, nesting/guards y 10.000 cambios |
| Room packs | PASS | Seis packs externos de laboratorio, bounds y ruta segura por BFS |
| Resource manager | PASS | 400 load/unload, generaciones y fallo transaccional |
| Campaña jugable | PASS | Diez niveles completos en cada una de las cinco dificultades |
| Audio | PASS | 75,42 s, loop, ocho SFX y señal válida |
| Soak FDC | PASS | 50 ciclos, 100 cargas completas de 16 KiB |

Identidad técnica actual:

- Build de recursos: `0x173B6D8B`.
- Contenedor: 35.839 bytes, ocho recursos.
- High-water release: `0x6FCD`.
- Margen a pila/framebuffer: 4.146 bytes.
- Datos visuales: 30 salas y 330 rectángulos compactos.

## Comandos de aceptación

```sh
make release
make check
make qa
make fdc-soak
```

`make qa` ejecuta reproducibilidad, checks estáticos y host, bancos, slice
Expanded, FDC normal y fallos, audio y la matriz de campaña. `make fdc-soak`
añade las 100 cargas. Los helpers restauran el release normal incluso después
de una variante de laboratorio.

## Estado del plan ambicioso

| Fase | Estado real |
|---|---|
| A0 — baseline/laboratorio | Completada |
| A1 — seams/recursos | Completada para el release y el laboratorio 128K |
| A2 — sistema visual | Completada: esquema, generador, compositor y fault tests |
| A3 — fábrica de contenido | Completada para las 30 composiciones residentes |
| A4 — campaña visual | Completada: 27 salas y 3 fases visuales del pitch final |
| A5 — jefe/audio | Completada en las cinco dificultades |
| A6 — RC software | QA automatizada y soak completos |

## Gates externos

La implementación y la aceptación automatizada del release están completas.
No se declara evidencia que no existe: todavía corresponden a una futura ronda
de producto las sesiones de primera experiencia con jugadores nuevos y una
matriz de CPC 6128 físicos/CRTC. Ninguno de esos gates cambia el contenido del
binario entregado, pero sí sería necesario antes de afirmar compatibilidad
universal de hardware.

La infraestructura Expanded de paginación/FDC permanece como laboratorio y no
se presenta en la web pública como una segunda edición ni como trabajo pendiente.
