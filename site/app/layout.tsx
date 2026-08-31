import type { Metadata, Viewport } from 'next';
import './globals.css';

export const viewport: Viewport = {
  width: 'device-width',
  initialScale: 1,
  viewportFit: 'cover',
  themeColor: '#12110f',
};

export const metadata: Metadata = {
  metadataBase: new URL('https://banterhouse-128k.donatoexposito.chatgpt.site'),
  title: 'Banterhouse — La Gran Idea no se entrega. Se sobrevive.',
  description: 'Juega online o descarga la edición Disquette 3 pulgadas recomendada de Banterhouse para Amstrad CPC 6128.',
  alternates: {
    canonical: '/',
  },
  robots: {
    index: true,
    follow: true,
  },
  openGraph: {
    title: 'Banterhouse — La Gran Idea no se entrega. Se sobrevive.',
    description: 'Pitu contra Alberto Pérez del Briefing en la Casa de la Guasa. Juega online o descarga Banterhouse para Amstrad CPC 6128.',
    url: '/',
    siteName: 'Banterhouse',
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
