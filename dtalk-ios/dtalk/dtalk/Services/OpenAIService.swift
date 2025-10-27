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
        print("🔵 OpenAIService: Starting persona generation for '\(name)'")
        print("🔵 API Key prefix: \(String(apiKey.prefix(10)))...")

        let url = URL(string: "https://api.openai.com/v1/chat/completions")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        // ウォルト・ディズニーを参考例として使用（最も完璧な例）
        let examplePersona = PersonaData.shared.allPersonas.first(where: { $0.id == "walt-disney" }) ?? PersonaData.shared.allPersonas.first!
        let exampleJSON = try JSONEncoder().encode(examplePersona)
        let exampleString = String(data: exampleJSON, encoding: .utf8) ?? ""

        let prompt = """
        あなたは歴史上の人物や著名人の詳細なプロフィールを生成する専門家です。
        以下のJSON形式の完璧な例を参考に、「\(name)」という人物の詳細情報を同じ品質レベルでJSON形式で生成してください。

        【完璧な参考例】
        \(exampleString)

        【厳密な要件】

        1. **JSON構造**: 上記と全く同じJSON構造で出力してください

        2. **基本情報**:
           - id: UUID形式で一意のIDを生成（例: "a1b2c3d4-e5f6-7890-abcd-ef1234567890"）
           - name: 「\(name)」を使用
           - nameEn: 英語名またはローマ字表記
           - era: 生没年や活動時期（例: "1901-1966", "BC384-BC322"）
           - title: 職業や肩書き（簡潔かつ具体的に）

        3. **avatar画像URL**:
           - Wikipediaの256px版画像URLを使用
           - 形式: "https://upload.wikimedia.org/wikipedia/commons/thumb/[2文字]/[2文字]/[filename]/256px-[filename]"
           - 例: "https://upload.wikimedia.org/wikipedia/commons/thumb/d/df/Walt_Disney_1946.JPG/256px-Walt_Disney_1946.JPG"
           - 実在する人物の場合は必ず本物の画像URLを生成（Wikipedia Commonsから実在する画像を検索して正確なパスを使用）
           - 架空の人物の場合は空文字 "" を使用

        4. **systemPrompt** (最重要):
           - 300-500文字以上の詳細なプロンプトを作成
           - 人物の性格、話し方、思考パターンを具体的に描写
           - 「あなたは[人物名]です。」で始める
           - 人物の特徴、信念、行動様式を詳しく説明
           - 会話でどのように振る舞うべきかを明確に指示
           - 参考例と同じレベルの詳細度を維持

        5. **backgroundGradient**:
           - 2-3色の配列（例: ["blue-500", "purple-600"]）
           - 人物のイメージに合った色を選択
           - 使用可能な色: red, orange, yellow, green, blue, indigo, purple, pink, gray（各色に-500, -600, -700, -800, -900のバリエーション）

        6. **textColor**: 必ず "white" を使用

        7. **traits（非常に重要）**:
           - speechPattern: 3-4個の特徴的な話し方や口癖
           - philosophy: 3-6個の人物の哲学や信念
           - decisionMaking: 意思決定の特徴を1文で説明
           - keyPhrases: 3-4個の特徴的なフレーズ
           - famousQuotes: 2-4個の実際の名言（日本語と英語の両方を含む）

        8. **specialties**: 3-5個の専門分野や得意領域

        9. **historicalContext**:
           - 200-400文字の詳細な歴史的背景
           - 生い立ち、主要な業績、影響、レガシーを含む
           - 具体的な年代や出来事を含める

        10. **category**（重要）:
           - 人物の主な活動領域に基づいて、以下のいずれかのカテゴリを自動選択
           - 選択肢（英語の値を使用）:
             * "business": ビジネス・起業家（例: 経営者、実業家、企業家）
             * "philosophy": 哲学・宗教（例: 哲学者、宗教指導者、思想家）
             * "science": 科学・技術（例: 科学者、発明家、数学者、技術者）
             * "art": 芸術・文化（例: 画家、彫刻家、作家、建築家）
             * "music": 音楽・芸能（例: 音楽家、作曲家、歌手、DJ、パフォーマー）
             * "sports": スポーツ（例: アスリート、スポーツ選手）
             * "social": 社会活動・政治（例: 政治家、社会運動家、活動家）
           - 複数の領域で活躍した人物の場合は、最も影響力が大きかった主要領域を選択

        【品質基準】
        - すべての項目を参考例と同等以上の詳細度で記載
        - 実在の人物の場合は正確な歴史的事実に基づく
        - systemPromptは特に詳細に（300文字以上）
        - famousQuotesは実際の名言を使用
        - avatar URLは実在するWikipedia画像を使用

        【出力形式】
        - JSONのみを出力し、他の説明やマークダウンは一切含めない
        - 文字エンコーディングはUTF-8
        - すべての文字列は適切にエスケープ

        上記の基準を厳密に守って、最高品質の人物プロフィールを生成してください。
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

        print("🔵 Sending request to OpenAI API...")
        let (data, response) = try await session.data(for: request)
        print("🔵 Received response from OpenAI API")

        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid response type")
            throw APIError.invalidResponse
        }

        print("🔵 HTTP Status Code: \(httpResponse.statusCode)")

        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ OpenAI API Error (\(httpResponse.statusCode)): \(errorMessage)")
            throw APIError.serverError("OpenAI API Error (\(httpResponse.statusCode)): \(errorMessage)")
        }

        // OpenAIのレスポンスをパース
        print("🔵 Decoding OpenAI response...")
        let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)

        guard let content = openAIResponse.choices.first?.message.content else {
            print("❌ No content in OpenAI response")
            throw APIError.serverError("No content in response")
        }

        print("🔵 OpenAI response content length: \(content.count) characters")
        print("🔵 Content preview: \(String(content.prefix(200)))...")

        // JSON文字列をPersonaにデコード
        guard let contentData = content.data(using: .utf8) else {
            print("❌ Failed to convert content to data")
            throw APIError.decodingError(NSError(domain: "OpenAIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert content to data"]))
        }

        print("🔵 Decoding Persona from JSON...")
        let persona = try JSONDecoder().decode(Persona.self, from: contentData)
        print("✅ Successfully generated persona: \(persona.name)")
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
