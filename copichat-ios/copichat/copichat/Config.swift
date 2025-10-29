import Foundation

// IMPORTANT: このファイルはXcode Cloudでビルドするためにリポジトリに含まれています
// APIキーは環境変数から読み込まれます

struct Config {
    // OpenAI APIキーを環境変数または直接設定から取得
    static let openAIAPIKey: String = {
        // 1. 環境変数から読み取る（Xcode Cloud用）
        if let envKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"], !envKey.isEmpty {
            return envKey
        }

        // 2. ローカル開発用：ここに直接APIキーを設定してください
        // 例: return "sk-proj-your-actual-api-key-here"
        // 注意：この値は.gitignoreで無視されないため、実際のAPIキーを
        //       コミットしないように注意してください
        return ""
    }()
}
