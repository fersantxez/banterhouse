import { defineConfig, globalIgnores } from 'eslint/config';
import nextVitals from 'eslint-config-next/core-web-vitals';
import nextTs from 'eslint-config-next/typescript';

const eslintConfig = defineConfig([
  ...nextVitals,
  ...nextTs,
  {
    // The art direction depends on exact intrinsic raster dimensions and
    // pixelated scaling. These static assets do not benefit from optimization.
    rules: { '@next/next/no-img-element': 'off' },
  },
  // `public/emulator` is the vendored Emscripten build of 1984. Validate the
  // application shell, but do not reinterpret generated third-party JS as TS.
  globalIgnores(['.next/**', 'dist/**', 'out/**', 'build/**', 'public/emulator/**', 'next-env.d.ts']),
]);

export default eslintConfig;
