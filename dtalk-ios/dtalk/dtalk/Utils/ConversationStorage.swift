import Foundation

class ConversationStorage {
    static let shared = ConversationStorage()

    private let userDefaults = UserDefaults.standard
    private let conversationsKey = "savedConversations"

    private init() {}

    // 会話を保存
    func saveConversation(personaId: String, messages: [Message]) {
        var conversations = getAllConversations()
        conversations[personaId] = messages

        if let encoded = try? JSONEncoder().encode(conversations) {
            userDefaults.set(encoded, forKey: conversationsKey)
        }
    }

    // 特定の人物との会話を取得
    func getConversation(for personaId: String) -> [Message]? {
        let conversations = getAllConversations()
        return conversations[personaId]
    }

    // すべての会話を取得
    func getAllConversations() -> [String: [Message]] {
        guard let data = userDefaults.data(forKey: conversationsKey),
              let conversations = try? JSONDecoder().decode([String: [Message]].self, from: data) else {
            return [:]
        }
        return conversations
    }

    // 特定の人物との会話を削除
    func deleteConversation(for personaId: String) {
        var conversations = getAllConversations()
        conversations.removeValue(forKey: personaId)

        if let encoded = try? JSONEncoder().encode(conversations) {
            userDefaults.set(encoded, forKey: conversationsKey)
        }
    }

    // すべての会話を削除
    func clearAllConversations() {
        userDefaults.removeObject(forKey: conversationsKey)
    }
}
