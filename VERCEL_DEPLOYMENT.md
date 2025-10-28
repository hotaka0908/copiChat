# Vercel デプロイメントガイド

このガイドでは、CopiChatアプリケーションをVercelにデプロイする手順を説明します。

---

## ✅ Vercel互換性確認済み

CopiChatは以下の点でVercel本番環境に完全対応しています：

- ✅ Next.js 15 App Router（Vercel最適化済み）
- ✅ Serverless Functions（APIルート）
- ✅ Edge Middleware（セキュリティヘッダー）
- ✅ 環境変数の自動検出（`VERCEL_URL`）
- ✅ TypeScript完全サポート
- ✅ プレビューデプロイメント対応

---

## 🚀 デプロイ方法

### 方法1: GitHub連携（推奨）

1. **GitHubリポジトリをpublicに設定**
   ```bash
   # GitHubのリポジトリ設定から
   Settings > General > Danger Zone > Change visibility > Public
   ```

2. **Vercelにログイン**
   - https://vercel.com にアクセス
   - GitHubアカウントで認証

3. **新規プロジェクトを作成**
   - 「Add New...」→「Project」
   - GitHubリポジトリ `hotaka0908/copichat` を選択
   - 「Import」をクリック

4. **環境変数を設定**

   **必須の環境変数:**
   ```
   OPENAI_API_KEY=sk-your-actual-openai-api-key-here
   ```

   **推奨の環境変数:**
   ```
   NEXT_PUBLIC_APP_URL=https://your-project-name.vercel.app
   ```

   > **注意:** デプロイ後にVercelから提供されるURLを確認してから、`NEXT_PUBLIC_APP_URL`を設定し直すことをお勧めします。

5. **デプロイ実行**
   - 「Deploy」ボタンをクリック
   - ビルドログを確認
   - デプロイ完了を待つ（通常1-3分）

6. **動作確認**
   ```bash
   # 提供されたURLにアクセス
   https://your-project-name.vercel.app

   # APIテスト
   curl https://your-project-name.vercel.app/api/test
   ```

---

### 方法2: Vercel CLI

1. **Vercel CLIをインストール**
   ```bash
   npm i -g vercel
   ```

2. **ログイン**
   ```bash
   vercel login
   ```

3. **環境変数を設定**
   ```bash
   # プロダクション環境変数
   vercel env add OPENAI_API_KEY production
   # プロンプトに従ってAPIキーを入力

   # プレビュー環境変数（オプション）
   vercel env add OPENAI_API_KEY preview
   ```

4. **デプロイ**
   ```bash
   # プレビューデプロイ
   vercel

   # 本番デプロイ
   vercel --prod
   ```

---

## 🔧 環境変数の詳細設定

### Vercel Dashboard での設定方法

1. プロジェクトを選択
2. 「Settings」→「Environment Variables」
3. 以下の変数を追加:

| 変数名 | 値 | 環境 | 説明 |
|--------|-----|------|------|
| `OPENAI_API_KEY` | `sk-...` | Production, Preview, Development | OpenAI APIキー（必須） |
| `NEXT_PUBLIC_APP_URL` | `https://copichat.vercel.app` | Production | 本番ドメイン（CORS用） |

### 自動設定される環境変数

Vercelが自動的に設定する変数（設定不要）:

- `VERCEL=1` - Vercel環境であることを示す
- `VERCEL_URL` - デプロイメントのURL（プロトコルなし）
- `VERCEL_ENV` - 環境（production/preview/development）
- `NODE_ENV` - Node.js環境（production/development）

---

## 📝 デプロイ後の確認事項

### 1. ビルドログの確認

デプロイ後、Vercel Dashboardで以下を確認:

```
✓ Compiled successfully
✓ Linting and checking validity of types
✓ Collecting page data
✓ Generating static pages
✓ Finalizing page optimization
```

### 2. 動作テスト

```bash
# 基本動作確認
curl https://your-app.vercel.app/api/test

# レスポンス例
{
  "status": "success",
  "message": "API is working",
  "environment": "production",
  "timestamp": "2025-10-08T..."
}
```

### 3. セキュリティヘッダーの確認

```bash
curl -I https://your-app.vercel.app/api/test
```

以下のヘッダーが含まれていることを確認:
```
strict-transport-security: max-age=63072000; includeSubDomains; preload
x-content-type-options: nosniff
x-frame-options: DENY
x-xss-protection: 1; mode=block
content-security-policy: ...
access-control-allow-origin: https://your-app.vercel.app
```

### 4. OpenAI API接続テスト

```bash
curl https://your-app.vercel.app/api/test-openai
```

成功時のレスポンス:
```json
{
  "status": "success",
  "message": "OpenAI API connection working",
  "testResponse": "こんにちは！...",
  "model": "gpt-4o-mini"
}
```

---

## 🔄 継続的デプロイメント

GitHubと連携している場合、以下の動作が自動化されます:

### プレビューデプロイ
```bash
# 新しいブランチにプッシュ
git checkout -b feature/new-feature
git push origin feature/new-feature

# 自動的にプレビューURLが生成される
# https://copichat-xxx-username.vercel.app
```

### 本番デプロイ
```bash
# mainブランチにマージ
git checkout main
git merge feature/new-feature
git push origin main

# 自動的に本番環境にデプロイされる
# https://copichat.vercel.app
```

---

## ⚙️ Vercel設定ファイル

プロジェクトには `vercel.json` が含まれています:

```json
{
  "framework": "nextjs",
  "regions": ["hnd1"],  // 東京リージョン
  "buildCommand": "npm run build",
  "env": {
    "OPENAI_API_KEY": "@openai-api-key"
  },
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {
          "key": "Strict-Transport-Security",
          "value": "max-age=63072000; includeSubDomains; preload"
        }
      ]
    }
  ]
}
```

---

## 🌍 カスタムドメインの設定

1. **Vercel Dashboardでドメイン追加**
   - プロジェクト > Settings > Domains
   - カスタムドメインを入力（例: `copichat.example.com`）

2. **DNS設定**
   - ドメインレジストラでCNAMEレコードを追加
   ```
   Type: CNAME
   Name: copichat (またはサブドメイン)
   Value: cname.vercel-dns.com
   ```

3. **環境変数を更新**
   ```
   NEXT_PUBLIC_APP_URL=https://copichat.example.com
   ```

4. **SSL証明書**
   - Vercelが自動的にLet's Encryptを使用してSSL証明書を発行

---

## 🐛 トラブルシューティング

### ビルドエラー: "OPENAI_API_KEY is missing"

**原因:** 環境変数が設定されていない

**解決方法:**
1. Vercel Dashboard > Settings > Environment Variables
2. `OPENAI_API_KEY` を追加
3. 再デプロイ

### CORS エラー

**原因:** `NEXT_PUBLIC_APP_URL` が正しく設定されていない

**解決方法:**
1. 実際のVercel URLを確認（例: `https://copichat-abc123.vercel.app`）
2. 環境変数に設定:
   ```
   NEXT_PUBLIC_APP_URL=https://copichat-abc123.vercel.app
   ```
3. 再デプロイ

### 関数タイムアウト

**原因:** OpenAI APIのレスポンスが遅い

**解決方法:**
Vercel Proプランにアップグレード（60秒のタイムアウト）
または
`next.config.js`で設定:
```javascript
module.exports = {
  experimental: {
    serverActions: {
      bodySizeLimit: '2mb',
    },
  },
}
```

---

## 📊 パフォーマンス最適化

### 1. Edge Functions（将来的な改善）

現在はServerless Functionsを使用していますが、将来的にEdge Functionsへの移行を検討:

```typescript
// app/api/chat/route.ts
export const runtime = 'edge'; // Edge Functionsに変更
```

### 2. キャッシング戦略

静的アセットは自動的にCDNでキャッシュされます。

### 3. リージョン設定

`vercel.json` で東京リージョン（hnd1）を指定済み:
```json
{
  "regions": ["hnd1"]
}
```

---

## 🔒 セキュリティチェックリスト

デプロイ前に確認:

- [x] `OPENAI_API_KEY` が環境変数に設定されている
- [x] `.env.local` がGitに含まれていない
- [x] `NEXT_PUBLIC_APP_URL` が正しく設定されている
- [x] HTTPS が有効になっている
- [x] セキュリティヘッダーが適用されている
- [x] CORS制限が機能している

---

## 📈 モニタリング

### Vercel Analytics

1. プロジェクト > Analytics タブ
2. 以下のメトリクスを確認:
   - リクエスト数
   - レスポンスタイム
   - エラー率
   - 帯域幅使用量

### ログの確認

```bash
# Vercel CLI でログ確認
vercel logs
vercel logs --follow  # リアルタイム
```

---

## 💰 コスト見積もり

### Vercel Hobby（無料プラン）
- **価格:** $0/月
- **制限:**
  - 100 GB 帯域幅
  - Serverless Function実行時間: 100時間/月
  - 1つのチーム

CopiChatの想定使用量（月間1000ユーザー）:
- 帯域幅: ~10 GB
- 関数実行時間: ~5時間
- **結論:** 無料プランで十分

### Vercel Pro（必要に応じて）
- **価格:** $20/月
- **追加機能:**
  - 1 TB 帯域幅
  - Serverless Function実行時間: 1000時間/月
  - パフォーマンス分析
  - パスワード保護

---

## 🎉 まとめ

CopiChatは以下の理由でVercelに最適化されています:

1. ✅ **Next.js 15 完全対応** - Vercelのネイティブフレームワーク
2. ✅ **自動スケーリング** - トラフィック増加に自動対応
3. ✅ **グローバルCDN** - 世界中で高速アクセス
4. ✅ **ゼロ設定デプロイ** - git push だけでデプロイ完了
5. ✅ **セキュリティ最適化** - HTTPS、ヘッダー、CORS完備

**次のステップ:** GitHubリポジトリをVercelに接続してデプロイしましょう！

---

**サポート:**
- Vercel Documentation: https://vercel.com/docs
- Next.js on Vercel: https://vercel.com/docs/frameworks/nextjs
- 問題が発生した場合: GitHub Issues に報告してください
