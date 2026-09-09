import type { Metadata } from "next";
import { Inter, Geist_Mono } from "next/font/google";
import "./globals.css";

const inter = Inter({ variable: "--font-inter", subsets: ["latin"] });
const geistMono = Geist_Mono({ variable: "--font-geist-mono", subsets: ["latin"] });

export const metadata: Metadata = {
  title: "PURGE — Remettre un PC Windows à zéro",
  description: "Le parcours Windows simple, guidé et lisible pour nettoyer complètement un ordinateur et revenir à l’écran de première configuration.",
  icons: {
    icon: "/icon.svg?v=2",
    shortcut: "/icon.svg?v=2",
  },
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="fr" className={`${inter.variable} ${geistMono.variable}`}><body>{children}</body></html>;
}
