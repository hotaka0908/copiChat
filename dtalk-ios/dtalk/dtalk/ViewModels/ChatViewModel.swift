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

        // 保存された会話履歴を読み込む
        messages = ChatHistoryManager.shared.loadMessages(for: persona.id)
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

            // 会話履歴を保存（最新20件のみ）
            ChatHistoryManager.shared.saveMessages(for: persona.id, messages: messages)

        } catch let error as APIError {
            errorMessage = handleAPIError(error)
            let errorMsg = Message(
                role: .assistant,
                content: errorMessage ?? "エラーが発生しました",
                timestamp: Date()
            )
            messages.append(errorMsg)

            // エラーメッセージも履歴に保存
            ChatHistoryManager.shared.saveMessages(for: persona.id, messages: messages)
        } catch {
            errorMessage = "予期しないエラーが発生しました"
            let errorMsg = Message(
                role: .assistant,
                content: errorMessage ?? "エラーが発生しました",
                timestamp: Date()
            )
            messages.append(errorMsg)

            // エラーメッセージも履歴に保存
            ChatHistoryManager.shared.saveMessages(for: persona.id, messages: messages)
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
        // 保存された履歴もクリア
        ChatHistoryManager.shared.clearMessages(for: persona.id)
    }
}
