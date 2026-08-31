'use client';

import { useEffect, useRef, useState } from 'react';

export default function EmulatorPlayer() {
  const shellRef = useRef<HTMLDivElement>(null);
  const [browserMode, setBrowserMode] = useState(false);
  const [fullscreen, setFullscreen] = useState(false);
  const [message, setMessage] = useState('');

  useEffect(() => {
    const handleFullscreenChange = () => {
      const active = document.fullscreenElement === shellRef.current;
      setFullscreen(active);
      if (active) setBrowserMode(false);
    };

    document.addEventListener('fullscreenchange', handleFullscreenChange);
    return () => document.removeEventListener('fullscreenchange', handleFullscreenChange);
  }, []);

  useEffect(() => {
    document.documentElement.classList.toggle('emulator-mode-open', browserMode);

    const handleEscape = (event: KeyboardEvent) => {
      if (event.key === 'Escape' && browserMode) setBrowserMode(false);
    };

    document.addEventListener('keydown', handleEscape);
    return () => {
      document.documentElement.classList.remove('emulator-mode-open');
      document.removeEventListener('keydown', handleEscape);
    };
  }, [browserMode]);

  async function toggleBrowserMode() {
    if (document.fullscreenElement) await document.exitFullscreen();
    setBrowserMode((active) => !active);
    setMessage('');
  }

  async function toggleFullscreen() {
    if (document.fullscreenElement) {
      await document.exitFullscreen();
      return;
    }

    try {
      await shellRef.current?.requestFullscreen({ navigationUI: 'hide' });
      setMessage('');
    } catch {
      setBrowserMode(true);
      setMessage('La pantalla completa no está disponible aquí. Se ha activado el modo navegador.');
    }
  }

  return (
    <div
      ref={shellRef}
      className={`emulator-shell${browserMode ? ' emulator-shell--browser' : ''}`}
    >
      <div className="emulator-toolbar">
        <div className="monitor-label">
          <span>BANTERHOUSE VISION · DISQUETTE 3&quot;</span>
          <i>EDICIÓN RECOMENDADA · 128K</i>
        </div>
        <div className="emulator-view-controls" aria-label="Tamaño del emulador">
          <button type="button" aria-pressed={browserMode} onClick={toggleBrowserMode}>
            <span aria-hidden="true">▣</span>
            {browserMode ? 'Salir del navegador' : 'Modo navegador'}
          </button>
          <button type="button" aria-pressed={fullscreen} onClick={toggleFullscreen}>
            <span aria-hidden="true">⛶</span>
            {fullscreen ? 'Salir de pantalla completa' : 'Pantalla completa'}
          </button>
        </div>
      </div>
      <p className="emulator-status" aria-live="polite">{message}</p>
      <iframe
        title="Emulador Amstrad CPC 6128 con Banterhouse"
        src="/emulator/?memory=128&diska=../release/banterhouse.dsk&autorun=LOADER.BAS&theme=Retro%20CRT&embed=1"
        allow="autoplay; fullscreen; gamepad"
        allowFullScreen
        loading="lazy"
      />
      <div className="monitor-controls" aria-hidden="true">
        <span>POWER</span><b></b><b></b><b></b><i>GT-65</i>
      </div>
    </div>
  );
}
