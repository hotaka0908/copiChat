# GitHub リポジトリ設定ガイド

CopiChatプロジェクトをGitHubで管理するための手順です。

## 1. GitHubでリポジトリを作成

1. GitHubにログイン: https://github.com
2. 右上の「+」アイコンをクリック → 「New repository」を選択
3. 以下の情報を入力:
   - **Repository name**: `copiChat`
   - **Description**: `AI-powered chat application for conversations with historical figures using Next.js and OpenAI GPT-4`
   - **Public/Private**: お好みで選択（推奨: Public）
   - **Initialize this repository with**: 何も選択しない
4. 「Create repository」をクリック

## 2. ローカルリポジトリをGitHubに接続

GitHubでリポジトリを作成すると、以下のようなコマンドが表示されます。
ターミナルで以下を実行してください:

```bash
# あなたのGitHubユーザー名を使用してください
git remote add origin https://github.com/YOUR_USERNAME/copiChat.git
git branch -M main
git push -u origin main
```

例: もしGitHubユーザー名が `funahashihotaka` の場合:
```bash
git remote add origin https://github.com/funahashihotaka/copiChat.git
git branch -M main
git push -u origin main
```

## 3. 環境変数の安全な管理

**重要**: `.env.local` ファイルは `.gitignore` に含まれているため、GitHubにはアップロードされません。
これはセキュリティのために重要です。

他の開発者がプロジェクトを使用する場合:
1. `.env.local.example` ファイルを作成
2. 必要な環境変数のテンプレートを記載
3. 実際の値は別途共有

## 4. 今後の開発フロー

```bash
# 変更をステージング
git add .

# コミット
git commit -m "説明的なコミットメッセージ"

# GitHubにプッシュ
git push

# ブランチを作成して機能開発
git checkout -b feature/new-feature
# 作業後
git add .
git commit -m "Add new feature"
git push -u origin feature/new-feature
```

## 5. 推奨される追加設定

### GitHub Actions（CI/CD）
`.github/workflows/ci.yml` を作成して自動テストを設定

### Issue Templates
バグ報告や機能リクエストのテンプレートを作成

### Branch Protection
mainブランチへの直接プッシュを制限

## 完了！

これでCopiChatプロジェクトがGitHubで管理できるようになりました。
コラボレーションや版管理が簡単になります。