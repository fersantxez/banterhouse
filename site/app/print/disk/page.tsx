export default function DiskInlay() {
  return (
    <main className="print-canvas disk-canvas">
      <div className="print-instructions">
        BANTERHOUSE · ESTUCHE DISCO AMSTRAD 3&quot; · CORTAR LÍNEA CONTINUA / PLEGAR LÍNEA DISCONTINUA
      </div>

      <section className="disk-package" aria-label="Carátula desplegada para disco Amstrad CPC de tres pulgadas">
        <article className="disk-cover-front">
          <img src="/release/banterhouse-cover.png" alt="Portada de Banterhouse" />
          <div className="disk-format-badge">DISCO<br />3&quot;</div>
          <div className="disk-price-badge">1.900<small>PTAS.</small></div>
          <div className="disk-cover-band">AMSTRAD CPC 6128 · 128K · REF. BH-D3</div>
        </article>

        <div className="disk-package-spine">
          <b>BANTERHOUSE</b><span>DISCO 3&quot; · 128K</span><i>BH-D3</i>
        </div>

        <article className="disk-cover-back">
          <header><b>BANTERHOUSE</b><span>ACCIÓN PUBLICITARIA EN 128K</span></header>
          <h2>El enemigo lleva corbata.</h2>
          <p>
            Madrid, 03:17. Pitu debe reconstruir la Gran Idea y alcanzar el pitch
            final antes de que Alberto Pérez del Briefing Ramírez de Quiñones
            llegue con otro cambio «mínimo».
          </p>
          <div className="disk-back-screens">
            <figure><img src="/release/screenshots/gameplay.png" alt="Juego" /><figcaption>¡30 PANTALLAS!</figcaption></figure>
            <figure><img src="/release/screenshots/boss.png" alt="Pitch final" /><figcaption>¡UN PITCH IMPOSIBLE!</figcaption></figure>
          </div>
          <div className="disk-back-features">
            <b>TECLADO / JOYSTICK</b><span>QAOP O FLECHAS — MOVER</span><span>ESPACIO — ACCIÓN</span>
          </div>
          <footer><span>CASA DE LA GUASA SOFTWARE</span><b>DISCO 3&quot; · 1.900 PTAS.</b></footer>
        </article>
      </section>

      <section className="disk-print-extras" aria-label="Etiqueta y lomo para disco de tres pulgadas">
        <div className="amstrad-disk-label">
          <div className="disk-shutter" aria-hidden="true"></div>
          <span>DISCO 3&quot; · CARA A</span>
          <b>BANTERHOUSE</b>
          <i>CASA DE LA GUASA SOFTWARE · BH-D3</i>
          <div className="disk-hub" aria-hidden="true"></div>
        </div>
        <div className="disk-instructions-block">
          <h3>INSTRUCCIONES DE ARRANQUE</h3>
          <p>INTRODUZCA EL DISCO EN LA UNIDAD A. ESCRIBA <b>RUN&quot;LOADER</b> Y PULSE INTRO.</p>
          <div><b>AMSTRAD CPC 6128</b><span>128K OBLIGATORIOS</span><strong>1.900 PTAS.</strong></div>
        </div>
      </section>
    </main>
  );
}
