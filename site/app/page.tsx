const cpcScreens = [
  { src: '/release/screenshots/loading.png', alt: 'Pantalla de carga de Banterhouse' },
  { src: '/release/screenshots/gameplay.png', alt: 'Pitu recorre la agencia en Amstrad CPC' },
  { src: '/release/screenshots/boss.png', alt: 'El pitch final ante el Presidente' },
];

export default function Home() {
  return (
    <main>
      <nav className="topbar" aria-label="Navegación principal">
        <a className="topbar-brand" href="#arriba">BH/128</a>
        <div className="topbar-links">
          <a href="#argumento">Argumento</a>
          <a href="#expediente">Expediente</a>
          <a href="#descargas">Descargas</a>
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
            <a className="button button-primary" href="#jugar">Jugar ahora</a>
            <a className="button button-secondary" href="#descargas">
              Elegir formato
            </a>
          </div>
          <p className="compatibility">AMSTRAD CPC 6128 · 128K · MODO 0 · AY SOUND</p>
        </div>

        <figure className="product-shot">
          <img
            src="/release/banterhouse-cassette-hero.png"
            alt="Edición en cassette de Banterhouse con Pitu y Alberto en portada"
          />
          <figcaption>Cassette 875 PTAS. · Disco 3&quot; 1.900 PTAS.</figcaption>
        </figure>

        <div className="sticker" aria-label="100% publicidad de guerrilla">
          <span>100%</span>
          <small>PUBLICIDAD<br />DE GUERRILLA</small>
        </div>
      </section>

      <div className="marquee" aria-label="Características del juego">
        <div>★ NUEVO ★ ACCIÓN PUBLICITARIA EN 128K ★ 30 PANTALLAS ★ 12 PIEZAS DE CREATIVIDAD ★ UN BRIEFING DE MÁS ★</div>
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
              <figcaption>Imagen real Amstrad CPC · {index + 1}/3</figcaption>
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
            final ante el Presidente. Y una promesa publicitaria que, por una vez,
            es rigurosamente cierta: <strong>no hay dos partidas iguales si nadie
            entiende el briefing.</strong>
          </p>
        </div>
      </section>

      <section className="release-section" id="descargas" aria-labelledby="release-heading">
        <header className="section-heading">
          <p>Disponible ahora / sin cupón de respuesta</p>
          <h2 id="release-heading">Elige tu formato. Asume las consecuencias.</h2>
        </header>

        <div className="release-grid">
          <article className="release-card release-cassette">
            <span className="format-label">CASSETTE · 875 PTAS.</span>
            <img src="/release/banterhouse-cassette-hero.png" alt="Edición cassette de Banterhouse" />
            <div className="release-card-copy">
              <h3>Cassette de medianoche</h3>
              <p>Imagen `.cdt` y carátula desplegada con etiquetas para las dos caras.</p>
              <a className="button button-primary" href="/release/banterhouse.cdt" download>
                Descargar .CDT
              </a>
              <a className="packaging-link" href="/release/banterhouse-cassette-inlay.png" download>
                Carátula cassette ↘
              </a>
              <small>REF. BH-K7 · PRECIO DE VENTA AL PÚBLICO: 875 PTAS.</small>
            </div>
          </article>

          <article className="release-card release-dsk">
            <span className="format-label">DISCO 3&quot; · 1.900 PTAS.</span>
            <div className="disk-art" aria-hidden="true">
              <span>3&quot;</span><b>DISCO</b><i>BANTERHOUSE · 128K</i>
            </div>
            <div className="release-card-copy">
              <h3>Disquete ejecutivo</h3>
              <p>Imagen `.dsk` y estuche imprimible para disco Amstrad CPC de 3 pulgadas.</p>
              <a className="button button-dark" href="/release/banterhouse.dsk" download>
                Descargar .DSK
              </a>
              <a className="packaging-link" href="/release/banterhouse-disk-inlay.png" download>
                Carátula disco 3&quot; ↘
              </a>
              <small>REF. BH-D3 · PRECIO DE VENTA AL PÚBLICO: 1.900 PTAS.</small>
            </div>
          </article>

          <article className="release-card release-complete">
            <span className="format-label">PACK COMPLETO</span>
            <img src="/release/banterhouse-ad-a4.png" alt="Anuncio de revista de Banterhouse" />
            <div className="release-card-copy">
              <h3>Casa de la Guasa</h3>
              <p>Los dos juegos, las dos carátulas, portada, anuncio A4 e instrucciones.</p>
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
      </section>

      <section className="magazine-feature" aria-labelledby="magazine-heading">
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

        <div className="emulator-shell">
          <div className="monitor-label">
            <span>BANTERHOUSE VISION</span>
            <i>128K COLOUR PERSONAL COMPUTER</i>
          </div>
          <iframe
            title="Emulador Amstrad CPC 6128 con Banterhouse"
            src="/emulator/?memory=128&diska=../release/banterhouse.dsk&autorun=LOADER.BAS&theme=Retro%20CRT"
            allow="autoplay; fullscreen; gamepad"
            loading="lazy"
          />
          <div className="monitor-controls" aria-hidden="true">
            <span>POWER</span><b></b><b></b><b></b><i>GT-65</i>
          </div>
        </div>
      </section>

      <footer>
        <p>BANTERHOUSE · UN PRODUCTO DE LA CASA DE LA GUASA · MADRID / 1987→2026</p>
        <p>
          Emulación por <a href="https://github.com/salvogendut/1984">1984</a> · GPL-2.0 ·
          Hecho con 128K, café recalentado y cambios mínimos.
        </p>
      </footer>
    </main>
  );
}
