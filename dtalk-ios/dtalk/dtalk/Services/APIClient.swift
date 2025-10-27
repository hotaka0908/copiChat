import Foundation

enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case decodingError(Error)
    case serverError(String)
}

class APIClient {
    static let shared = APIClient()

    private let baseURL: String
    private let session: URLSession

    private init() {
        // Vercelにデプロイされたサーバーを使用
        self.baseURL = "https://dtalk-dusky.vercel.app"

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)
    }

    func sendMessage(personaId: String, messages: [Message]) async throws -> String {
        guard let url = URL(string: "\(baseURL)/api/chat") else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let apiMessages = messages.map { APIMessage(from: $0) }
        let chatRequest = ChatRequest(personaId: personaId, messages: apiMessages)

        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(chatRequest)
        } catch {
            throw APIError.decodingError(error)
        }

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            guard httpResponse.statusCode == 200 else {
                if let errorMessage = String(data: data, encoding: .utf8) {
                    throw APIError.serverError(errorMessage)
                }
                throw APIError.serverError("HTTP \(httpResponse.statusCode)")
            }

            let decoder = JSONDecoder()
            let chatResponse = try decoder.decode(ChatResponse.self, from: data)
            return chatResponse.message

        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }

    func generatePersona(name: String) async throws -> Persona {
        // サーバー経由でOpenAI APIを呼び出す（セキュリティ向上）
        guard let url = URL(string: "\(baseURL)/api/generate-persona") else {
            throw APIError.invalidURL
        }

        print("🔵 Requesting persona generation from server for: \(name)")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 90 // 人物生成は時間がかかるため90秒

        // 既存人物名のリストを取得
        let existingNames = PersonaData.shared.getAllPersonas().map { $0.name }

        let requestBody: [String: Any] = [
            "name": name,
            "existingPersonaNames": existingNames
        ]

        do {
            let encoder = JSONEncoder()
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            throw APIError.decodingError(error)
        }

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            print("🔵 Server response status: \(httpResponse.statusCode)")

            guard httpResponse.statusCode == 200 else {
                if let errorMessage = String(data: data, encoding: .utf8) {
                    print("❌ Server error response: \(errorMessage)")
                    throw APIError.serverError(errorMessage)
                }
                throw APIError.serverError("HTTP \(httpResponse.statusCode)")
            }

            // レスポンスのJSONをデコード
            let decoder = JSONDecoder()
            let serverResponse = try decoder.decode(GeneratePersonaResponse.self, from: data)

            print("✅ Successfully generated persona: \(serverResponse.persona.name)")
            return serverResponse.persona

        } catch let error as APIError {
            throw error
        } catch {
            print("❌ Network error: \(error)")
            throw APIError.networkError(error)
        }
    }
}

// サーバーレスポンス用の構造体
private struct GeneratePersonaResponse: Codable {
    let persona: Persona
}
