import Foundation

class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @Published var apiBaseURL: String {
        didSet {
            UserDefaults.standard.set(apiBaseURL, forKey: "apiBaseURL")
        }
    }

    private init() {
        #if DEBUG
        self.apiBaseURL = UserDefaults.standard.string(forKey: "apiBaseURL") ?? "http://localhost:3000"
        #else
        self.apiBaseURL = UserDefaults.standard.string(forKey: "apiBaseURL") ?? "https://your-dtalk-app.vercel.app"
        #endif
    }

    func resetToDefaults() {
        #if DEBUG
        apiBaseURL = "http://localhost:3000"
        #else
        apiBaseURL = "https://your-dtalk-app.vercel.app"
        #endif
    }
}
