#!/usr/bin/env node

const fs = require('fs');

const source = fs.readFileSync('src/graphics.c', 'utf8');
const liveFrames = ['g_pitu', 'g_pitu_walk'];

function decodeLeft(byte) {
  return ((byte >> 7) & 1) |
         ((byte >> 2) & 2) |
         ((byte >> 3) & 4) |
         ((byte << 2) & 8);
}

function decodeRight(byte) {
  return ((byte >> 6) & 1) |
         ((byte >> 1) & 2) |
         ((byte >> 2) & 4) |
         ((byte << 3) & 8);
}

for (const name of liveFrames) {
  const match = source.match(new RegExp(
    `const unsigned char ${name}\\[512\\]\\s*=\\s*\\{([\\s\\S]*?)\\};`
  ));
  if (!match) throw new Error(`Missing Pitu frame: ${name}`);

  const bytes = [...match[1].matchAll(/0x([0-9A-Fa-f]{2})/g)]
    .map((entry) => parseInt(entry[1], 16));
  if (bytes.length !== 512) {
    throw new Error(`${name} has ${bytes.length} bytes instead of 512`);
  }

  const pens = new Set();
  for (let offset = 0; offset < bytes.length; offset += 2) {
    const mask = bytes[offset];
    const data = bytes[offset + 1];
    const y = Math.floor(offset / 16);
    const masks = [decodeLeft(mask), decodeRight(mask)];
    const pixels = [decodeLeft(data), decodeRight(data)];

    for (let pixel = 0; pixel < 2; ++pixel) {
      if (masks[pixel] === 15) continue;
      const pen = pixels[pixel];
      pens.add(pen);
      if (y >= 24 && pen === 10) {
        throw new Error(`${name} still has a magenta shoe pixel at row ${y}`);
      }
    }
  }

  for (const obsolete of [6, 7, 11]) {
    if (pens.has(obsolete)) {
      throw new Error(`${name} still uses obsolete Pitu pen ${obsolete}`);
    }
  }
  for (const canonical of [4, 14]) {
    if (!pens.has(canonical)) {
      throw new Error(`${name} does not use canonical Pitu pen ${canonical}`);
    }
  }
}

process.stdout.write('Pitu palette checks: PASS\n');
