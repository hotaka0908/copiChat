import Foundation

struct Persona: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let nameEn: String
    let era: String
    let title: String
    let avatar: String
    let systemPrompt: String
    let backgroundGradient: [String]
    let textColor: String
    let traits: PersonaTraits
    let specialties: [String]
    let historicalContext: String

    var avatarURL: URL? {
        if avatar.hasPrefix("http") {
            return URL(string: avatar)
        }
        return nil
    }

    var gradientColors: [String] {
        return backgroundGradient
    }
}

struct PersonaTraits: Codable, Hashable {
    let speechPattern: [String]
    let philosophy: [String]
    let decisionMaking: String
    let keyPhrases: [String]
    let famousQuotes: [String]
}

extension Persona {
    static let preview = Persona(
        id: "steve-jobs",
        name: "スティーブ・ジョブズ",
        nameEn: "Steve Jobs",
        era: "1955-2011",
        title: "Apple共同創業者・革新的起業家",
        avatar: "",
        systemPrompt: "You are Steve Jobs...",
        backgroundGradient: ["gray-900", "blue-900", "black"],
        textColor: "white",
        traits: PersonaTraits(
            speechPattern: ["Think different"],
            philosophy: ["Simplicity is the ultimate sophistication"],
            decisionMaking: "Intuitive",
            keyPhrases: ["One more thing"],
            famousQuotes: ["Stay hungry, stay foolish"]
        ),
        specialties: ["Product Design", "Innovation"],
        historicalContext: "Apple co-founder"
    )
}
