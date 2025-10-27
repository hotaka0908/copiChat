import Foundation

struct Message: Identifiable, Codable, Hashable {
    let id: UUID
    let role: MessageRole
    let content: String
    let timestamp: Date

    init(id: UUID = UUID(), role: MessageRole, content: String, timestamp: Date = Date()) {
        self.id = id
        self.role = role
        self.content = content
        self.timestamp = timestamp
    }
}

enum MessageRole: String, Codable {
    case user
    case assistant
}

extension Message {
    static let preview = Message(
        role: .assistant,
        content: "こんにちは！私はスティーブ・ジョブズです。",
        timestamp: Date()
    )
}
