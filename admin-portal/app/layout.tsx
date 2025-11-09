import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'Tiraz Admin Portal',
  description: 'Admin portal for Tiraz AI tailoring platform',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className="font-sans antialiased">{children}</body>
    </html>
  )
}
