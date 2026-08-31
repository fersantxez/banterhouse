#!/usr/bin/env python3
"""Build the printable Banterhouse user manual.

The manual is intentionally original.  It borrows the compact, high-energy
editorial vocabulary of Spanish 8-bit software manuals without reproducing a
specific publisher's trade dress.
"""

from __future__ import annotations

import math
from io import BytesIO
from pathlib import Path

from PIL import Image
from reportlab.lib.colors import Color, HexColor, white
from reportlab.lib.pagesizes import A5
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfgen import canvas
from reportlab.lib.utils import ImageReader


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "output" / "pdf" / "banterhouse-manual.pdf"
W, H = A5

INK = HexColor("#12110F")
PAPER = HexColor("#F2E5C8")
CREAM = HexColor("#FFF7E7")
MAGENTA = HexColor("#F41468")
CYAN = HexColor("#00D8D8")
ACID = HexColor("#F4E81D")
GRAY = HexColor("#8D8A82")
DEEP = HexColor("#221218")

FONT_DIR = Path("/System/Library/Fonts/Supplemental")
FONTS = {
    "Sans": FONT_DIR / "Arial.ttf",
    "Sans-Bold": FONT_DIR / "Arial Bold.ttf",
    "Sans-Black": FONT_DIR / "Arial Black.ttf",
    "Sans-Italic": FONT_DIR / "Arial Italic.ttf",
    "Mono": FONT_DIR / "Courier New.ttf",
    "Mono-Bold": FONT_DIR / "Courier New Bold.ttf",
    "Narrow": FONT_DIR / "Arial Narrow.ttf",
    "Narrow-Bold": FONT_DIR / "Arial Narrow Bold.ttf",
}

for name, path in FONTS.items():
    pdfmetrics.registerFont(TTFont(name, str(path)))


def wrap(text: str, font: str, size: float, width: float) -> list[str]:
    lines: list[str] = []
    for paragraph in text.split("\n"):
        if not paragraph:
            lines.append("")
            continue
        words = paragraph.split()
        current = ""
        for word in words:
            trial = word if not current else f"{current} {word}"
            if pdfmetrics.stringWidth(trial, font, size) <= width:
                current = trial
            else:
                if current:
                    lines.append(current)
                current = word
        if current:
            lines.append(current)
    return lines


def text_block(c: canvas.Canvas, text: str, x: float, y: float, width: float,
               font: str = "Sans", size: float = 9.2, leading: float = 12.2,
               color=INK, max_lines: int | None = None) -> float:
    c.setFont(font, size)
    c.setFillColor(color)
    lines = wrap(text, font, size, width)
    if max_lines is not None:
        lines = lines[:max_lines]
    for line in lines:
        c.drawString(x, y, line)
        y -= leading
    return y


def label(c: canvas.Canvas, text: str, x: float, y: float, color=MAGENTA,
          text_color=white, angle: float = -1.5) -> None:
    c.saveState()
    c.translate(x, y)
    c.rotate(angle)
    width = pdfmetrics.stringWidth(text, "Sans-Black", 7.2) + 16
    c.setFillColor(color)
    c.rect(0, -5, width, 17, fill=1, stroke=0)
    c.setFillColor(text_color)
    c.setFont("Sans-Black", 7.2)
    c.drawString(8, 0, text)
    c.restoreState()


def title(c: canvas.Canvas, kicker: str, heading: str, page: int,
          accent=MAGENTA) -> float:
    c.setFillColor(PAPER)
    c.rect(0, 0, W, H, fill=1, stroke=0)
    c.setFillColor(INK)
    c.rect(0, H - 13, W, 13, fill=1, stroke=0)
    c.setFillColor(accent)
    c.rect(0, H - 18, W, 5, fill=1, stroke=0)
    label(c, kicker.upper(), 26, H - 45, accent)
    c.setFillColor(INK)
    c.setFont("Sans-Black", 28)
    y = H - 78
    for line in wrap(heading.upper(), "Sans-Black", 28, W - 52):
        c.drawString(26, y, line)
        y -= 27
    return y - 8


def footer(c: canvas.Canvas, page: int) -> None:
    c.setFillColor(INK)
    c.setFont("Mono-Bold", 7)
    c.drawString(26, 17, f"BANTERHOUSE / MANUAL CPC 6128 / {page:02d}")


def panel(c: canvas.Canvas, x: float, y: float, w: float, h: float,
          fill=CREAM, shadow=INK, stroke=INK, sw: float = 2) -> None:
    c.setFillColor(shadow)
    c.rect(x + 5, y - 5, w, h, fill=1, stroke=0)
    c.setFillColor(fill)
    c.setStrokeColor(stroke)
    c.setLineWidth(sw)
    c.rect(x, y, w, h, fill=1, stroke=1)


def crop_image(path: Path, target_ratio: float) -> ImageReader:
    img = Image.open(path).convert("RGB")
    ratio = img.width / img.height
    if ratio > target_ratio:
        nw = int(img.height * target_ratio)
        left = (img.width - nw) // 2
        img = img.crop((left, 0, left + nw, img.height))
    else:
        nh = int(img.width / target_ratio)
        top = (img.height - nh) // 2
        img = img.crop((0, top, img.width, top + nh))
    if path.stat().st_size > 500_000:
        img.thumbnail((1200, 1800), Image.Resampling.LANCZOS)
        encoded = BytesIO()
        img.save(encoded, format="JPEG", quality=88, optimize=True, progressive=True)
        encoded.seek(0)
        return ImageReader(encoded)
    return ImageReader(img)


def image_frame(c: canvas.Canvas, path: Path, x: float, y: float, w: float,
                h: float, caption: str | None = None, accent=MAGENTA) -> None:
    c.setFillColor(accent)
    c.rect(x + 6, y - 6, w, h, fill=1, stroke=0)
    c.setFillColor(INK)
    c.rect(x - 2, y - 2, w + 4, h + 4, fill=1, stroke=0)
    c.drawImage(crop_image(path, w / h), x, y, w, h, mask="auto")
    if caption:
        c.setFillColor(INK)
        c.rect(x, y - 15, w, 15, fill=1, stroke=0)
        c.setFillColor(white)
        c.setFont("Mono-Bold", 6.3)
        c.drawString(x + 5, y - 10, caption.upper())


def dots(c: canvas.Canvas, x: float, y: float, w: float, h: float,
         color=Color(0, 0, 0, alpha=.15), step: float = 8) -> None:
    c.setFillColor(color)
    yy = y
    row = 0
    while yy <= y + h:
        xx = x + (step / 2 if row % 2 else 0)
        while xx <= x + w:
            c.circle(xx, yy, 1.1, fill=1, stroke=0)
            xx += step
        yy += step
        row += 1


def burst(c: canvas.Canvas, cx: float, cy: float, r1: float, r2: float,
          points: int, fill=ACID, text: str | None = None) -> None:
    p = c.beginPath()
    for i in range(points * 2):
        a = math.pi / 2 + i * math.pi / points
        r = r1 if i % 2 == 0 else r2
        x = cx + math.cos(a) * r
        y = cy + math.sin(a) * r
        if i == 0:
            p.moveTo(x, y)
        else:
            p.lineTo(x, y)
    p.close()
    c.setFillColor(fill)
    c.setStrokeColor(INK)
    c.setLineWidth(2)
    c.drawPath(p, fill=1, stroke=1)
    if text:
        c.setFillColor(INK)
        c.setFont("Sans-Black", 9)
        c.drawCentredString(cx, cy - 3, text)


def bullet_list(c: canvas.Canvas, items: list[str], x: float, y: float,
                width: float, size: float = 8.6, leading: float = 11.4,
                bullet_color=MAGENTA) -> float:
    for item in items:
        lines = wrap(item, "Sans", size, width - 15)
        c.setFillColor(bullet_color)
        c.rect(x, y - 4, 7, 7, fill=1, stroke=0)
        c.setFillColor(INK)
        c.setFont("Sans", size)
        for idx, line in enumerate(lines):
            c.drawString(x + 14, y - idx * leading, line)
        y -= max(1, len(lines)) * leading + 5
    return y


def page_cover(c: canvas.Canvas) -> None:
    c.setFillColor(DEEP)
    c.rect(0, 0, W, H, fill=1, stroke=0)
    dots(c, 0, 0, W, H, Color(1, 1, 1, alpha=.08), 10)
    c.setFillColor(CYAN)
    c.rect(0, H - 28, W, 11, fill=1, stroke=0)
    c.setFillColor(MAGENTA)
    c.rect(0, 17, W, 12, fill=1, stroke=0)
    label(c, "EDICION CPC 6128 / 128K", 29, H - 58, MAGENTA)
    c.setFillColor(white)
    c.setFont("Sans-Black", 52)
    c.drawString(26, H - 121, "BANTER-")
    c.drawString(26, H - 169, "HOUSE")
    c.setFillColor(ACID)
    c.setFont("Narrow-Bold", 22)
    c.drawString(29, H - 202, "MANUAL DE INSTRUCCIONES")
    cover = ROOT / "release" / "banterhouse-release" / "art" / "banterhouse-cover.png"
    image_frame(c, cover, 33, 96, W - 66, 244, "LA GRAN IDEA NO SE ENTREGA. SE SOBREVIVE.", CYAN)
    burst(c, W - 70, 92, 45, 33, 13, ACID, "10 PLANTAS")
    c.setFillColor(white)
    c.setFont("Mono-Bold", 7.5)
    c.drawString(29, 50, "CASA DE LA GUASA SOFTWARE / REF. BH-MAN")


def page_welcome(c: canvas.Canvas) -> None:
    y = title(c, "Antes de fichar", "Bienvenida a la agencia", 2, CYAN)
    image_frame(c, ROOT / "site/public/release/screenshots/loading.png", 26, y - 152, W - 52, 132,
                "Madrid / 03:17 horas", MAGENTA)
    y -= 184
    panel(c, 26, y - 125, W - 52, 125, CREAM, MAGENTA)
    c.setFillColor(INK)
    c.setFont("Sans-Black", 13)
    c.drawString(40, y - 24, "EL BRIEFING")
    text = ("El cliente ha pedido lo mismo, pero distinto. La Gran Idea ha "
            "estallado en doce piezas y ha quedado repartida por las diez "
            "plantas de Banterhouse, la Casa de la Guasa. Solo Pitu puede "
            "recomponerla antes del pitch final.")
    text_block(c, text, 40, y - 44, W - 82, "Sans", 9.2, 12.5)
    y -= 149
    c.setFont("Sans-Black", 12)
    c.setFillColor(MAGENTA)
    c.drawString(26, y, "ESTO ES BANTERHOUSE")
    bullet_list(c, [
        "Exploración y persecución en treinta pantallas fijas.",
        "Acción y puzles de entorno: Pitu no combate.",
        "Partidas de 45 a 70 minutos; progreso mediante códigos.",
        "Cinco dificultades con las mismas salas y el mismo final.",
    ], 28, y - 24, W - 54, 8.7, 11.3, CYAN)


def page_mission(c: canvas.Canvas) -> None:
    y = title(c, "Objetivo", "Reconstruye la Gran Idea", 3, MAGENTA)
    c.setFillColor(INK)
    c.setFont("Sans", 9.5)
    y = text_block(c, "Recoge las doce piezas de creatividad. Cada cuatro piezas completan una fila del storyboard y aseguran tu progreso.", 26, y, W - 52, "Sans-Bold", 9.2, 12.3)
    disciplines = [
        ("CONCEPTO", "3 bombillas y bocetos", ACID, "01"),
        ("COPY", "3 tiras de texto", CYAN, "02"),
        ("ARTE", "3 muestras de color", MAGENTA, "03"),
        ("MAQUETA", "3 registros de corte", HexColor("#E86830"), "04"),
    ]
    y -= 10
    for name, desc, color, num in disciplines:
        panel(c, 26, y - 72, W - 52, 64, CREAM, color)
        c.setFillColor(color)
        c.rect(26, y - 72, 58, 64, fill=1, stroke=0)
        c.setFillColor(INK)
        c.setFont("Sans-Black", 22)
        c.drawCentredString(55, y - 51, num)
        c.setFont("Sans-Black", 14)
        c.drawString(98, y - 34, name)
        c.setFont("Mono-Bold", 8)
        c.drawString(98, y - 51, desc.upper())
        y -= 78
    burst(c, W - 68, 74, 43, 31, 12, ACID, "12 PIEZAS")
    text_block(c, "Consejo: las piezas se recogen al tocarlas. No necesitas pulsar Acción.", 26, 68, W - 145, "Sans-Bold", 8.5, 11, INK)


def draw_key(c: canvas.Canvas, x: float, y: float, text: str, w: float = 34) -> None:
    c.setFillColor(INK)
    c.roundRect(x + 3, y - 3, w, 28, 3, fill=1, stroke=0)
    c.setFillColor(CREAM)
    c.setStrokeColor(INK)
    c.setLineWidth(2)
    c.roundRect(x, y, w, 28, 3, fill=1, stroke=1)
    c.setFillColor(INK)
    c.setFont("Mono-Bold", 9)
    c.drawCentredString(x + w / 2, y + 9, text)


def page_controls(c: canvas.Canvas) -> None:
    y = title(c, "Puesto de mando", "Controles", 4, ACID)
    panel(c, 25, y - 138, W - 50, 128, CREAM, INK)
    c.setFont("Sans-Black", 12)
    c.setFillColor(INK)
    c.drawString(39, y - 31, "TECLADO")
    draw_key(c, 61, y - 83, "Q")
    draw_key(c, 61, y - 119, "A")
    draw_key(c, 20, y - 119, "O")
    draw_key(c, 102, y - 119, "P")
    text_block(c, "FLECHAS O QAOP\nMover y cruzar puertas", 158, y - 57, W - 202, "Sans-Bold", 9.1, 14)
    y -= 157
    rows = [
        ("S / ESPACIO / FUEGO", "Usar máquina, esconderse, abrir atajo."),
        ("FUEGO + DIRECCION", "Saltar por una ruta cian válida."),
        ("ESC", "Pausa, mapa y piezas pendientes."),
        ("CONTACTO", "Recoger una pieza de creatividad."),
    ]
    for key, desc in rows:
        c.setFillColor(MAGENTA)
        c.rect(26, y - 36, 130, 34, fill=1, stroke=0)
        c.setFillColor(white)
        c.setFont("Mono-Bold", 7.4)
        c.drawCentredString(91, y - 23, key)
        text_block(c, desc, 169, y - 13, W - 195, "Sans", 8.4, 10.5)
        y -= 45
    y -= 5
    panel(c, 26, y - 74, W - 52, 68, ACID, INK)
    c.setFont("Sans-Black", 11)
    c.setFillColor(INK)
    c.drawString(40, y - 29, "EN EL NAVEGADOR")
    text_block(c, "En móvil usa el mando táctil. Toca el monitor una vez para activar teclado y sonido.", 40, y - 46, W - 80, "Sans-Bold", 8.3, 10.5)


def page_play(c: canvas.Canvas) -> None:
    y = title(c, "Método creativo", "Como se juega", 5, CYAN)
    image_frame(c, ROOT / "site/public/release/screenshots/gameplay.png", 26, y - 142, W - 52, 126,
                "Lee la sala antes de moverte", MAGENTA)
    y -= 176
    steps = [
        ("1", "OBSERVA", "Localiza puertas, pieza, cobertura, rutas cian y el icono de acción."),
        ("2", "PREPARA", "Activa teléfonos, fax o fotocopiadora para atraer a Alberto lejos de tu ruta."),
        ("3", "EJECUTA", "Recoge el objetivo, rompe la línea de visión y vuelve a la salida señalada."),
        ("4", "CIERRA", "Al final de planta recibirás puntuación y un código para continuar."),
    ]
    for number, head, body in steps:
        c.setFillColor(INK)
        c.circle(49, y - 18, 19, fill=1, stroke=0)
        c.setFillColor(ACID)
        c.setFont("Sans-Black", 15)
        c.drawCentredString(49, y - 23, number)
        c.setFillColor(INK)
        c.setFont("Sans-Black", 10)
        c.drawString(78, y - 10, head)
        text_block(c, body, 78, y - 26, W - 104, "Sans", 8.1, 10.2)
        y -= 64
    label(c, "UNA SALA = UNA MICRO-SITUACION", 92, 43, MAGENTA, white, 1)


def page_danger(c: canvas.Canvas) -> None:
    y = title(c, "Cuentas", "Alberto y el briefing", 6, MAGENTA)
    image_frame(c, ROOT / "site/public/release/screenshots/night.png", 26, y - 139, W - 52, 123,
                "El peligro siempre se anuncia", CYAN)
    y -= 171
    panel(c, 26, y - 112, W - 52, 104, CREAM, MAGENTA)
    c.setFont("Sans-Black", 12)
    c.setFillColor(INK)
    c.drawString(40, y - 30, "NO LE GANAS: LE DESPISTAS")
    bullet_list(c, [
        "Los muebles y tabiques rompen su línea de tiro.",
        "Un ruido cambia su destino entre las tres salas.",
        "Puedes esconderte si ya no te está mirando.",
        "Nunca dispara sin aviso y solo lanza un briefing a la vez.",
    ], 40, y - 50, W - 80, 8.1, 10.2, CYAN)
    y -= 140
    c.setFillColor(INK)
    c.setFont("Sans-Black", 13)
    c.drawString(26, y, "CARGA, CAFE Y BURNOUT")
    text_block(c, "Cada impacto añade Carga. Al llenarla sufres BURNOUT, gastas un café y vuelves a una entrada segura. Las piezas quedan guardadas.", 26, y - 22, W - 52, "Sans", 8.8, 11.2)
    panel(c, 27, 38, W - 54, 63, ACID, INK)
    c.setFillColor(INK)
    c.setFont("Mono-Bold", 10)
    c.drawString(42, 76, "IDEA 07/12")
    c.drawString(154, 76, "CARGA [ ][ ][ ]")
    c.drawString(303, 76, "CAFE x2")
    c.setFont("Sans-Bold", 7.6)
    c.drawString(42, 54, "Sin cafés: GAME OVER. CONTINUE reinicia la planta, no la campaña.")


def page_agency(c: canvas.Canvas) -> None:
    y = title(c, "Directorio", "Diez plantas / treinta salas", 7, CYAN)
    levels = [
        ("01", "TODO CLARISIMO", "Concepto I"),
        ("02", "UNA PALABRA MENOS", "Copy I"),
        ("03", "ROJO DISCRETO", "Arte I"),
        ("04", "FINAL BUENO, AHORA SI", "Maqueta I"),
        ("05", "REUNION PREVIA", "Concepto II + Copy II"),
        ("06", "PREMIO A NOSOTROS", "Arte II"),
        ("07", "PARA AYER, DE NOCHE", "Maqueta II"),
        ("08", "EL RANKING", "Concepto III + Arte III"),
        ("09", "DEFINITIVA 12", "Copy III + Maqueta III"),
        ("10", "EL PITCH IMPOSIBLE", "3 sellos"),
    ]
    row_h = 33.5
    for idx, (num, name, objective) in enumerate(levels):
        color = [MAGENTA, CYAN, ACID][idx % 3]
        c.setFillColor(color)
        c.rect(26, y - row_h + 3, 47, row_h - 5, fill=1, stroke=0)
        c.setFillColor(INK)
        c.setFont("Sans-Black", 16)
        c.drawCentredString(49.5, y - 24, num)
        c.setStrokeColor(INK)
        c.setLineWidth(1)
        c.line(79, y - row_h + 3, W - 26, y - row_h + 3)
        c.setFont("Sans-Black", 8.3)
        c.drawString(83, y - 15, name)
        c.setFont("Mono-Bold", 6.8)
        c.drawRightString(W - 27, y - 28, objective.upper())
        y -= row_h
    panel(c, 26, 43, W - 52, 67, CREAM, MAGENTA)
    text_block(c, "Cada planta conecta tres salas en triángulo. Tras recoger el objetivo, vuelve al ascensor o salida. Los niveles 4, 7 y 9 aseguran el storyboard.", 40, 82, W - 80, "Sans-Bold", 8.5, 11)


def page_difficulty(c: canvas.Canvas) -> None:
    y = title(c, "Recursos humanos", "Elige tu dificultad", 8, ACID)
    text_block(c, "Las cinco opciones mantienen todas las salas, piezas, soluciones y el mismo final. Solo cambia la presión de Alberto y la ayuda disponible.", 26, y, W - 52, "Sans-Bold", 9, 12)
    y -= 45
    profiles = [
        ("MUY FACIL", "5 Carga / 5 cafés", "Ruta y posición exacta", CYAN),
        ("FACIL", "4 Carga / 4 cafés", "Posición exacta", HexColor("#75D078")),
        ("NORMAL", "3 Carga / 3 cafés", "Última sala conocida", ACID),
        ("DIFICIL", "3 Carga / 2 cafés", "Pista durante 2 segundos", HexColor("#F08B3E")),
        ("MUY DIFICIL", "2 Carga / 2 cafés", "Sin marcador de Alberto", MAGENTA),
    ]
    for idx, (name, resources, help_text, color) in enumerate(profiles):
        h = 64 if name == "NORMAL" else 58
        panel(c, 26, y - h, W - 52, h - 7, white if name == "NORMAL" else CREAM,
              MAGENTA if name == "NORMAL" else INK, sw=3 if name == "NORMAL" else 1.5)
        c.setFillColor(color)
        c.rect(27, y - h + 1, 12, h - 9, fill=1, stroke=0)
        c.setFillColor(INK)
        c.setFont("Sans-Black", 11.5)
        c.drawString(52, y - 24, name)
        c.setFont("Mono-Bold", 7.2)
        c.drawRightString(W - 41, y - 23, resources.upper())
        c.setFont("Sans", 8)
        c.drawString(52, y - 42, help_text)
        if name == "NORMAL":
            label(c, "RECOMENDADA", W - 105, y - 51, MAGENTA, white, 2)
        y -= h + 5
    text_block(c, "Puedes bajar la dificultad tras un BURNOUT o solicitar un cambio desde pausa. Nunca perderás progreso por hacerlo.", 26, 42, W - 52, "Sans-Bold", 8.2, 10.5)


def page_secrets(c: canvas.Canvas) -> None:
    y = title(c, "Circular interna", "Consejos de supervivencia", 9, MAGENTA)
    tips = [
        ("MIRA ANTES DE CORRER", "Al entrar tienes unos instantes de gracia. Úsalos para leer puertas y cobertura."),
        ("ESCUCHA", "La proximidad de Alberto se anuncia con sonido direccional y un pulso de borde."),
        ("HAZ RUIDO CON INTENCION", "Teléfono, fax y fotocopiadora son señuelos, no decoración."),
        ("SIGUE LAS CHISPAS", "Hay tres por planta. Recogerlas en orden mejora tu puntuación."),
        ("EL CIAN ES RUTA", "Cintas y pasos cian marcan saltos contextuales o atajos seguros."),
        ("GUARDA EL CODIGO", "Al cerrar una planta recibes la clave de la siguiente y de tu dificultad."),
    ]
    for idx, (head, body) in enumerate(tips):
        col = idx % 2
        row = idx // 2
        x = 26 + col * 190
        top = y - row * 105
        color = [CYAN, ACID, MAGENTA][row]
        panel(c, x, top - 86, 174, 78, CREAM, color)
        burst(c, x + 24, top - 29, 19, 13, 9, color, str(idx + 1))
        c.setFillColor(INK)
        c.setFont("Sans-Black", 7.4)
        c.drawString(x + 48, top - 26, head)
        text_block(c, body, x + 14, top - 52, 146, "Sans", 7.2, 8.7)
    panel(c, 26, 65, W - 52, 76, INK, MAGENTA)
    c.setFillColor(white)
    c.setFont("Sans-Black", 12)
    c.drawString(41, 113, "RANGOS DE AGENCIA")
    c.setFont("Mono-Bold", 7.3)
    c.drawString(41, 91, "BECARIA / JUNIOR / CREATIVA / DIRECTORA / LEYENDA")
    c.setFillColor(ACID)
    c.setFont("Sans-Bold", 8)
    c.drawString(41, 75, "Tiempo, impactos, cafés, chispas y secretos deciden el rango.")


def page_load(c: canvas.Canvas) -> None:
    y = title(c, "Informática", "Carga y arranque", 10, CYAN)
    cols = [
        (26, "DSK / RECOMENDADO", ["Monta banterhouse.dsk en la unidad A.", 'Escribe: run"loader', "Pulsa Intro y espera la pantalla de título."], MAGENTA),
        (218, "CDT / CASSETTE", ["Monta banterhouse.cdt en el emulador.", "Selecciona CPC 6128 con 128K.", "Inicia la carga de cinta según tu emulador."], CYAN),
    ]
    for x, head, items, color in cols:
        panel(c, x, y - 205, 175, 192, CREAM, color)
        c.setFillColor(color)
        c.rect(x, y - 48, 175, 35, fill=1, stroke=0)
        c.setFillColor(INK)
        c.setFont("Sans-Black", 9.6)
        c.drawCentredString(x + 87.5, y - 35, head)
        yy = y - 75
        for idx, item in enumerate(items, 1):
            c.setFillColor(INK)
            c.circle(x + 25, yy + 2, 11, fill=1, stroke=0)
            c.setFillColor(white)
            c.setFont("Sans-Black", 8)
            c.drawCentredString(x + 25, yy - 1, str(idx))
            yy = text_block(c, item, x + 45, yy + 6, 112, "Sans", 7.9, 10) - 22
    y -= 235
    panel(c, 26, y - 86, W - 52, 79, ACID, INK)
    c.setFillColor(INK)
    c.setFont("Sans-Black", 11)
    c.drawString(40, y - 30, "JUGAR EN LA WEB")
    text_block(c, "Abre banterhouse-128k.donatoexposito.chatgpt.site y pulsa Jugar DSK ahora. El disco se monta automáticamente.", 40, y - 48, W - 80, "Sans-Bold", 8.3, 10.5)
    y -= 112
    c.setFillColor(INK)
    c.setFont("Sans-Black", 12)
    c.drawString(26, y, "SI ALGO NO RESPONDE")
    bullet_list(c, [
        "Comprueba que el equipo está configurado como CPC 6128 / 128K.",
        "Haz clic o toca el monitor del navegador para capturar teclado y sonido.",
        "Reinicia el emulador y vuelve a montar el archivo, sin modificarlo.",
    ], 28, y - 23, W - 54, 8.2, 10.5, MAGENTA)


def page_pitch(c: canvas.Canvas) -> None:
    y = title(c, "Consejo", "El pitch imposible", 11, MAGENTA)
    image_frame(c, ROOT / "site/public/release/screenshots/boss.png", 26, y - 134, W - 52, 118,
                "Tres sellos. Ninguna barra de vida.", ACID)
    y -= 158
    phases = [
        ("01", "EL PITCH", "Activa Concepto, Copy, Arte y Maqueta alrededor de la mesa."),
        ("02", "CAMBIO MINIMO", "Sigue las órdenes fijas y alcanza dos veces el control iluminado."),
        ("03", "COMO AL PRINCIPIO", "Convierte el briefing de Alberto en la solución final."),
    ]
    for num, head, body in phases:
        c.setFillColor(INK)
        c.rect(26, y - 56, 61, 49, fill=1, stroke=0)
        c.setFillColor(ACID)
        c.setFont("Sans-Black", 18)
        c.drawCentredString(56.5, y - 39, num)
        c.setFillColor(MAGENTA)
        c.setFont("Sans-Black", 10)
        c.drawString(101, y - 24, head)
        text_block(c, body, 101, y - 41, W - 127, "Sans", 8.2, 10.2)
        y -= 62
    panel(c, 26, 43, W - 52, 58, CREAM, CYAN)
    text_block(c, "Un BURNOUT reinicia la fase actual, no todo el jefe. Los patrones están anunciados y ninguna fase estrena reglas nuevas.", 41, 78, W - 82, "Sans-Bold", 8.1, 9.8)


def page_back(c: canvas.Canvas) -> None:
    c.setFillColor(PAPER)
    c.rect(0, 0, W, H, fill=1, stroke=0)
    dots(c, 0, H * .52, W, H * .48, Color(0, 0, 0, alpha=.12), 9)
    c.setFillColor(INK)
    c.rect(0, 0, W, 198, fill=1, stroke=0)
    label(c, "EXPEDIENTE CERRADO", 28, H - 44, MAGENTA)
    c.setFillColor(INK)
    c.setFont("Sans-Black", 34)
    c.drawString(26, H - 94, "LA GRAN IDEA")
    c.drawString(26, H - 126, "NO SE ENTREGA.")
    c.setFillColor(MAGENTA)
    c.drawString(26, H - 158, "SE SOBREVIVE.")
    image_frame(c, ROOT / "site/public/release/screenshots/victory.png", 39, 244, W - 78, 150,
                "Una idea aprobada: fenómeno poco frecuente", CYAN)
    c.setFillColor(white)
    c.setFont("Sans-Black", 13)
    c.drawString(28, 164, "BANTERHOUSE")
    c.setFont("Sans", 8.2)
    text_block(c, "Diseño, programación y producción: Casa de la Guasa Software. Juego para Amstrad CPC 6128. Manual original, edición 2026.", 28, 142, W - 56, "Sans", 8.2, 11, white)
    c.setFillColor(ACID)
    c.setFont("Mono-Bold", 7.2)
    c.drawString(28, 93, "banterhouse-128k.donatoexposito.chatgpt.site")
    c.setFillColor(white)
    c.setFont("Sans", 6.8)
    text_block(c, "Inspiración editorial: manuales españoles de videojuegos de los años ochenta. Obra no afiliada a sus editoras históricas ni al cómic que inspira su energía visual.", 28, 66, W - 56, "Sans", 6.8, 9, white)
    c.setFillColor(CYAN)
    c.rect(0, 17, W, 11, fill=1, stroke=0)


def build() -> None:
    OUT.parent.mkdir(parents=True, exist_ok=True)
    c = canvas.Canvas(str(OUT), pagesize=A5, pageCompression=1)
    c.setTitle("Banterhouse - Manual de instrucciones")
    c.setAuthor("Casa de la Guasa Software")
    c.setSubject("Manual de usuario para Amstrad CPC 6128")
    c.setKeywords("Banterhouse, Amstrad CPC 6128, manual, videojuego")
    pages = [
        page_cover, page_welcome, page_mission, page_controls, page_play,
        page_danger, page_agency, page_difficulty, page_secrets, page_load,
        page_pitch, page_back,
    ]
    for index, page in enumerate(pages):
        page(c)
        if 1 <= index <= 10:
            footer(c, index + 1)
        if index != len(pages) - 1:
            c.showPage()
    c.save()
    print(OUT)


if __name__ == "__main__":
    build()
