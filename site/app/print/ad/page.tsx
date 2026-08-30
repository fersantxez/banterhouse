export default function Advertisement() {
  return (
    <main className="print-canvas ad-canvas">
      <section className="ad-sheet">
        <header className="ad-topline">
          <span>NOVEDAD ABSOLUTA</span>
          <b>AMSTRAD CPC 6128 · 128K</b>
          <span>REF. BH-128</span>
        </header>

        <div className="ad-title-block">
          <p>ESTA NOCHE,</p>
          <h1>EL ENEMIGO LLEVA CORBATA.</h1>
        </div>

        <div className="ad-art">
          <img src="/release/banterhouse-cover.png" alt="Portada de Banterhouse" />
          <div className="ad-burst"><b>¡30</b><span>PANTALLAS<br />DE ACCIÓN!</span></div>
        </div>

        <div className="ad-copy-grid">
          <div className="ad-story">
            <h2>BANTERHOUSE</h2>
            <h3>LA GRAN IDEA NO SE ENTREGA. SE SOBREVIVE.</h3>
            <p>
              Madrid, 03:17 horas. El cliente ha pedido «lo mismo, pero distinto».
              La campaña ha saltado por los aires y sus doce fragmentos están
              perdidos en las diez plantas de la agencia más peligrosa de la ciudad.
            </p>
            <p>
              Tú eres <strong>PITU</strong>, creativa, insomne y última esperanza
              de la cuenta. Reúne concepto, copy, arte y maqueta. Utiliza teléfonos,
              máquinas y escondites. Llega al pitch final antes que
              <strong> ALBERTO PÉREZ DEL BRIEFING RAMÍREZ DE QUIÑONES</strong>,
              el comercial que nunca trae un cambio pequeño.
            </p>
          </div>

          <div className="ad-mission">
            <h3>TU MISIÓN</h3>
            <ul>
              <li>RECUPERA LAS 12 PIEZAS DE LA GRAN IDEA.</li>
              <li>ENGAÑA A ALBERTO CON TELÉFONOS Y FAXES.</li>
              <li>ATRAVIESA 10 NIVELES DE CAOS PUBLICITARIO.</li>
              <li>CONVENCE AL PRESIDENTE EN EL PITCH IMPOSIBLE.</li>
            </ul>
            <div className="ad-villain">
              <img src="/release/characters/alberto.png" alt="Alberto" />
              <blockquote>«PITU, ES SOLO UN CAMBIO.»</blockquote>
            </div>
            <div className="ad-agency">
              <b>BANTERHOUSE</b>
              <span>Del inglés: Casa de la Guasa.</span>
            </div>
          </div>
        </div>

        <div className="ad-screens">
          <figure><img src="/release/screenshots/gameplay.png" alt="Juego" /><figcaption>¡RECORRE LA AGENCIA!</figcaption></figure>
          <figure><img src="/release/screenshots/boss.png" alt="Pitch final" /><figcaption>¡SOBREVIVE AL PITCH!</figcaption></figure>
          <figure><img src="/release/screenshots/victory.png" alt="Victoria" /><figcaption>¡SALVA LA IDEA!</figcaption></figure>
        </div>

        <footer className="ad-footer">
          <div><b>CASA DE LA GUASA SOFTWARE</b><span>MODO 0 · MÚSICA AY · TECLADO/JOYSTICK</span></div>
          <div className="ad-price"><small>PRECIO LANZAMIENTO</small><b>1.495 PTS.</b></div>
          <div className="ad-platform"><b>128K</b><span>DISCO 3&quot;</span></div>
        </footer>
      </section>
    </main>
  );
}
