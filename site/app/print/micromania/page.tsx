const screens = [
  { src: '/release/screenshots/gameplay.png', caption: 'Pitu inspecciona la planta creativa. El café es decorativo.' },
  { src: '/release/screenshots/boss.png', caption: 'El Presidente espera. La campaña, de momento, no.' },
  { src: '/release/screenshots/victory.png', caption: 'Una idea aprobada: fenómeno poco frecuente en la naturaleza.' },
];

export default function MicromaniaArticle() {
  return (
    <main className="print-canvas micromania-canvas">
      <section className="mm-spread" aria-label="Artículo doble página inspirado en Micromanía de 1987">
        <div className="mm-fold" aria-hidden="true"></div>

        <article className="mm-page mm-page-left">
          <header className="mm-masthead">
            <div><b>MICROMANÍA</b><i>SÓLO PARA ADICTOS</i></div>
            <span>ESPECIAL IMAGINARIO · NOVIEMBRE 1987</span>
          </header>
          <div className="mm-vertical-title" aria-hidden="true">LO NUEVO</div>

          <section className="mm-title-block">
            <p>CASA DE LA GUASA SOFTWARE · AMSTRAD CPC 6128</p>
            <h1>BANTERHOUSE</h1>
            <h2>La Gran Idea no se entrega. Se sobrevive.</h2>
          </section>

          <section className="mm-opening">
            <div className="mm-opening-copy">
              <h3>UNA NOCHE MUY LARGA</h3>
              <p className="mm-dropcap">
                Son las 03:17 y en las oficinas de Banterhouse sólo quedan dos
                cosas en pie: la máquina de café y un briefing que debía haberse
                entregado ayer. La campaña ha saltado por los aires y sus doce
                fragmentos están repartidos por las diez plantas de la agencia.
              </p>
              <p>
                En tan delicada situación tomamos el control de Pitu, creativa,
                insomne y última esperanza de la cuenta. Nuestro cometido consiste
                en recuperar concepto, copy, arte y maqueta antes de que Alberto
                Pérez del Briefing Ramírez de Quiñones aparezca con una de sus
                célebres correcciones «de dos minutos».
              </p>
            </div>
            <figure className="mm-hero-screen">
              <img src="/release/screenshots/loading.png" alt="Pantalla de carga de Banterhouse" />
              <figcaption>La aventura empieza cuando las personas sensatas ya se han ido.</figcaption>
            </figure>
          </section>

          <section className="mm-body-columns">
            <div>
              <h3>LA OFICINA CONTRAATACA</h3>
              <p>
                Banterhouse no es un simple decorado. Teléfonos, faxes, puertas,
                escondites y máquinas forman un pequeño mecanismo de precisión.
                Pitu no dispara: piensa. Una llamada oportuna puede mandar a
                Alberto al extremo opuesto de la planta; una puerta abierta a
                destiempo puede dejarnos frente a su corbata.
              </p>
            </div>
            <div>
              <h3>ACCIÓN CON CEREBRO</h3>
              <p>
                Cada pantalla plantea una ruta, un objeto y una decisión. El
                control responde con rapidez y obliga a observar antes de moverse.
                La mezcla de persecución y rompecabezas resulta sencilla de
                entender, aunque completar las treinta pantallas exige memoria,
                sangre fría y cierta experiencia esquivando reuniones.
              </p>
            </div>
            <div>
              <h3>LA CASA DE LA GUASA</h3>
              <p>
                Bajo su nombre inglés, la agencia es una sátira de la publicidad
                tratada con absoluta seriedad aventurera. Rankings amañados,
                fotocopiadoras sospechosas y cafés radiactivos construyen un mundo
                reconocible y absurdo. El humor no interrumpe el juego: es el juego.
              </p>
            </div>
          </section>

          <section className="mm-dossier-panel">
            <header><span>EXPEDIENTE CONFIDENCIAL</span><b>DOS PROFESIONALES. CERO POSIBILIDADES.</b></header>
            <div className="mm-dossier-grid">
              <article>
                <img src="/release/characters/pitu.png" alt="Pitu" />
                <div><h3>PITU</h3><p>Creativa. Último café: 02:41. Su arma es pensar dos pantallas por delante.</p><b>JUGADOR 1</b></div>
              </article>
              <article>
                <img src="/release/characters/alberto.png" alt="Alberto" />
                <div><h3>ALBERTO</h3><p>Ejecutivo. Urgente desde ayer. Escucha un teléfono a tres despachos.</p><b>PELIGRO</b></div>
              </article>
            </div>
            <blockquote>«PITU, ES SÓLO UN CAMBIO.»</blockquote>
          </section>

          <footer className="mm-page-footer"><span>24 · MICROMANÍA</span><i>RECREACIÓN EDITORIAL NO OFICIAL · 2026</i></footer>
        </article>

        <article className="mm-page mm-page-right">
          <header className="mm-running-head"><b>MEGA JUEGO</b><span>AMSTRAD CPC 128K</span></header>

          <section className="mm-right-lead">
            <div>
              <p>EL ENEMIGO LLEVA CORBATA</p>
              <h2>UN BRIEFING DE MÁS</h2>
            </div>
            <div className="mm-cover-mini">
              <img src="/release/banterhouse-cover.png" alt="Portada de Banterhouse" />
            </div>
          </section>

          <section className="mm-screens-row">
            {screens.map((screen, index) => (
              <figure key={screen.src} className={`mm-shot mm-shot-${index + 1}`}>
                <img src={screen.src} alt={screen.caption} />
                <figcaption>{screen.caption}</figcaption>
              </figure>
            ))}
          </section>

          <section className="mm-right-copy">
            <div>
              <h3>ALBERTO NO DESCANSA</h3>
              <p>
                El gran hallazgo es Alberto. No se limita a recorrer una ruta:
                atiende al ruido, cambia de planta y convierte cada operación en
                una persecución. Su presencia se anuncia antes de verse, de modo
                que el jugador siempre dispone de un segundo para preparar una
                estratagema o lamentar su última decisión.
              </p>
              <h3>COLOR, RUIDO Y CARÁCTER</h3>
              <p>
                Los gráficos en Modo 0 son grandes, claros y deliberadamente
                caricaturescos. Pitu se reconoce al instante y la agencia mantiene
                una lectura limpia incluso cuando el caos alcanza cotas de comité.
                La música AY y los avisos sonoros completan una presentación muy
                cuidada para una producción nacional de 128K.
              </p>
            </div>

            <aside className="mm-verdict">
              <header><span>NUESTRO JOYSTICK</span><b>9</b></header>
              <div className="mm-score"><span>ADICCIÓN</span><i><b style={{ width: '90%' }}></b></i><strong>9</strong></div>
              <div className="mm-score"><span>GRÁFICOS</span><i><b style={{ width: '80%' }}></b></i><strong>8</strong></div>
              <div className="mm-score"><span>ORIGINALIDAD</span><i><b style={{ width: '100%' }}></b></i><strong>10</strong></div>
              <blockquote>
                «Una idea disparatada convertida en un arcade de persecución tan
                claro como adictivo. Pitu merece entregar la campaña.»
              </blockquote>
              <small>Texto: M. G. Guasa · Pantallas: Casa de la Guasa Software</small>
            </aside>
          </section>

          <section className="mm-playbook">
            <div className="mm-playbook-copy">
              <p>GUÍA DE SUPERVIVENCIA CREATIVA</p>
              <h3>CÓMO ENTREGAR SIN SER ENTREGADO</h3>
              <ol>
                <li><b>OBSERVA.</b><span>Localiza la pieza y estudia el recorrido de Alberto.</span></li>
                <li><b>PROVOCA.</b><span>Usa teléfonos y máquinas para fabricar una distracción.</span></li>
                <li><b>ESCÓNDETE.</b><span>Una mesa a tiempo vale más que diez reuniones.</span></li>
                <li><b>ENTREGA.</b><span>Reúne las doce piezas y afronta el pitch final.</span></li>
              </ol>
            </div>
            <div className="mm-review-notes">
              <div><h4>LO MEJOR</h4><p>Una mecánica de ruido y engaño muy original. Humor integrado en cada pantalla.</p></div>
              <div><h4>LO PEOR</h4><p>Alberto no entiende la expresión «mañana a primera hora».</p></div>
              <blockquote>CASA DE LA GUASA<br /><small>Del inglés: Banterhouse.</small></blockquote>
            </div>
          </section>

          <section className="mm-data-strip">
            <div><b>OBJETIVO</b><span>12 piezas · 10 plantas · 30 pantallas</span></div>
            <div><b>CONTROL</b><span>QAOP / Flechas · Espacio</span></div>
            <div><b>CARGA</b><span>RUN&quot;LOADER</span></div>
            <div className="mm-price"><span>CASSETTE</span><b>875 PTAS.</b></div>
            <div className="mm-price mm-price-disk"><span>DISCO 3&quot;</span><b>1.900 PTAS.</b></div>
          </section>

          <footer className="mm-page-footer"><i>RECREACIÓN EDITORIAL NO OFICIAL · 2026</i><span>MICROMANÍA · 25</span></footer>
        </article>
      </section>
    </main>
  );
}
