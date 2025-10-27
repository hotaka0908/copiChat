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
        // OpenAIServiceを使用してiOS側で直接人物を生成
        return try await OpenAIService.shared.generatePersona(name: name)
    }
}
