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
    let category: PersonaCategory

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

enum PersonaCategory: String, Codable, CaseIterable {
    case business = "business"
    case philosophy = "philosophy"
    case science = "science"
    case art = "art"
    case music = "music"
    case sports = "sports"
    case social = "social"
    case other = "other"

    var displayName: String {
        switch self {
        case .business: return "ビジネス・起業家"
        case .philosophy: return "哲学・宗教"
        case .science: return "科学・技術"
        case .art: return "芸術・文化"
        case .music: return "音楽・芸能"
        case .sports: return "スポーツ"
        case .social: return "社会活動・政治"
        case .other: return "その他"
        }
    }

    var icon: String {
        switch self {
        case .business: return "briefcase.fill"
        case .philosophy: return "book.fill"
        case .science: return "atom"
        case .art: return "paintpalette.fill"
        case .music: return "music.note"
        case .sports: return "sportscourt.fill"
        case .social: return "heart.fill"
        case .other: return "ellipsis.circle.fill"
        }
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
        historicalContext: "Apple co-founder",
        category: .business
    )
}
