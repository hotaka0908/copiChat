import Foundation
import SwiftUI

@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Published var currentInput: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    let persona: Persona
    private let apiClient: APIClient

    init(persona: Persona, apiClient: APIClient = .shared) {
        self.persona = persona
        self.apiClient = apiClient

        // 初期メッセージを追加
        let initialMessage = Message(
            role: .assistant,
            content: "こんにちは！私は\(persona.name)です。\(persona.era)を生きた\(persona.title)として、あなたとお話しできることを嬉しく思います。何についてお聞きになりたいですか？",
            timestamp: Date()
        )
        messages.append(initialMessage)
    }

    func sendMessage() async {
        guard !currentInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        let userMessage = Message(
            role: .user,
            content: currentInput,
            timestamp: Date()
        )

        messages.append(userMessage)
        let inputToSend = currentInput
        currentInput = ""
        isLoading = true
        errorMessage = nil

        do {
            let response = try await apiClient.sendMessage(
                personaId: persona.id,
                messages: messages
            )

            let assistantMessage = Message(
                role: .assistant,
                content: response,
                timestamp: Date()
            )
            messages.append(assistantMessage)

        } catch let error as APIError {
            errorMessage = handleAPIError(error)
            let errorMsg = Message(
                role: .assistant,
                content: errorMessage ?? "エラーが発生しました",
                timestamp: Date()
            )
            messages.append(errorMsg)
        } catch {
            errorMessage = "予期しないエラーが発生しました"
            let errorMsg = Message(
                role: .assistant,
                content: errorMessage ?? "エラーが発生しました",
                timestamp: Date()
            )
            messages.append(errorMsg)
        }

        isLoading = false
    }

    private func handleAPIError(_ error: APIError) -> String {
        switch error {
        case .invalidURL:
            return "無効なURLです"
        case .networkError(let underlyingError):
            return "ネットワークエラー: \(underlyingError.localizedDescription)"
        case .invalidResponse:
            return "無効なレスポンスです"
        case .decodingError(let underlyingError):
            return "データの解析に失敗しました: \(underlyingError.localizedDescription)"
        case .serverError(let message):
            return "サーバーエラー: \(message)"
        }
    }

    func clearMessages() {
        messages.removeAll()
        // 初期メッセージを再追加
        let initialMessage = Message(
            role: .assistant,
            content: "こんにちは！私は\(persona.name)です。\(persona.era)を生きた\(persona.title)として、あなたとお話しできることを嬉しく思います。何についてお聞きになりたいですか？",
            timestamp: Date()
        )
        messages.append(initialMessage)
    }
}
