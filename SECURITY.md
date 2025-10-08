# セキュリティガイド

このドキュメントでは、DTalkアプリケーションに実装されているセキュリティ機能について説明します。

## 🔒 実装済みセキュリティ機能

### 1. CORS（Cross-Origin Resource Sharing）制限

**概要:**
不正なドメインからのAPIアクセスを防ぐため、許可されたオリジンのみAPIにアクセス可能です。

**設定方法:**
```bash
# .env.local ファイル
NEXT_PUBLIC_APP_URL=https://yourdomain.com
```

**自動許可されるオリジン:**
- 開発環境: `http://localhost:3000`, `http://127.0.0.1:3000`
- 本番環境: `NEXT_PUBLIC_APP_URL` で設定したドメイン
- Vercel: `*.vercel.app` ドメイン（プレビューデプロイメント対応）

**実装場所:**
- `lib/security.ts` - CORS制御ロジック
- `app/api/chat/route.ts` - APIエンドポイント

### 2. セキュリティヘッダー

以下のHTTPセキュリティヘッダーを全ページに適用:

#### X-Content-Type-Options
```
X-Content-Type-Options: nosniff
```
MIMEタイプのスニッフィングを防止

#### X-Frame-Options
```
X-Frame-Options: DENY
```
クリックジャッキング攻撃を防止（iframeへの埋め込みを禁止）

#### X-XSS-Protection
```
X-XSS-Protection: 1; mode=block
```
XSS攻撃の基本的な保護

#### Content-Security-Policy (CSP)
```
Content-Security-Policy: default-src 'self'; script-src 'self' 'unsafe-eval' 'unsafe-inline'; ...
```
コンテンツの読み込み元を制限し、XSS攻撃を防止

#### Referrer-Policy
```
Referrer-Policy: strict-origin-when-cross-origin
```
リファラー情報の漏洩を制限

#### Permissions-Policy
```
Permissions-Policy: camera=(), microphone=(), geolocation=(), payment=()
```
不要なブラウザ機能へのアクセスを無効化

#### Strict-Transport-Security (本番環境のみ)
```
Strict-Transport-Security: max-age=63072000; includeSubDomains; preload
```
HTTPS通信を強制

**実装場所:**
- `middleware.ts` - 全ページ共通
- `lib/security.ts` - APIレスポンス用

### 3. 環境変数の保護

**保護対象:**
- `OPENAI_API_KEY` - OpenAI APIキー
- その他の機密情報

**保護方法:**
- `.gitignore` で `.env*.local` を除外
- `.env.local.example` にはプレースホルダーのみ記載
- サーバーサイドでのみAPIキーを使用（クライアントに露出しない）

### 4. 入力検証

**APIエンドポイントでの検証:**
- メッセージ長の制限（最大8000文字）
- 空メッセージのチェック
- データ型の検証
- 必須パラメータの存在確認

**実装場所:**
- `lib/ai.ts` - `validateMessage()` 関数
- `app/api/chat/route.ts` - リクエストバリデーション

### 5. エラーハンドリング

**セキュアなエラーレスポンス:**
- 詳細なエラー情報はログのみに出力
- クライアントには一般的なエラーメッセージのみ返却
- スタックトレースの非公開

## 🚀 本番環境へのデプロイ

### Vercelへのデプロイ手順

1. **環境変数の設定**
   ```
   Vercel Dashboard > Settings > Environment Variables
   ```
   以下を設定:
   - `OPENAI_API_KEY`: OpenAI APIキー
   - `NEXT_PUBLIC_APP_URL`: 本番ドメイン（例: https://dtalk.vercel.app）

2. **HTTPS の確認**
   - Vercelは自動的にHTTPS化されます
   - カスタムドメインを使用する場合もHTTPSが適用されます

3. **デプロイ**
   ```bash
   # Vercel CLIを使用
   npm i -g vercel
   vercel --prod
   ```

### セキュリティチェックリスト

デプロイ前に以下を確認してください:

- [ ] `.env.local` がGitに含まれていない
- [ ] `OPENAI_API_KEY` が環境変数に正しく設定されている
- [ ] `NEXT_PUBLIC_APP_URL` が本番ドメインに設定されている
- [ ] HTTPSが有効になっている
- [ ] デバッグログが本番環境で無効化されている

## 🔍 セキュリティ監査

### 定期的に確認すべき項目

1. **依存パッケージの脆弱性チェック**
   ```bash
   npm audit
   npm audit fix
   ```

2. **環境変数の漏洩チェック**
   ```bash
   git log --all --full-history --source --pretty=format: --name-only | grep -E '\.env'
   ```

3. **APIキーのローテーション**
   - 定期的にOpenAI APIキーを再生成
   - 古いキーを無効化

## 📞 セキュリティ問題の報告

セキュリティ上の脆弱性を発見した場合は、以下の方法で報告してください:

1. GitHubのIssueは**使用しないでください**（公開されるため）
2. リポジトリオーナーに直接連絡
3. 詳細な再現手順を含めてください

## 📚 参考リソース

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Next.js Security Best Practices](https://nextjs.org/docs/app/building-your-application/configuring/security)
- [Vercel Security](https://vercel.com/docs/security/overview)
- [OpenAI API Best Practices](https://platform.openai.com/docs/guides/safety-best-practices)

---

最終更新日: 2025-10-08
