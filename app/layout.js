import "./globals.css";

export const metadata = {
  title: "Christoph Rump – Lucid dreaming workshops and retreats",
  description:
    "Lucid dreaming workshops, retreats and courses with certified facilitator Christoph Rump: mindful day and night routines for calmer days and more conscious nights.",
};

export const viewport = { width: "device-width", initialScale: 1, viewportFit: "cover" };

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <head>
        {/* Same Google Fonts link as the original page (see docs/NOTES.md: privacy) */}
        <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Bricolage+Grotesque:opsz,wght@12..96,400..800&family=Newsreader:opsz,wght@6..72,400..600&display=swap" />
      </head>
      <body>{children}</body>
    </html>
  );
}
