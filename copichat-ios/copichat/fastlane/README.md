# Fastlane セットアップガイド

このプロジェクトでは、Fastlaneを使用してiOSアプリのビルド・デプロイを自動化しています。

## 📋 前提条件

- Xcode（最新版推奨）
- Fastlane（`brew install fastlane`でインストール済み）
- Apple Developer Program メンバーシップ
- App Store Connect へのアクセス権

## 🚀 使い方

### 初回セットアップ

1. **Apple IDを環境変数に設定**（オプション）

```bash
export FASTLANE_USER="your-apple-id@example.com"
export FASTLANE_PASSWORD="your-app-specific-password"
```

または、各コマンド実行時に入力することもできます。

2. **App Store Connect API Key を使用する場合**（推奨）

App Store Connect API Keyを使用すると、2ファクタ認証を回避できます。

- App Store Connect > ユーザーとアクセス > キー > App Store Connect API で作成
- ダウンロードした `.p8` ファイルを `fastlane/` に配置
- Fastfileに設定を追加（必要に応じて）

### 利用可能なコマンド

#### 1. TestFlightにビルドをアップロード

```bash
fastlane beta
```

このコマンドは以下を実行します：
- ビルド番号を自動インクリメント
- アプリをビルド（Archive作成）
- TestFlightに自動アップロード

**所要時間**: 約5-10分

#### 2. App Storeに審査提出

```bash
fastlane release
```

このコマンドは以下を実行します：
- バージョン番号の入力を求める（Enterでスキップ）
- ビルド番号を自動インクリメント
- アプリをビルド（Archive作成）
- App Store Connectにアップロード
- 自動的に審査に提出

**所要時間**: 約10-15分

#### 3. バージョン番号をインクリメント

```bash
fastlane bump_version
```

マイナーバージョン（例: 1.0.1 → 1.0.2）とビルド番号を自動で更新します。

#### 4. プロジェクトをクリーン

```bash
fastlane clean
```

ビルド成果物やキャッシュをクリーンアップします。

## 🔧 トラブルシューティング

### 認証エラーが発生する場合

```bash
# App Store Connectの認証情報をリセット
fastlane fastlane-credentials remove

# 再度コマンドを実行
fastlane beta
```

### ビルドエラーが発生する場合

```bash
# プロジェクトをクリーン
fastlane clean

# Xcodeでも手動クリーン
# Xcode > Product > Clean Build Folder

# 再度実行
fastlane beta
```

### 署名エラーが発生する場合

- Xcodeで署名設定を確認
- Automatic Signingが有効になっているか確認
- Provisioning Profileが最新か確認

## 📝 カスタマイズ

`fastlane/Fastfile` を編集することで、動作をカスタマイズできます：

- バージョン番号の自動入力
- Slackへの通知追加
- スクリーンショット自動生成
- テストの自動実行

## 🔒 セキュリティ

以下のファイルは **絶対にGitにコミットしないでください**：

- `AuthKey_*.p8`（App Store Connect API Key）
- `*.mobileprovision`
- `*.ipa`

これらは `.gitignore` に既に追加されています。

## 📚 参考リンク

- [Fastlane 公式ドキュメント](https://docs.fastlane.tools/)
- [iOSアプリのデプロイ](https://docs.fastlane.tools/getting-started/ios/beta-deployment/)
- [App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi)
