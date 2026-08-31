# Pitu canon — regla de producción

Pitu no es una referencia flexible. Su dibujo original es el modelo canónico y
ningún asset, portada, animación o material promocional puede rediseñarla.

## Jerarquía de fuentes

1. Autoridad absoluta: `assets/originals/pitu_orig.jpeg`.
2. Traducción pixel-art: `assets/originals/pitu_export.png`.
3. Adaptación de color CPC: `assets/originals/pitu_AMS.png`.
4. Copia de producción: `assets/img/pitu.png`.

`pitu_export.png` y `pitu_AMS.png` comparten exactamente máscara, silueta y
píxeles negros; cambia la cuantización de color. `assets/img/pitu.png` es la
copia visual de producción de esa adaptación.

## Invariantes

- Enorme melena negra, compacta y dominante hasta aproximadamente la cintura.
- Pasador rectangular azul o cian dentro de la melena.
- Gafas negras grandes y rectangulares con una lente o brillo blanco visible.
- Cara de perfil, nariz muy pronunciada y boca rosa o magenta.
- Piel melocotón con sombra naranja o marrón.
- Camiseta verde lima con un segundo verde para el detalle.
- Pantalón recto azul muy oscuro o gris carbón.
- Zapatos blancos con pequeño detalle rosa.
- Cuerpo estrecho y simple; cabeza y pelo pesan mucho más que el torso.
- Construcción mediante grandes bloques rectangulares de píxel.
- Actitud tranquila, irónica y segura; no es una superheroína de acción.

## Cambios permitidos

- Espejo horizontal para las dos direcciones.
- Movimiento mínimo de brazos y piernas para andar.
- Pequeño desplazamiento de las puntas del pelo.
- Frame de impacto o escondite que conserve perfil, pelo, gafas y ropa.
- Mapeo de sus colores a las tintas físicas elegidas del CPC.
- Corrección manual del pixel aspect ratio sin suavizado.

## Cambios prohibidos

- Pelo rojo, naranja o rubio.
- Coleta, pelo corto o una melena de otra silueta.
- Eliminar las gafas o el pasador azul.
- Añadir pecas, grandes aros o rasgos no presentes.
- Top azul, ropa de moda nueva o pantalón multicolor.
- Rostro frontal o anatomía suave y realista.
- Convertirla en una caricatura inspirada vagamente en el original.
- Antialiasing, interpolación bilineal o bordes redondeados.

## Validación

Cada frame nuevo debe revisarse así:

1. Superponerlo con el original o con `pitu_export.png`.
2. Confirmar masa y contorno del pelo.
3. Confirmar gafas, brillo blanco, pasador y perfil.
4. Confirmar camiseta, pantalón y zapatos.
5. Comprobar el frame a tamaño 1× en Modo 0.
6. Comprobar su lectura sobre fondos claros y oscuros.
7. Obtener aprobación visual antes de incorporarlo a `graphics.c`.

## Estado de los assets actuales

| Asset | Estado |
|---|---|
| `assets/originals/pitu_orig.jpeg` | Canon absoluto. |
| `assets/originals/pitu_export.png` | Canon pixel-art. |
| `assets/originals/pitu_AMS.png` | Adaptación CPC compatible. |
| `assets/img/pitu.png` | Copia de producción compatible. |
| Frames `g_pitu*` de `src/graphics.c` | Compatibles en identidad; validar cada animación. |
| `banterhouse-cover-master-v1.png` | Rechazado: representa otra protagonista. |
| `banterhouse-cover-master-v2.png` | Estudio de composición; no es fuente de Pitu. |
| `banterhouse-cover-master-v3-pitu-lock.png` | Rechazado: su crop cortaba píxeles canónicos. |
| `banterhouse-cover-master-v5-creatas-cast.png` | Estudio conforme de Pitu a escala entera `20×`. |
| `banterhouse-cover-master-v6-literal-cast.png` | Estudio conforme de Pitu a escala entera `24×`. |
| `banterhouse-cover-master-v7-alberto-lock.png` | Rechazado por interpretar como melena la dentadura de Alberto; Pitu sí permanece conforme a `24×`. |
| `banterhouse-cover-master-v8-alberto-model-lock.png` | Máster vigente: Pitu canónica exacta a `24×` y Alberto corregido desde la hoja completa. |

El mundo, los secundarios y la sátira pueden evolucionar. Pitu no.
