import Foundation

struct ChatRequest: Codable {
    let personaId: String
    let messages: [APIMessage]
}

struct APIMessage: Codable {
    let role: String
    let content: String
    let timestamp: String?

    enum CodingKeys: String, CodingKey {
        case role
        case content
        case timestamp
    }

    init(from message: Message) {
        self.role = message.role.rawValue
        self.content = message.content
        let formatter = ISO8601DateFormatter()
        self.timestamp = formatter.string(from: message.timestamp)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        role = try container.decode(String.self, forKey: .role)
        content = try container.decode(String.self, forKey: .content)
        timestamp = try container.decodeIfPresent(String.self, forKey: .timestamp)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(role, forKey: .role)
        try container.encode(content, forKey: .content)
        try container.encodeIfPresent(timestamp, forKey: .timestamp)
    }
}

struct ChatResponse: Codable {
    let message: String
    let persona: PersonaInfo?
}

struct PersonaInfo: Codable {
    let id: String
    let name: String
    let era: String
}
