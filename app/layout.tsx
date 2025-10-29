import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  metadataBase: new URL('https://copichat.vercel.app'),
  title: 'CopiChat - 偉人・アーティストと会話するAIチャットボット | ジョブズ、アリストテレス、ダ・ヴィンチ、アインシュタイン、Avicii',
  description: 'CopiChatは歴史上の偉人や現代のイノベーターとリアルな対話ができるAI搭載チャットボットです。スティーブ・ジョブズ、アリストテレス、レオナルド・ダ・ヴィンチ、アルベルト・アインシュタイン、Aviciiと知的な会話を楽しめます。OpenAI GPT-4を使用した教育的体験をお試しください。',
  keywords: [
    'CopiChat', 'コピチャット', 'copichat app', 'copichat ai',
    'AI チャットボット', '歴史的人物', '対話AI', 'OpenAI GPT-4',
    'スティーブ・ジョブズ', 'Steve Jobs', 'Apple創設者',
    'アリストテレス', 'Aristotle', '古代ギリシャ哲学者',
    'レオナルド・ダ・ヴィンチ', 'Leonardo da Vinci', 'ルネサンス',
    'アルベルト・アインシュタイン', 'Albert Einstein', '相対性理論',
    'Avicii', 'アヴィーチー', 'Tim Bergling', 'Wake Me Up', 'Levels',
    'EDM', 'DJ', '音楽プロデューサー', 'Folktronica',
    'スタートアップ', 'AI・機械学習', 'ウェアラブルデバイス', '音楽制作',
    '教育アプリ', '学習ツール', '歴史学習', '哲学対話', 'ビジネス相談',
    'AI persona', 'historical figures chat', 'educational AI', 'music production'
  ],
  authors: [{ name: 'CopiChat Team' }],
  creator: 'CopiChat',
  publisher: 'CopiChat',
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      'max-video-preview': -1,
      'max-image-preview': 'large',
      'max-snippet': -1,
    },
  },
  openGraph: {
    type: 'website',
    locale: 'ja_JP',
    url: 'https://copichat.vercel.app',
    siteName: 'CopiChat',
    title: 'CopiChat - 偉人・アーティストと対話するAIチャットボット',
    description: 'ジョブズ、アリストテレス、ダ・ヴィンチ、アインシュタイン、AviciiとAIで会話。OpenAI GPT-4搭載の教育的チャットボット体験。',
    images: [
      {
        url: '/og-image.jpg',
        width: 1200,
        height: 630,
        alt: 'CopiChat - 歴史的人物との対話',
      },
    ],
  },
  twitter: {
    card: 'summary_large_image',
    title: 'CopiChat - 偉人・アーティストと対話するAI',
    description: 'ジョブズ、アリストテレス、ダ・ヴィンチ、アインシュタイン、AviciiとAIで対話。教育的チャットボット体験。',
    images: ['/og-image.jpg'],
    creator: '@copichat_ai',
  },
  verification: {
    google: 'your-google-verification-code-here',
  },
}

export function generateViewport() {
  return {
    width: 'device-width',
    initialScale: 1,
    maximumScale: 1,
  }
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="ja">
      <head>
        <link rel="canonical" href="https://copichat.vercel.app" />
        <meta name="application-name" content="CopiChat" />
        <meta name="apple-mobile-web-app-capable" content="yes" />
        <meta name="apple-mobile-web-app-status-bar-style" content="default" />
        <meta name="apple-mobile-web-app-title" content="CopiChat" />
        <meta name="format-detection" content="telephone=no" />
        <meta name="mobile-web-app-capable" content="yes" />
        <meta name="theme-color" content="#ffffff" />
        
        {/* JSON-LD構造化データ */}
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{
            __html: JSON.stringify({
              "@context": "https://schema.org",
              "@type": "WebApplication",
              "name": "CopiChat",
              "alternateName": ["コピチャット", "copichat app"],
              "description": "歴史上の偉人や現代のイノベーターと対話できるAI搭載チャットボット。スティーブ・ジョブズ、アリストテレス、レオナルド・ダ・ヴィンチ、アルベルト・アインシュタイン、Aviciiとの知的な会話が楽しめます。",
              "url": "https://copichat.vercel.app",
              "applicationCategory": "EducationalApplication",
              "operatingSystem": "Any",
              "offers": {
                "@type": "Offer",
                "price": "0",
                "priceCurrency": "JPY"
              },
              "creator": {
                "@type": "Organization",
                "name": "CopiChat Team"
              },
              "keywords": "CopiChat, AI チャットボット, 歴史的人物, スティーブ・ジョブズ, アリストテレス, ダ・ヴィンチ, アインシュタイン, Avicii, 起業家, DJ, 音楽プロデューサー, 教育アプリ, スタートアップ, EDM"
            })
          }}
        />
      </head>
      <body className={inter.className}>
        <div className="min-h-screen bg-gradient-to-br from-slate-50 to-blue-50">
          {children}
        </div>
      </body>
    </html>
  )
}