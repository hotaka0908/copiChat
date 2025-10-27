import Foundation

class OpenAIService {
    static let shared = OpenAIService()

    private let apiKey: String
    private let session: URLSession

    private init() {
        // APIキーはConfig.swiftから読み込みます
        // Config.swiftの設定方法はConfig-Template.swiftを参照してください
        self.apiKey = Config.openAIAPIKey

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 120
        self.session = URLSession(configuration: configuration)
    }

    func generatePersona(name: String) async throws -> Persona {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        // 既存の人物を参考例として使用
        let examplePersona = PersonaData.shared.allPersonas.first!
        let exampleJSON = try JSONEncoder().encode(examplePersona)
        let exampleString = String(data: exampleJSON, encoding: .utf8) ?? ""

        let prompt = """
        あなたは歴史上の人物や架空の人物のプロフィールを生成する専門家です。

        以下のJSON形式の例を参考に、「\(name)」という人物の詳細情報をJSON形式で生成してください。

        【参考例】
        \(exampleString)

        【要件】
        1. 上記と全く同じJSON構造で出力してください
        2. id は UUID形式で一意のIDを生成してください
        3. name は「\(name)」を使用してください
        4. nameEn は英語名（ローマ字または英訳）を生成してください
        5. era は生没年や活動時期を記載してください
        6. title は職業や肩書きを記載してください
        7. avatar は適切なWikipedia画像URLを生成してください（存在しない場合は空文字）
        8. systemPrompt は人物になりきって会話するためのプロンプトを詳細に記載してください
        9. backgroundGradient は適切な色の配列を指定してください（例: ["blue-600", "purple-700"]）
        10. textColor は "white" を使用してください
        11. traits の各項目（speechPattern, philosophy, decisionMaking, keyPhrases, famousQuotes）を充実させてください
        12. specialties は専門分野の配列を記載してください
        13. historicalContext は歴史的背景や業績を詳しく記載してください

        JSONのみを出力し、他の説明は一切含めないでください。
        """

        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                ["role": "system", "content": "You are a helpful assistant that generates persona data in JSON format."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7,
            "response_format": ["type": "json_object"]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw APIError.serverError("OpenAI API Error (\(httpResponse.statusCode)): \(errorMessage)")
        }

        // OpenAIのレスポンスをパース
        let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)

        guard let content = openAIResponse.choices.first?.message.content else {
            throw APIError.serverError("No content in response")
        }

        // JSON文字列をPersonaにデコード
        guard let contentData = content.data(using: .utf8) else {
            throw APIError.decodingError(NSError(domain: "OpenAIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert content to data"]))
        }

        let persona = try JSONDecoder().decode(Persona.self, from: contentData)
        return persona
    }
}

// OpenAI APIのレスポンス構造
struct OpenAIResponse: Codable {
    let choices: [Choice]

    struct Choice: Codable {
        let message: Message
    }

    struct Message: Codable {
        let content: String
    }
}
