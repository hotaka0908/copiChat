import Foundation

class PersonaGenerationLimitManager: ObservableObject {
    static let shared = PersonaGenerationLimitManager()

    private let userDefaults = UserDefaults.standard
    private let remainingGenerationsKey = "remainingPersonaGenerations"

    @Published var remainingGenerations: Int {
        didSet {
            userDefaults.set(remainingGenerations, forKey: remainingGenerationsKey)
        }
    }

    private init() {
        // 初回起動時は3回に設定
        if userDefaults.object(forKey: remainingGenerationsKey) == nil {
            self.remainingGenerations = 3
            userDefaults.set(3, forKey: remainingGenerationsKey)
        } else {
            self.remainingGenerations = userDefaults.integer(forKey: remainingGenerationsKey)
        }
    }

    /// 生成可能かチェック
    func canGenerate() -> Bool {
        return remainingGenerations > 0
    }

    /// 生成回数を1回減らす
    func consumeGeneration() {
        if remainingGenerations > 0 {
            remainingGenerations -= 1
        }
    }

    /// 共有で2回追加
    func addGenerationsFromShare() {
        remainingGenerations += 2
        print("✅ 共有特典: 生成回数を2回追加しました（残り: \(remainingGenerations)回）")
    }

    /// リセット（デバッグ用）
    func reset() {
        remainingGenerations = 3
    }
}
