# Vercel 環境変数設定ガイド

このガイドでは、Vercelで環境変数を正しく設定する方法を説明します。

---

## 🔧 環境変数の設定手順

### ステップ1: Vercel Dashboardにアクセス

1. https://vercel.com にアクセス
2. プロジェクト `dtalk` を選択
3. 上部メニューから **Settings** をクリック

### ステップ2: 環境変数を追加

1. 左サイドバーから **Environment Variables** を選択
2. **Add New** ボタンをクリック

### ステップ3: 必須の環境変数を設定

#### 1. OPENAI_API_KEY（必須）

| 項目 | 値 |
|------|-----|
| **Key** | `OPENAI_API_KEY` |
| **Value** | `sk-proj-...` （あなたのOpenAI APIキー） |
| **Environment** | ✅ Production<br>✅ Preview<br>✅ Development |

**重要:**
- Value欄にOpenAI APIキー全体を貼り付けてください
- 3つの環境全てにチェックを入れることを推奨

#### 2. NEXT_PUBLIC_APP_URL（推奨）

| 項目 | 値 |
|------|-----|
| **Key** | `NEXT_PUBLIC_APP_URL` |
| **Value** | `https://your-project-name.vercel.app` |
| **Environment** | ✅ Production |

**注意:**
- 最初のデプロイ後にVercelから提供されるURLを確認してから設定
- または、カスタムドメインを使用する場合はそのURLを設定

---

## 📸 設定画面のスクリーンショット例

```
┌─────────────────────────────────────────────────────┐
│ Environment Variables                               │
├─────────────────────────────────────────────────────┤
│                                                     │
│ Key:   OPENAI_API_KEY                              │
│ Value: sk-proj-********************************    │
│                                                     │
│ Environments:                                       │
│ ☑ Production                                       │
│ ☑ Preview                                          │
│ ☑ Development                                      │
│                                                     │
│ [Save]                                             │
└─────────────────────────────────────────────────────┘
```

---

## 🔄 設定後の再デプロイ

環境変数を追加した後、自動的に再デプロイされます。
手動で再デプロイする場合：

1. **Deployments** タブを開く
2. 最新のデプロイメントの右側にある **︙** メニューをクリック
3. **Redeploy** を選択

---

## ✅ 設定確認方法

### 方法1: デプロイメントログで確認

1. Vercel Dashboardで最新のデプロイメントをクリック
2. **Building** セクションを展開
3. 以下のようなログが表示されれば成功:
   ```
   ✓ Compiled successfully
   ✓ Generating static pages
   ```

### 方法2: APIエンドポイントで確認

デプロイ完了後、以下のURLにアクセス:
```
https://your-app.vercel.app/api/test
```

成功時のレスポンス:
```json
{
  "status": "success",
  "message": "API is working",
  "environment": "production"
}
```

### 方法3: OpenAI接続テスト

```
https://your-app.vercel.app/api/test-openai
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

## 🐛 トラブルシューティング

### エラー: "OPENAI_API_KEY is not configured"

**原因:** 環境変数が設定されていないか、デプロイに反映されていない

**解決方法:**
1. Vercel Dashboard > Settings > Environment Variables を確認
2. `OPENAI_API_KEY` が存在するか確認
3. Production環境にチェックが入っているか確認
4. 再デプロイを実行

### エラー: "Invalid API key"

**原因:** OpenAI APIキーが正しくない

**解決方法:**
1. https://platform.openai.com/api-keys でAPIキーを確認
2. 正しいキーをコピー（`sk-proj-` で始まる）
3. Vercel Dashboardで環境変数を更新
4. 再デプロイ

### エラー: Build時に環境変数が読み込めない

**原因:** `vercel.json`でシークレット参照を使用している（現在は削除済み）

**解決方法:**
- `vercel.json`の`env`セクションを削除（既に対応済み）
- Vercel Dashboardから直接環境変数を設定

---

## 🔐 セキュリティのベストプラクティス

### ✅ 推奨

- ✅ Vercel Dashboardから環境変数を設定
- ✅ APIキーは定期的にローテーション
- ✅ Production環境のみに本番APIキーを設定
- ✅ Preview/Development環境には別のAPIキーを使用

### ❌ 非推奨

- ❌ `.env.local`をGitにコミット
- ❌ `vercel.json`にAPIキーをハードコード
- ❌ コード内にAPIキーを直接記述
- ❌ 公開リポジトリでAPIキーを共有

---

## 📋 環境変数一覧

| 変数名 | 必須 | 説明 | デフォルト値 |
|--------|------|------|------------|
| `OPENAI_API_KEY` | ✅ 必須 | OpenAI APIキー | なし |
| `NEXT_PUBLIC_APP_URL` | 推奨 | アプリケーションURL（CORS用） | 自動検出 |
| `VERCEL_URL` | 自動 | Vercelが自動設定 | - |
| `VERCEL_ENV` | 自動 | 環境識別子 | - |
| `NODE_ENV` | 自動 | Node.js環境 | production |

---

## 💡 ヒント

### プレビューデプロイメント用の設定

ブランチごとに異なる設定を使いたい場合:

1. Environment Variables画面で変数を追加
2. **Preview** 環境を選択
3. **Branch** で特定のブランチを指定（オプション）

### 環境変数の更新

環境変数を更新した場合、変更は即座に新しいデプロイメントに反映されます。
既存のデプロイメントには影響しません。

---

## 📞 サポート

問題が解決しない場合:

1. **Vercel Documentation**: https://vercel.com/docs/environment-variables
2. **GitHub Issues**: このリポジトリのIssuesセクション
3. **Vercel Support**: https://vercel.com/support

---

**最終更新:** 2025-10-08
