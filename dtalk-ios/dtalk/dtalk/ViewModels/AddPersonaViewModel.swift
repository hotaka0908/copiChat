import Foundation
import SwiftUI
import Combine

@MainActor
class AddPersonaViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var generatedPersona: Persona?

    // 進捗表示用のプロパティ
    @Published var currentProgress: Double = 0.0
    @Published var currentStepMessage: String = ""
    @Published var currentStepEmoji: String = ""
    @Published var completedSteps: [String] = []
    @Published var isGenerating: Bool = false

    private let apiClient: APIClient = .shared
    private var progressTimer: AnyCancellable?
    private var currentStepIndex: Int = 0

    // 進捗ステップの定義
    struct ProgressStep {
        let emoji: String
        let message: String
        let targetProgress: Double
        let duration: TimeInterval
    }

    private let progressSteps: [ProgressStep] = [
        ProgressStep(emoji: "🔍", message: "人物情報を検索中", targetProgress: 0.20, duration: 3.5),
        ProgressStep(emoji: "📚", message: "プロフィール情報を収集中", targetProgress: 0.35, duration: 3.5),
        ProgressStep(emoji: "🧠", message: "性格と話し方を分析中", targetProgress: 0.60, duration: 6.0),
        ProgressStep(emoji: "✍️", message: "人格を形成中", targetProgress: 0.80, duration: 6.0),
        ProgressStep(emoji: "🎨", message: "振る舞いを作成中", targetProgress: 0.95, duration: 3.5),
        ProgressStep(emoji: "✨", message: "最終調整中", targetProgress: 0.98, duration: 2.0)
    ]

    func generatePersona(name: String) async {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "人物名を入力してください"
            return
        }

        // 生成回数チェック
        guard PersonaGenerationLimitManager.shared.canGenerate() else {
            errorMessage = "生成回数の上限に達しました"
            return
        }

        // 進捗表示を開始
        startProgress()

        isLoading = true
        errorMessage = nil

        do {
            let persona = try await apiClient.generatePersona(name: name)
            generatedPersona = persona

            // PersonaDataに追加
            PersonaData.shared.addPersona(persona)

            // 生成回数を消費
            PersonaGenerationLimitManager.shared.consumeGeneration()

            // 即座に完了状態に
            completeProgress()

        } catch let error as APIError {
            errorMessage = handleAPIError(error)
            print("❌ APIError: \(error)")
            stopProgress()
        } catch {
            errorMessage = "予期しないエラーが発生しました: \(error.localizedDescription)"
            print("❌ Unexpected Error: \(error)")
            print("❌ Error Details: \(String(describing: error))")
            stopProgress()
        }

        isLoading = false
    }

    // 進捗を開始
    private func startProgress() {
        isGenerating = true
        currentProgress = 0.0
        currentStepIndex = 0
        completedSteps = []

        // 最初のステップを開始
        if !progressSteps.isEmpty {
            let firstStep = progressSteps[0]
            currentStepEmoji = firstStep.emoji
            currentStepMessage = firstStep.message

            // 次のステップへの進行をスケジュール
            scheduleNextStep()
        }
    }

    // 次のステップに進む
    private func scheduleNextStep() {
        guard currentStepIndex < progressSteps.count else { return }

        let step = progressSteps[currentStepIndex]
        let startProgress = currentProgress
        let targetProgress = step.targetProgress
        let duration = step.duration
        let updateInterval = 0.1 // 100msごとに更新
        let totalSteps = Int(duration / updateInterval)
        let progressIncrement = (targetProgress - startProgress) / Double(totalSteps)

        var stepCount = 0

        progressTimer = Timer.publish(every: updateInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }

                stepCount += 1
                self.currentProgress = min(startProgress + (progressIncrement * Double(stepCount)), targetProgress)

                // このステップが完了したら
                if stepCount >= totalSteps {
                    self.progressTimer?.cancel()

                    // 完了したステップを記録
                    self.completedSteps.append(step.message)

                    // 次のステップへ
                    self.currentStepIndex += 1
                    if self.currentStepIndex < self.progressSteps.count {
                        let nextStep = self.progressSteps[self.currentStepIndex]
                        withAnimation {
                            self.currentStepEmoji = nextStep.emoji
                            self.currentStepMessage = nextStep.message
                        }
                        self.scheduleNextStep()
                    }
                }
            }
    }

    // 進捗を完了状態に
    private func completeProgress() {
        progressTimer?.cancel()

        withAnimation {
            currentProgress = 1.0
            currentStepEmoji = "✅"
            currentStepMessage = "完了"

            // 残っているステップを完了済みにする
            for i in currentStepIndex..<progressSteps.count {
                if !completedSteps.contains(progressSteps[i].message) {
                    completedSteps.append(progressSteps[i].message)
                }
            }
        }

        // 少し遅延してから生成フラグをオフ
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isGenerating = false
        }
    }

    // 進捗を停止（エラー時）
    private func stopProgress() {
        progressTimer?.cancel()
        isGenerating = false
    }

    // リセット
    func resetProgress() {
        progressTimer?.cancel()
        currentProgress = 0.0
        currentStepMessage = ""
        currentStepEmoji = ""
        completedSteps = []
        isGenerating = false
        currentStepIndex = 0
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
