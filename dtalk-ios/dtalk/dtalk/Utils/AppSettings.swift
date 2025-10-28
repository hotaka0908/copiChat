import Foundation
import UIKit

class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @Published var apiBaseURL: String {
        didSet {
            UserDefaults.standard.set(apiBaseURL, forKey: "apiBaseURL")
        }
    }

    @Published var userName: String {
        didSet {
            UserDefaults.standard.set(userName, forKey: "userName")
        }
    }

    @Published var userProfileImage: UIImage? {
        didSet {
            if let image = userProfileImage,
               let data = image.jpegData(compressionQuality: 0.8) {
                UserDefaults.standard.set(data, forKey: "userProfileImage")
            } else {
                UserDefaults.standard.removeObject(forKey: "userProfileImage")
            }
        }
    }

    private init() {
        #if DEBUG
        self.apiBaseURL = UserDefaults.standard.string(forKey: "apiBaseURL") ?? "http://localhost:3000"
        #else
        self.apiBaseURL = UserDefaults.standard.string(forKey: "apiBaseURL") ?? "https://your-dtalk-app.vercel.app"
        #endif

        self.userName = UserDefaults.standard.string(forKey: "userName") ?? ""

        if let imageData = UserDefaults.standard.data(forKey: "userProfileImage"),
           let image = UIImage(data: imageData) {
            self.userProfileImage = image
        } else {
            self.userProfileImage = nil
        }
    }

    func resetToDefaults() {
        #if DEBUG
        apiBaseURL = "http://localhost:3000"
        #else
        apiBaseURL = "https://your-dtalk-app.vercel.app"
        #endif
    }
}
