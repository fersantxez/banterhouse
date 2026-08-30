import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  metadataBase: new URL('https://banterhouse-128k.donatoexposito.chatgpt.site'),
  title: 'Banterhouse — La Gran Idea no se entrega. Se sobrevive.',
  description: 'Un juego de persecución, puzles y publicidad para Amstrad CPC 6128.',
  openGraph: {
    title: 'Banterhouse — La Gran Idea no se entrega. Se sobrevive.',
    description: 'Pitu contra Alberto Pérez del Briefing en la Casa de la Guasa. Juega online o descarga la edición completa para Amstrad CPC 6128.',
    type: 'website',
    locale: 'es_ES',
    images: [{
      url: 'https://banterhouse-128k.donatoexposito.chatgpt.site/og.png',
      width: 1733,
      height: 907,
      alt: 'Banterhouse: La Gran Idea no se entrega. Se sobrevive.',
    }],
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Banterhouse — La Gran Idea no se entrega. Se sobrevive.',
    description: 'Un videojuego de caos publicitario para Amstrad CPC 6128.',
    images: ['https://banterhouse-128k.donatoexposito.chatgpt.site/og.png'],
  },
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="es">
      <body>{children}</body>
    </html>
  );
}
