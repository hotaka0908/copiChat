# GitHub リポジトリ作成 - 簡単セットアップ

## 方法1: Webブラウザで作成（推奨）

1. **GitHubにログイン**: https://github.com

2. **新しいリポジトリを作成**:
   - 右上の「+」→「New repository」
   - Repository name: `dtalk`
   - Description: `AI-powered chat application for conversations with historical figures`
   - Public を選択
   - 「Create repository」をクリック

3. **ターミナルで実行**:
```bash
cd /Users/funahashihotaka/Desktop/dtalk

# あなたのGitHubユーザー名に置き換えて実行
git remote add origin https://github.com/YOUR_USERNAME/dtalk.git
git push -u origin main
```

## 方法2: スクリプトを使用

1. **GitHubトークンを作成**:
   - https://github.com/settings/tokens
   - 「Generate new token (classic)」
   - Note: `dtalk`
   - Expiration: 30 days
   - Scopes: `repo` にチェック
   - 「Generate token」をクリック
   - トークンをコピー（一度しか表示されません！）

2. **スクリプトを実行**:
```bash
cd /Users/funahashihotaka/Desktop/dtalk
./create-github-repo.sh YOUR_USERNAME YOUR_TOKEN
```

## 方法3: GitHub Desktop を使用

1. **GitHub Desktop をダウンロード**: https://desktop.github.com/

2. **リポジトリを追加**:
   - File → Add Local Repository
   - `/Users/funahashihotaka/Desktop/dtalk` を選択
   - Publish repository をクリック

## ✅ 完了後の確認

リポジトリURL: `https://github.com/YOUR_USERNAME/dtalk`

## 🎉 成功！

これでDTalkがGitHubで管理できるようになります。