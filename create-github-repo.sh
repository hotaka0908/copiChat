#!/bin/bash

# GitHubリポジトリ作成スクリプト
# 使用方法: ./create-github-repo.sh YOUR_GITHUB_USERNAME YOUR_GITHUB_TOKEN

USERNAME=$1
TOKEN=$2

if [ -z "$USERNAME" ] || [ -z "$TOKEN" ]; then
    echo "使用方法: ./create-github-repo.sh YOUR_GITHUB_USERNAME YOUR_GITHUB_TOKEN"
    echo ""
    echo "GitHubトークンの作成方法:"
    echo "1. https://github.com/settings/tokens にアクセス"
    echo "2. 'Generate new token' をクリック"
    echo "3. 'repo' スコープを選択"
    echo "4. トークンを生成してコピー"
    exit 1
fi

# リポジトリ作成
echo "GitHubにリポジトリを作成中..."
curl -X POST -H "Authorization: token $TOKEN" \
     -H "Accept: application/vnd.github.v3+json" \
     https://api.github.com/user/repos \
     -d '{
       "name": "copiChat",
       "description": "AI-powered chat application for conversations with historical figures using Next.js and OpenAI GPT-4",
       "private": false,
       "has_issues": true,
       "has_projects": true,
       "has_wiki": true
     }'

echo ""
echo "リポジトリ作成完了！"
echo ""
echo "次に以下のコマンドを実行してください:"
echo "git remote add origin https://github.com/$USERNAME/copiChat.git"
echo "git push -u origin main"