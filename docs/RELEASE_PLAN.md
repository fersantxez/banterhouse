# Banterhouse — plan de lanzamiento

## Concepto de campaña

**Titular:** *La Gran Idea no se entrega. Se sobrevive.*

**Promesa:** una pieza perdida de la edad de oro del software español reaparece
con juego real para Amstrad CPC 6128, ediciones físicas de cassette y disco de
3 pulgadas, anuncio de revista y una recreativa doméstica dentro del navegador.

**Conflicto:** Madrid, 03:17. Pitu debe reconstruir una campaña hecha pedazos
antes de que Alberto Pérez del Briefing Ramírez de Quiñones la alcance con otro
cambio «mínimo».

**Marca:** Banterhouse es la traducción inglesa deliberadamente aparatosa de
*Casa de la Guasa*. La agencia se trata como un lugar real y peligroso, mientras
el contenido sigue siendo una sátira cariñosa del trabajo publicitario.

## Tono heredado de la publicidad de 8 bits

- Titular imperativo o amenazante en mayúsculas.
- Segunda persona: «Tú eres Pitu», «Tu misión».
- Situación absurda narrada con solemnidad cinematográfica.
- Prestaciones convertidas en espectáculo: `30 PANTALLAS`, `128K`, `MÚSICA AY`.
- Sellos, estallidos, precio en pesetas y referencia de catálogo.
- Capturas reales enmarcadas y siempre acompañadas por un beneficio.
- Remate de distribuidora ficticia: `CASA DE LA GUASA SOFTWARE`.
- Nada de vaporwave, rejillas de neón ni nostalgia genérica de sintetizadores.

La campaña toma el **formato y la cadencia**, no frases ni composiciones
literales, de anuncios de Dinamic, Topo Soft, Opera Soft y Ocean. Referencias:

- [Archivo de publicidad de Dinamic en CPC Rulez](https://cpcrulez.fr/info-dinamic.htm)
- [Topo Soft: el reto de ser distintos](https://cpcrulez.fr/games-company-topo_soft-el_reto_de_ser_distintos_ASO.htm)
- [Anuncios de software en MicroHobby 189](https://archive.org/download/microhobby-magazine-189.pdf/MicroHobby_189.pdf)
- [Anuncio de NARC de Ocean](https://worldofspectrum.net/item/0003360/)
- [Archivo original de Creatas y Ejecutas](https://www.flickr.com/photos/danielsolana/albums/72157604028721493/)

## Piezas

| Pieza | Uso | Salida |
|---|---|---|
| Portada | Carátula y prensa | `site/public/release/banterhouse-cover.png` |
| Cassette hero | Cabecera de landing y prensa | `site/public/release/banterhouse-cassette-hero.png` |
| Carátula desplegada | Impresión A4 horizontal | `site/public/release/banterhouse-cassette-inlay.png` |
| Estuche de disco 3″ | Impresión A4 horizontal | `site/public/release/banterhouse-disk-inlay.png` |
| Anuncio | Revista A4 vertical | `site/public/release/banterhouse-ad-a4.png` |
| Juego en cassette | Descarga directa, 875 PTAS. | `site/public/release/banterhouse.cdt` |
| Juego en disco 3″ | Descarga directa, 1.900 PTAS. | `site/public/release/banterhouse.dsk` |
| Paquete | Juego, CDT, arte y prensa | `site/public/release/banterhouse-release.zip` |
| Social card | Open Graph y X | `site/public/og.png` |
| Emulador | Juego en navegador | `site/public/emulator/` |

## Arquitectura de landing

1. Exclusiva mundial y descarga inmediata.
2. Argumento como anuncio de videojuego.
3. Expedientes de Pitu y Alberto.
4. Banterhouse / Casa de la Guasa.
5. Formatos: cassette a 875 PTAS., disco de 3″ a 1.900 PTAS. y paquete completo.
6. Emulador CPC 6128 con el disco montado y autoarranque.

## Emulación

La web distribuye una copia autocontenida de [1984](https://github.com/salvogendut/1984),
emulador GPL-2.0 de CPC 6128 compilado a WebAssembly. Monta el DSK mediante
parámetros relativos y lanza `LOADER.BAS`. El emulador, el juego y las visitas
permanecen en el navegador; no hay carga de partidas a un servidor.
