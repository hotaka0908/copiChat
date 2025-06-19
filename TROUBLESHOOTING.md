# DTalk トラブルシューティング

## 🚨 現在の問題: 401 認証エラー

**症状**: VercelでデプロイされたDTalkにアクセスすると401エラーが表示される

## 🔧 解決方法

### 1. Vercel Dashboard設定の確認

**手順**:
1. https://vercel.com/hotakas-projects/dtalk/settings にアクセス
2. 「Security」または「General」タブを確認
3. 「Authentication」または「Protection」設定を確認
4. パブリックアクセスを有効にする

### 2. プロジェクト設定の変更

**オプション1: Vercel Dashboard**
- プロジェクト設定 → Protection → Public access を有効化

**オプション2: CLI経由**
```bash
vercel inspect https://dtalk-jvc3vy53e-hotakas-projects.vercel.app
vercel project set protection=public
```

## 📊 実装済みの修正

### ✅ 完了した改善

1. **OpenAIモデルの更新**
   - `gpt-4-turbo-preview` → `gpt-4o-mini`
   - より安定で高速なモデル

2. **エラーハンドリングの強化**
   - 詳細なログ出力
   - 具体的なエラーメッセージ
   - CORS対応

3. **API設定の改善**
   - レスポンスヘッダーの最適化
   - 環境変数の確認機能

## 🧪 ローカルテスト方法

```bash
# ローカルで動作確認
cd /Users/funahashihotaka/Downloads/dtalk
npm run dev

# ブラウザで http://localhost:3001 にアクセス
# 人物を選択してチャット機能をテスト
```

## 📱 動作確認手順

1. **ホームページアクセス**
   - 人物選択ギャラリーが表示されることを確認

2. **チャット機能テスト**
   - 任意の人物（例：スティーブ・ジョブズ）を選択
   - 「こんにちは」などの簡単な質問を送信
   - AI応答が正常に返されることを確認

## 🔍 デバッグ情報

**最新デプロイURL**: https://dtalk-jvc3vy53e-hotakas-projects.vercel.app

**ログ確認コマンド**:
```bash
vercel logs https://dtalk-jvc3vy53e-hotakas-projects.vercel.app
```

**環境変数確認**:
```bash
vercel env ls
```

## 🆘 緊急時の対処法

認証エラーが解決しない場合:
1. プロジェクトを削除して再作成
2. 新しいドメインでの再デプロイ
3. Vercel Dashboard での手動設定確認

**連絡先**: 設定変更には管理者権限が必要な可能性があります。