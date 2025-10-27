import Foundation
import SwiftUI

@MainActor
class AddPersonaViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var generatedPersona: Persona?

    private let apiClient: APIClient = .shared

    func generatePersona(name: String) async {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "人物名を入力してください"
            return
        }

        isLoading = true
        errorMessage = nil

        do {
            let persona = try await apiClient.generatePersona(name: name)
            generatedPersona = persona

            // PersonaDataに追加
            PersonaData.shared.addPersona(persona)

        } catch let error as APIError {
            errorMessage = handleAPIError(error)
            print("❌ APIError: \(error)")
        } catch {
            errorMessage = "予期しないエラーが発生しました: \(error.localizedDescription)"
            print("❌ Unexpected Error: \(error)")
            print("❌ Error Details: \(String(describing: error))")
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
}
