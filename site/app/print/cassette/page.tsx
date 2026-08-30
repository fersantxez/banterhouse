export default function CassetteInlay() {
  return (
    <main className="print-canvas cassette-canvas">
      <div className="print-instructions">
        BANTERHOUSE · CARÁTULA CASSETTE · CORTAR LÍNEA CONTINUA / PLEGAR LÍNEA DISCONTINUA
      </div>

      <section className="inlay" aria-label="Carátula desplegada de cassette">
        <div className="inlay-back">
          <header><b>BANTERHOUSE</b><span>ACCIÓN PUBLICITARIA EN 128K</span></header>
          <h2>La Gran Idea no se entrega. Se sobrevive.</h2>
          <p>
            Son las 03:17. La campaña está hecha pedazos. Pitu debe reunir doce
            fragmentos de creatividad y alcanzar el pitch final mientras Alberto
            Pérez del Briefing Ramírez de Quiñones recorre la agencia con otro
            cambio «mínimo».
          </p>
          <div className="inlay-screens">
            <img src="/release/screenshots/gameplay.png" alt="Juego" />
            <img src="/release/screenshots/boss.png" alt="Jefe final" />
          </div>
          <div className="inlay-controls">
            <b>CONTROLES</b><span>QAOP / FLECHAS — MOVER</span><span>ESPACIO — ACCIÓN</span><span>ESC — PAUSA</span>
          </div>
          <small>© 1987→2026 CASA DE LA GUASA SOFTWARE · AMSTRAD CPC 6128 · 128K</small>
        </div>

        <div className="inlay-spine">
          <b>BANTERHOUSE</b><span>CASSETTE · AMSTRAD CPC 128K</span><i>BH-K7</i>
        </div>

        <div className="inlay-front">
          <img src="/release/banterhouse-cover.png" alt="Portada" />
          <div className="front-badge">128K</div>
          <div className="front-price">875<small>PTAS.</small></div>
          <div className="front-platform">AMSTRAD CPC 128K · CASSETTE EDITION · 875 PTAS.</div>
        </div>
      </section>

      <section className="cassette-labels" aria-label="Etiquetas para cassette">
        <div className="cassette-label label-a">
          <span>CARA A</span><b>BANTERHOUSE</b><i>LA CASA DE LA GUASA</i><small>128K · BH-K7 · 875 PTAS.</small>
          <div className="label-holes"><i></i><i></i><i></i></div>
        </div>
        <div className="cassette-label label-b">
          <span>CARA B</span><b>THE BRIEFING SIDE</b><i>NO APAGUE EL ORDENADOR</i><small>128K · BH-K7 · 875 PTAS.</small>
          <div className="label-holes"><i></i><i></i><i></i></div>
        </div>
      </section>
    </main>
  );
}
