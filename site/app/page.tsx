import EmulatorPlayer from './EmulatorPlayer';

const cpcScreens = [
  {
    src: '/release/screenshots/mesa-pitu.png',
    alt: 'Pitu comienza la campaña en su mesa de la primera planta',
    caption: 'Mesa Pitu · Planta 1',
  },
  {
    src: '/release/screenshots/estudio-noche.png',
    alt: 'Pitu recorre el Estudio Noche con un fondo azul y magenta',
    caption: 'Estudio Noche · Planta 7',
  },
  {
    src: '/release/screenshots/proyeccion.png',
    alt: 'El pitch final en la sala de Proyección ante el Presidente',
    caption: 'Proyección · Pitch final',
  },
];

export default function Home() {
  return (
    <main id="contenido">
      <a className="skip-link" href="#release-title">Saltar al contenido</a>
      <nav className="topbar" aria-label="Navegación principal">
        <a className="topbar-brand" href="#arriba">BH/128</a>
        <div className="topbar-links">
          <a href="#argumento">Argumento</a>
          <a href="#expediente">Expediente</a>
          <a href="#descargas">Descargas</a>
          <a href="#micromania">Micromanía</a>
          <a href="#jugar">Jugar</a>
        </div>
      </nav>

      <section className="hero" id="arriba" aria-labelledby="release-title">
        <div className="hero-copy">
          <p className="eyebrow">La exclusiva mundial que nadie pidió</p>
          <h1 id="release-title">Banterhouse</h1>
          <p className="subhead">La Gran Idea no se entrega. Se sobrevive.</p>
          <p className="intro">
            Pitu tiene una noche para recomponer una campaña imposible. Alberto
            Pérez del Briefing Ramírez de Quiñones tiene otros planes. Bienvenido
            a la agencia que convirtió el caos en método: la Casa de la Guasa.
          </p>
          <div className="hero-actions">
            <a className="button button-primary" href="#jugar">Jugar Disquette 3&quot; ahora</a>
            <a className="button button-secondary" href="/release/banterhouse.dsk" download>
              Descargar Disquette 3&quot;
            </a>
          </div>
          <p className="compatibility">EDICIÓN DISQUETTE 3&quot; · CPC 6128 · 128K · MODO 0 · AY SOUND</p>
        </div>

        <figure className="product-shot">
          <img
            src="/release/banterhouse-disk-inlay.png"
            alt="Edición recomendada de Banterhouse en disco de 3 pulgadas, con estuche, etiqueta e instrucciones"
          />
          <figcaption>Edición recomendada · Disco 3&quot; · 1.900 PTAS.</figcaption>
        </figure>

      </section>

      <div className="marquee" aria-label="Características del juego">
        <div className="marquee-track">
          <span>★ NUEVO ★ ACCIÓN PUBLICITARIA EN 128K ★ 30 PANTALLAS ★ 12 PIEZAS DE CREATIVIDAD ★ UN BRIEFING DE MÁS ★</span>
          <span aria-hidden="true">★ NUEVO ★ ACCIÓN PUBLICITARIA EN 128K ★ 30 PANTALLAS ★ 12 PIEZAS DE CREATIVIDAD ★ UN BRIEFING DE MÁS ★</span>
        </div>
      </div>

      <section className="story-section" id="argumento">
        <div className="story-kicker">Madrid. 03:17 horas. Definitiva_12_FINAL_AHORA_SÍ.</div>
        <div className="story-grid">
          <h2>¿Podrá Pitu salvar la idea antes de que Alberto salve la cuenta?</h2>
          <div className="story-copy">
            <p>
              El cliente ha pedido «lo mismo, pero distinto». La Gran Idea ha
              estallado en doce fragmentos y se ha dispersado por las diez plantas
              de la agencia. Los teléfonos no paran. La fotocopiadora sabe demasiado.
              El Presidente espera en la última planta.
            </p>
            <p>
              Tú eres Pitu. Reúne concepto, copy, arte y maqueta. Escóndete tras las
              mesas. Provoca llamadas. Haz que el caos trabaje para ti. Y, sobre todo,
              evita que Alberto te alcance con otro briefing «de dos minutos».
            </p>
          </div>
        </div>

        <div className="screenshot-strip" aria-label="Capturas reales del juego">
          {cpcScreens.map((screen, index) => (
            <figure key={screen.src} className={`screen screen-${index + 1}`}>
              <img src={screen.src} alt={screen.alt} />
              <figcaption>{screen.caption} · Imagen real Amstrad CPC</figcaption>
            </figure>
          ))}
        </div>

      </section>

      <section className="dossier" id="expediente" aria-labelledby="dossier-title">
        <header className="section-heading inverse-heading">
          <p>Expediente confidencial / Solo ojos creativos</p>
          <h2 id="dossier-title">Dos profesionales. Una campaña. Cero posibilidades.</h2>
        </header>

        <div className="character-cards">
          <article className="character-card pitu-card">
            <div className="character-visual pixel-visual">
              <img src="/release/characters/pitu.png" alt="Pitu, la creativa" />
            </div>
            <div className="character-copy">
              <span className="stamp">JUGADOR 1</span>
              <h3>Pitu</h3>
              <p className="role">Creativa. Superviviente. Último café: 02:41.</p>
              <p>
                Armada con un rotulador, unas zapatillas y la única neurona todavía
                despierta. Pitu no combate: piensa, despista y consigue que las
                máquinas de la agencia se rebelen contra el planning.
              </p>
              <dl>
                <div><dt>Especialidad</dt><dd>Encontrar ideas donde nadie miró</dd></div>
                <div><dt>Punto débil</dt><dd>El briefing «muy abierto»</dd></div>
              </dl>
            </div>
          </article>

          <article className="character-card alberto-card">
            <div className="character-visual alberto-visual">
              <img src="/release/characters/alberto.png" alt="Alberto Pérez del Briefing Ramírez de Quiñones" />
            </div>
            <div className="character-copy">
              <span className="stamp">CUENTAS</span>
              <h3>Alberto</h3>
              <p className="full-name">Pérez del Briefing Ramírez de Quiñones</p>
              <p className="role">Ejecutivo. Perseguidor. Urgente desde ayer.</p>
              <p>
                Un hombre capaz de pronunciar «solo es un cambio» sin pestañear.
                Recorre la agencia con sonrisa reglamentaria, corbata negra y
                briefings de alta velocidad. Oye un teléfono a tres despachos.
              </p>
              <dl>
                <div><dt>Especialidad</dt><dd>Añadir una cosa más</dd></div>
                <div><dt>Punto débil</dt><dd>La línea ocupada</dd></div>
              </dl>
            </div>
          </article>
        </div>
      </section>

      <section className="agency-section">
        <div className="agency-title">
          <span className="agency-number">128</span>
          <div>
            <p>Nombre en clave</p>
            <h2>Banterhouse</h2>
            <em>Del inglés: Casa de la Guasa.</em>
          </div>
        </div>
        <div className="agency-copy">
          <p>
            Sobre el papel, una agencia de publicidad. En la práctica, un laberinto
            de viñetas, cristales, teléfonos, faxes, rankings amañados y cafés que
            jamás debieron existir.
          </p>
          <p>
            Diez plantas. Treinta pantallas. Doce piezas de creatividad. Un pitch
            final ante el Presidente. Cada sala tiene su propio rótulo, paleta y
            landmark: del Túnel Pantone al Estudio Noche, del archivo a la sala de
            Proyección. Y una promesa publicitaria que, por una vez, es rigurosamente
            cierta: <strong>no hay dos partidas iguales si nadie entiende el briefing.</strong>
          </p>
        </div>
      </section>

      <section className="release-section" id="descargas" aria-labelledby="release-heading">
        <header className="section-heading">
          <p>Disponible ahora / sin cupón de respuesta</p>
          <h2 id="release-heading">Elige tu formato. Asume las consecuencias.</h2>
        </header>

        <div className="release-grid">
          <article className="release-card release-dsk release-recommended">
            <span className="format-label">RECOMENDADA · DISCO 3&quot;</span>
            <div className="disk-art" aria-hidden="true">
              <div className="three-inch-disk">
                <span className="disk-side">A</span>
                <span className="disk-shutter-art" />
                <span className="disk-spindle-art" />
                <span className="disk-label-art">
                  <small>BANTERHOUSE</small>
                  <b>AMSTRAD CPC 6128</b>
                  <i>DISQUETTE 3&quot;</i>
                </span>
              </div>
            </div>
            <div className="release-card-copy">
              <h3>Disquette 3&quot; ejecutivo</h3>
              <p>La experiencia por defecto: carga rápida, emulador integrado y estuche imprimible.</p>
              <a className="button button-primary" href="/release/banterhouse.dsk" download>
                Descargar Disquette 3&quot;
              </a>
              <a className="packaging-link" href="/release/banterhouse-disk-inlay.png" download>
                Carátula disco 3&quot; ↘
              </a>
              <a className="packaging-link" href="/release/banterhouse-manual.pdf" download>
                Manual ilustrado ↘
              </a>
              <small>REF. BH-D3 · EDICIÓN RECOMENDADA · 1.900 PTAS.</small>
            </div>
          </article>

          <article className="release-card release-cassette">
            <span className="format-label">ALTERNATIVA · CASSETTE</span>
            <img src="/release/banterhouse-cassette-hero.png" alt="Edición cassette de Banterhouse" />
            <div className="release-card-copy">
              <h3>Cassette de medianoche</h3>
              <p>Formato alternativo en cinta magnética, con carátula para las dos caras.</p>
              <a className="button button-dark" href="/release/banterhouse.cdt" download>
                Descargar Cassette
              </a>
              <a className="packaging-link" href="/release/banterhouse-cassette-inlay.png" download>
                Carátula cassette ↘
              </a>
              <small>REF. BH-K7 · EDICIÓN ALTERNATIVA · 875 PTAS.</small>
            </div>
          </article>

          <article className="release-card release-complete">
            <span className="format-label">PACK COMPLETO</span>
            <img src="/release/banterhouse-ad-a4.png" alt="Anuncio de revista de Banterhouse" />
            <div className="release-card-copy">
              <h3>Casa de la Guasa</h3>
              <p>Disquette 3&quot;, Cassette, manual ilustrado, carátulas, portada y materiales de lanzamiento.</p>
              <a className="button button-secondary" href="/release/banterhouse-release.zip" download>
                Descargar ZIP
              </a>
              <a className="packaging-link" href="/release/banterhouse-ad-a4.png" download>
                Anuncio de revista ↘
              </a>
              <a className="packaging-link" href="/release/banterhouse-micromania-article.pdf" download>
                Artículo Micromanía ↘
              </a>
              <small>REF. BH-ZIP · COPIAS ESCANDALOSAMENTE ILIMITADAS</small>
            </div>
          </article>
        </div>

        <article className="manual-callout" id="manual" aria-labelledby="manual-heading">
          <div className="manual-cover" aria-hidden="true">
            <small>EDICIÓN CPC 6128 / 128K</small>
            <strong>BANTER<br />HOUSE</strong>
            <span>MANUAL DE<br />INSTRUCCIONES</span>
            <i>12 PÁGINAS · A5</i>
          </div>
          <div className="manual-copy">
            <p className="eyebrow">Documentación para sobrevivir al briefing</p>
            <h3 id="manual-heading">El manual que debía venir en la caja.</h3>
            <p>
              Misión, controles, Carga y café, cinco dificultades, las diez plantas,
              consejos de supervivencia y guía de arranque. Un libreto original
              inspirado en la energía editorial del software español de 8 bits.
            </p>
            <div className="manual-actions">
              <a className="button button-primary" href="/release/banterhouse-manual.pdf" download>
                Descargar manual PDF
              </a>
              <a className="button button-dark" href="/release/banterhouse-release.zip" download>
                Manual + juego
              </a>
            </div>
            <small>PDF A5 · 12 PÁGINAS · INCLUIDO TAMBIÉN EN EL PACK COMPLETO</small>
          </div>
        </article>
      </section>

      <section className="magazine-feature" id="micromania" aria-labelledby="magazine-heading">
        <div className="magazine-feature-copy">
          <p className="eyebrow">Hemeroteca imposible / Noviembre 1987</p>
          <h2 id="magazine-heading">Micromanía somete la Casa de la Guasa a su joystick.</h2>
          <p>
            Una doble página con análisis, pantallazos, ficha técnica y veredicto
            editorial. Recreación no oficial inspirada en la primera época de la
            prensa española de 8 bits.
          </p>
          <div className="magazine-actions">
            <a className="button button-primary" href="/release/banterhouse-micromania-article.pdf" download>
              Descargar PDF
            </a>
            <a className="button button-dark" href="/release/banterhouse-micromania-spread.png" download>
              Alta resolución
            </a>
            <a className="button button-secondary" href="/release/banterhouse-launch-email.html">
              Ver anuncio email
            </a>
            <a className="button button-dark" href="/release/banterhouse-email-ad.png" download>
              Descargar anuncio
            </a>
          </div>
          <small>PIEZA APÓCRIFA · NO PUBLICADA NI AFILIADA A MICROMANÍA</small>
        </div>
        <a className="magazine-preview" href="/release/banterhouse-micromania-spread.png" download aria-label="Descargar doble página de Micromanía en alta resolución">
          <img src="/release/banterhouse-micromania-spread.png" alt="Doble página de revista dedicada a Banterhouse" />
        </a>
      </section>

      <section className="play-section" id="jugar" aria-labelledby="play-heading">
        <div className="play-copy">
          <p className="eyebrow">Demostración en el punto de venta</p>
          <h2 id="play-heading">Haz clic. Coge el teclado. Salva la agencia.</h2>
          <p>
            El disco se monta automáticamente en un Amstrad CPC 6128 virtual.
            Haz clic dentro del monitor para activar teclado y sonido.
          </p>
          <ul>
            <li><b>Flechas / QAOP</b> — Mover a Pitu</li>
            <li><b>Espacio</b> — Acción</li>
            <li><b>Esc</b> — Pausa</li>
          </ul>
          <p className="emulator-note">
            Si no arranca solo, escribe <code>run&quot;loader</code> y pulsa Intro.
          </p>
        </div>

        <EmulatorPlayer />
      </section>

      <footer>
        <p>BANTERHOUSE · UN PRODUCTO DE LA CASA DE LA GUASA · MADRID / 1987→2026</p>
        <p>
          Emulación por <a href="https://github.com/salvogendut/1984">1984</a> · GPL-2.0 ·
          Hecho con 128K, café recalentado e ideas imposibles ·
          <a href="https://github.com/fersantxez/banterhouse"> Código en GitHub</a>.
        </p>
      </footer>
    </main>
  );
}
