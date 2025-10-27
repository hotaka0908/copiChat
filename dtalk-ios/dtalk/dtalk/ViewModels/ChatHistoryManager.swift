import Foundation

/// 会話履歴を管理するクラス
/// 人物ごとに最新N件のメッセージをUserDefaultsに保存
@MainActor
class ChatHistoryManager {
    static let shared = ChatHistoryManager()

    private let userDefaults = UserDefaults.standard
    private let maxMessagesPerPersona = 20 // 保持する最大メッセージ数

    private init() {}

    /// 人物IDからUserDefaultsのキーを生成
    private func key(for personaId: String) -> String {
        return "chat_history_\(personaId)"
    }

    /// 会話履歴を保存（最新N件のみ）
    func saveMessages(for personaId: String, messages: [Message]) {
        // 最新N件のみに制限
        let limitedMessages = keepLastNMessages(messages, maxCount: maxMessagesPerPersona)

        do {
            let data = try JSONEncoder().encode(limitedMessages)
            userDefaults.set(data, forKey: key(for: personaId))
        } catch {
            print("Failed to save messages: \(error)")
        }
    }

    /// 会話履歴を読み込み
    func loadMessages(for personaId: String) -> [Message] {
        guard let data = userDefaults.data(forKey: key(for: personaId)) else {
            return []
        }

        do {
            let messages = try JSONDecoder().decode([Message].self, from: data)
            return messages
        } catch {
            print("Failed to load messages: \(error)")
            return []
        }
    }

    /// 会話履歴を削除
    func clearMessages(for personaId: String) {
        userDefaults.removeObject(forKey: key(for: personaId))
    }

    /// すべての会話履歴を削除
    func clearAllMessages() {
        let keys = userDefaults.dictionaryRepresentation().keys
        for key in keys where key.hasPrefix("chat_history_") {
            userDefaults.removeObject(forKey: key)
        }
    }

    /// メッセージ配列から最新N件のみを保持
    func keepLastNMessages(_ messages: [Message], maxCount: Int) -> [Message] {
        guard messages.count > maxCount else {
            return messages
        }
        return Array(messages.suffix(maxCount))
    }

    /// 最後のメッセージを取得
    func getLastMessage(for personaId: String) -> Message? {
        let messages = loadMessages(for: personaId)
        return messages.last
    }

    /// 会話履歴があるかどうか
    func hasHistory(for personaId: String) -> Bool {
        return !loadMessages(for: personaId).isEmpty
    }
}
