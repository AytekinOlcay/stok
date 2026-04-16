import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import Link from "next/link";
import "./globals.css";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "Freezer Inventory",
  description: "QR-based freezer inventory management system",
};

const navItems = [
  { href: "/dashboard", label: "📊 Dashboard" },
  { href: "/products", label: "🥩 Products" },
  { href: "/shelves", label: "🗄️ Shelves" },
  { href: "/logs", label: "📋 Logs" },
  { href: "/statistics", label: "📈 Statistics" },
];

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html
      lang="en"
      className={`${geistSans.variable} ${geistMono.variable} h-full antialiased`}
    >
      <body className="min-h-full flex">
        <aside className="w-56 shrink-0 border-r bg-muted/30 flex flex-col">
          <div className="px-4 py-5 border-b">
            <span className="font-bold text-lg">❄️ Freezer App</span>
          </div>
          <nav className="flex-1 px-2 py-4 space-y-1">
            {navItems.map((item) => (
              <Link
                key={item.href}
                href={item.href}
                className="flex items-center gap-2 rounded-md px-3 py-2 text-sm font-medium hover:bg-accent hover:text-accent-foreground transition-colors"
              >
                {item.label}
              </Link>
            ))}
          </nav>
        </aside>
        <main className="flex-1 overflow-auto">{children}</main>
      </body>
    </html>
  );
}
