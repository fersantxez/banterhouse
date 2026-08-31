import { createHash } from 'node:crypto';
import { existsSync, readFileSync, readdirSync, statSync } from 'node:fs';
import { extname, join } from 'node:path';
import { spawnSync } from 'node:child_process';

const root = process.cwd();
const appDir = join(root, 'app');
const publicDir = join(root, 'public');
const releaseDir = join(publicDir, 'release');
const errors = [];

function walk(directory) {
  return readdirSync(directory, { withFileTypes: true }).flatMap((entry) => {
    const path = join(directory, entry.name);
    return entry.isDirectory() ? walk(path) : [path];
  });
}

function check(condition, message) {
  if (!condition) errors.push(message);
}

function sha256(buffer) {
  return createHash('sha256').update(buffer).digest('hex');
}

const sourceFiles = walk(appDir).filter((path) => ['.tsx', '.ts', '.css'].includes(extname(path)));
const publicTextFiles = walk(releaseDir).filter((path) => ['.html', '.txt'].includes(extname(path)));
const publicCopy = [...sourceFiles, ...publicTextFiles]
  .map((path) => readFileSync(path, 'utf8'))
  .join('\n');

const forbiddenPublicCopy = [
  /parte de producci[oó]n/i,
  /classic terminada/i,
  /expanded(?:\s+lab|\s+en\s+el\s+laboratorio|\s+en\s+laboratorio)/i,
  /informe t[eé]cnico/i,
  /identidad del build/i,
  /trabajo pendiente/i,
];

for (const pattern of forbiddenPublicCopy) {
  check(!pattern.test(publicCopy), `El contenido público contiene texto interno: ${pattern}`);
}

check(!existsSync(join(releaseDir, 'screenshots', 'expanded-lab.png')), 'La captura interna expanded-lab.png no debe publicarse.');

const page = readFileSync(join(appDir, 'page.tsx'), 'utf8');
check(page.includes('src="/release/banterhouse-disk-inlay.png"'), 'El hero debe presentar la edición DSK recomendada.');
check(page.includes('Jugar DSK ahora'), 'La acción principal debe lanzar la edición DSK.');
check(page.indexOf('release-dsk') < page.indexOf('release-cassette'), 'La edición DSK debe aparecer antes que cassette.');
check(page.includes('src="/emulator/?memory=128&diska=../release/banterhouse.dsk'), 'El emulador debe montar la edición DSK.');

const ids = new Set([...page.matchAll(/\bid="([^"]+)"/g)].map((match) => match[1]));
for (const match of page.matchAll(/href="#([^"]+)"/g)) {
  check(ids.has(match[1]), `El enlace #${match[1]} no tiene un destino con id equivalente.`);
}

const assetReferences = new Set();
for (const source of sourceFiles.filter((path) => extname(path) === '.tsx').map((path) => readFileSync(path, 'utf8'))) {
  for (const match of source.matchAll(/(?:href|src)=["'](\/[^"'#?]*)[^"']*["']/g)) assetReferences.add(match[1]);
  for (const match of source.matchAll(/\bsrc:\s*["'](\/[^"'?]*)[^"']*["']/g)) assetReferences.add(match[1]);
}

for (const reference of assetReferences) {
  let path = join(publicDir, reference);
  if (reference.endsWith('/')) path = join(path, 'index.html');
  check(existsSync(path) && statSync(path).isFile(), `Falta el recurso público ${reference}.`);
}

const requiredFiles = [
  'banterhouse.dsk',
  'banterhouse.cdt',
  'banterhouse-release.zip',
  'banterhouse-disk-inlay.png',
  'banterhouse-cassette-inlay.png',
  'banterhouse-manual.pdf',
  'banterhouse-micromania-article.pdf',
];
for (const filename of requiredFiles) {
  const path = join(releaseDir, filename);
  check(existsSync(path) && statSync(path).size > 1024, `${filename} falta o está vacío.`);
}

const png = readFileSync(join(releaseDir, 'banterhouse-disk-inlay.png'));
check(png.subarray(0, 8).equals(Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a])), 'La carátula DSK no es un PNG válido.');
const pdf = readFileSync(join(releaseDir, 'banterhouse-micromania-article.pdf'));
check(pdf.subarray(0, 5).toString() === '%PDF-', 'El artículo descargable no es un PDF válido.');
const manualPdf = readFileSync(join(releaseDir, 'banterhouse-manual.pdf'));
check(manualPdf.subarray(0, 5).toString() === '%PDF-', 'El manual descargable no es un PDF válido.');

const archive = join(releaseDir, 'banterhouse-release.zip');
for (const format of ['dsk', 'cdt']) {
  const archived = spawnSync('unzip', ['-p', archive, `banterhouse-release/game/banterhouse.${format}`], { maxBuffer: 8 * 1024 * 1024 });
  check(archived.status === 0, `El ZIP no contiene banterhouse.${format}.`);
  if (archived.status === 0) {
    const direct = readFileSync(join(releaseDir, `banterhouse.${format}`));
    check(sha256(archived.stdout) === sha256(direct), `banterhouse.${format} no coincide entre la descarga directa y el ZIP.`);
  }
}

const archivedReadme = spawnSync('unzip', ['-p', archive, 'banterhouse-release/README.txt'], { encoding: 'utf8' });
check(archivedReadme.status === 0, 'El ZIP no contiene README.txt.');
if (archivedReadme.status === 0) {
  for (const pattern of forbiddenPublicCopy) {
    check(!pattern.test(archivedReadme.stdout), `El README del ZIP contiene texto interno: ${pattern}`);
  }
}

const archivedManual = spawnSync('unzip', ['-p', archive, 'banterhouse-release/manual/banterhouse-manual.pdf'], { maxBuffer: 8 * 1024 * 1024 });
check(archivedManual.status === 0, 'El ZIP no contiene el manual de usuario.');
if (archivedManual.status === 0) {
  check(sha256(archivedManual.stdout) === sha256(manualPdf), 'El manual no coincide entre la descarga directa y el ZIP.');
}

check(existsSync(join(publicDir, 'emulator', 'index.html')), 'Falta la entrada del emulador web.');
check(walk(join(publicDir, 'emulator')).some((path) => path.endsWith('.wasm')), 'Falta el binario WASM del emulador.');

if (errors.length) {
  console.error(errors.map((error) => `✗ ${error}`).join('\n'));
  process.exit(1);
}

console.log(`✓ Sitio público validado: ${assetReferences.size} recursos, descargas DSK/CDT sincronizadas y contenido interno ausente.`);
