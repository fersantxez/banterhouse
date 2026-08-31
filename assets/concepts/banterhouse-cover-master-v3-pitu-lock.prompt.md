# BANTERHOUSE cover master v3 — Pitu Lock

Máster vigente. Conserva el fondo creado con el generador integrado para la v2
y sustituye su representación de Pitu por una inserción determinista del dibujo
canónico `assets/originals/pitu_orig.jpeg`.

## Prompt generativo

El prompt completo usado para generar el fondo y la composición está guardado
sin cambios en `banterhouse-cover-master-v2.prompt.md`.

## Operación final no generativa

1. Se detectó el rectángulo no blanco de `pitu_orig.jpeg`:
   `crop=508:1188:288:260`.
2. Se escaló con nearest-neighbour a `300×702`.
3. Se reservó un panel blanco con borde negro en `(370,190)`, de `340×740`.
4. Se insertó Pitu en `(390,209)` sin redibujarla ni interpolarla.

Esta operación prevalece sobre cualquier descripción generativa anterior de
Pitu. El panel hace explícito que el mundo adopta una estética, mientras el
dibujo original de Pitu permanece intacto.
