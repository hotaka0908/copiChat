# DTalk - 歴史的人物との対話チャットボット

[![Vercel](https://img.shields.io/badge/deployed%20on-Vercel-black)](https://vercel.com)
[![Next.js](https://img.shields.io/badge/Next.js-15-black)](https://nextjs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.6-blue)](https://www.typescriptlang.org/)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

DTalkは、AI技術を使用して歴史上の偉人たちの思考パターンと人格を再現し、ユーザーが彼らと実際に会話しているような体験を提供するWebアプリケーションです。

## 🌟 特徴

- **本格的な人格再現**: 各歴史的人物の思考パターン、価値観、話し方を忠実に再現
- **直感的なUI**: クリーンで使いやすいモダンなインターフェース
- **レスポンシブデザイン**: PC、タブレット、スマートフォンに対応
- **高品質なAI**: OpenAI GPT-4o-miniによる自然で知的な対話
- **美しいアニメーション**: Framer Motionによるスムーズなユーザー体験
- **エンタープライズグレードのセキュリティ**: CORS制限、セキュリティヘッダー、環境変数保護

## 🎭 対話可能な歴史的人物（全10名）

### スティーブ・ジョブズ (1955-2011)
- **専門分野**: 製品デザイン、ユーザーエクスペリエンス、イノベーション戦略
- **特徴**: 完璧主義、シンプルさへの追求、革新的思考
- **有名な言葉**: "Stay hungry, stay foolish"

### アリストテレス (BC384-BC322)
- **専門分野**: 論理学、倫理学、政治学、形而上学
- **特徴**: 論理的思考、中庸の精神、万学への精通
- **有名な言葉**: "人間は社会的動物である"

### レオナルド・ダ・ヴィンチ (1452-1519)
- **専門分野**: 絵画、発明、解剖学、工学
- **特徴**: 芸術と科学の融合、飽くなき好奇心
- **有名な言葉**: "シンプルさは究極の洗練である"

### アルベルト・アインシュタイン (1879-1955)
- **専門分野**: 理論物理学、相対性理論、科学哲学
- **特徴**: 想像力重視、平和主義、深い洞察力
- **有名な言葉**: "想像力は知識より重要である"

### 船橋穂天 (1996-)
- **専門分野**: AI・機械学習、スタートアップ経営、投資戦略
- **特徴**: データドリブン、ポジティブ思考、継続的学習
- **有名な言葉**: "人々の生活をより良くする世界一の会社を創る"

### Avicii (1989-2018)
- **専門分野**: EDMプロデュース、音楽制作、ジャンル融合
- **特徴**: 革新的、完璧主義、感情的深さ
- **有名な言葉**: "I'm a producer, not a DJ"

### マザー・テレサ (1910-1997)
- **専門分野**: 慈善活動、スピリチュアルケア、貧困者支援
- **特徴**: 無条件の愛、献身、平和への祈り
- **有名な言葉**: "We can do small things with great love"

### ジョン・レノン (1940-1980)
- **専門分野**: ロック音楽、平和運動、社会批判
- **特徴**: 平和主義、反権威主義、芸術的革新
- **有名な言葉**: "Imagine all the people living life in peace"

### 長嶋茂雄 (1936-)
- **専門分野**: 野球技術指導、チームビルディング、モチベーション向上
- **特徴**: 明るく前向き、感覚派の天才、エンターテイナー精神
- **有名な言葉**: "野球は楽しくやるもんだよ"

### アラン・チューリング (1912-1954)
- **専門分野**: 計算機科学、暗号解読、人工知能理論
- **特徴**: 論理的思考、独創的発想、数学的厳密性
- **有名な言葉**: "Can machines think?"

## 🚀 はじめ方

### 1. 環境設定

```bash
# プロジェクトディレクトリに移動
cd dtalk

# 依存関係をインストール
npm install
```

### 2. 環境変数の設定

`.env.local` ファイルを作成し、以下の環境変数を設定してください：

```env
# OpenAI Configuration
OPENAI_API_KEY=your_openai_api_key_here

# Supabase Configuration (オプション)
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url_here
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key_here
```

### 3. 開発サーバーの起動

```bash
npm run dev
```

ブラウザで `http://localhost:3000` を開いてDTalkをお楽しみください。

## 🛠️ 技術スタック

- **フレームワーク**: Next.js 15 (App Router)
- **言語**: TypeScript 5.6
- **スタイリング**: Tailwind CSS
- **AI**: OpenAI GPT-4o-mini API
- **アニメーション**: Framer Motion
- **アイコン**: Lucide React
- **デプロイ**: Vercel
- **セキュリティ**: カスタムミドルウェア、CORS制限、CSP

## 📁 プロジェクト構造

```
dtalk/
├── app/                      # Next.js App Router
│   ├── page.tsx             # ホームページ（人物選択）
│   ├── chat/[personaId]/    # チャット画面
│   ├── api/
│   │   ├── chat/            # メインチャットAPI
│   │   ├── test/            # APIテストエンドポイント
│   │   └── test-openai/     # OpenAI接続テスト
│   ├── layout.tsx           # レイアウト
│   └── globals.css          # グローバルスタイル
├── lib/                     # ライブラリとユーティリティ
│   ├── personas.ts          # 人物データベース（10人物）
│   ├── ai.ts                # OpenAI API 連携
│   └── security.ts          # セキュリティユーティリティ
├── middleware.ts            # Edge Middleware（セキュリティ）
├── public/                  # 静的ファイル
├── vercel.json              # Vercel設定
├── SECURITY.md              # セキュリティドキュメント
├── VERCEL_DEPLOYMENT.md     # デプロイ手順
└── README.md                # このファイル
```

## 🎯 使用方法

1. **人物選択**: ホームページで対話したい歴史的人物を選択
2. **対話開始**: 選択した人物とのチャット画面が開きます
3. **質問入力**: テキストエリアに質問や話したい内容を入力
4. **Enterで送信**: Enterキーまたは送信ボタンでメッセージを送信
5. **AI応答**: その人物の特徴を再現したAIが応答します

## 💡 カスタマイズ

### 新しい人物の追加

`lib/personas.ts` ファイルに新しい人物データを追加できます：

```typescript
"new-persona": {
  id: "new-persona",
  name: "新しい人物",
  nameEn: "New Persona",
  era: "生年-没年",
  title: "肩書き",
  // ... その他の設定
}
```

### UI テーマのカスタマイズ

Tailwind CSSクラスを編集して、カラーテーマやレイアウトを変更できます。

## 🔧 開発コマンド

```bash
# 開発サーバー起動
npm run dev

# プロダクションビルド
npm run build

# プロダクションサーバー起動
npm run start

# 型チェック
npm run type-check

# Lintチェック
npm run lint
```

## 🚀 Vercelへのデプロイ

### クイックスタート

1. **GitHubリポジトリをVercelにインポート**
   ```
   https://vercel.com → New Project → Import from GitHub
   ```

2. **環境変数を設定**（Vercel Dashboard）
   ```
   OPENAI_API_KEY=sk-your-actual-key
   NEXT_PUBLIC_APP_URL=https://your-app.vercel.app
   ```

3. **デプロイ** - 自動的にビルド＆デプロイ完了！

📖 **詳細な手順**: [VERCEL_DEPLOYMENT.md](./VERCEL_DEPLOYMENT.md) を参照

## 🔒 セキュリティ

DTalkは本番環境レベルのセキュリティ対策を実装しています：

- ✅ **CORS制限**: 許可されたオリジンのみアクセス可能
- ✅ **セキュリティヘッダー**: CSP, X-Frame-Options, HSTS等
- ✅ **環境変数保護**: APIキーの適切な管理
- ✅ **入力検証**: 全APIエンドポイントで実施
- ✅ **依存関係監査**: 脆弱性ゼロを維持

📖 **詳細**: [SECURITY.md](./SECURITY.md) を参照

## 🧪 テスト済み

- ✅ TypeScript型チェック完了
- ✅ プロダクションビルド成功
- ✅ セキュリティ監査合格（脆弱性: 0件）
- ✅ APIエンドポイント動作確認済み
- ✅ Vercel本番環境互換性確認済み

📊 **詳細レポート**: [TEST_REPORT.md](./TEST_REPORT.md)

## 📈 今後の予定

- [ ] 会話履歴の保存機能
- [ ] お気に入りメッセージのブックマーク
- [ ] 多言語対応（英語、中国語等）
- [ ] 音声対話機能
- [ ] より多くの歴史的人物の追加
- [ ] ユーザー認証とプロフィール機能

## 🤝 貢献

プロジェクトへの貢献を歓迎します！バグ報告、機能提案、プルリクエストなど、お気軽にお寄せください。

## 📄 ライセンス

このプロジェクトはMITライセンスの下で公開されています。

## 🙏 謝辞

- OpenAI GPT-4の素晴らしいAI技術
- Next.js、Tailwind CSS、Framer Motionの優れたフレームワーク
- 歴史的人物たちの偉大な業績と知恵

---

**注意**: このアプリケーションはAI技術を使用した歴史的人物の再現であり、実際の人物の意見や考えを完全に代表するものではありません。教育や娯楽目的での使用を前提としています。