import SwiftUI

struct ContactView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showMailError = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // ヘッダー
                VStack(spacing: 12) {
                    Image(systemName: "envelope.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)

                    Text("お問い合わせ")
                        .font(.system(size: 28, weight: .bold))

                    Text("ご質問やご要望がございましたら\nお気軽にお問い合わせください")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)

                // お問い合わせ方法
                VStack(spacing: 16) {
                    ContactMethodCard(
                        icon: "envelope.fill",
                        title: "メールでのお問い合わせ",
                        description: "ho@universalpine.com",
                        action: {
                            openMail()
                        }
                    )
                }
                .padding(.horizontal)

                Spacer()
            }
        }
        .navigationTitle("お問い合わせ")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }
            }
        }
        .alert("メールアプリを開けません", isPresented: $showMailError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("メールアプリが設定されていないか、利用できません。")
        }
    }

    private func openMail() {
        let email = "ho@universalpine.com"
        let subject = "DTalkアプリについてのお問い合わせ"
        let urlString = "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"

        if let url = URL(string: urlString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                showMailError = true
            }
        }
    }
}

struct ContactMethodCard: View {
    let icon: String
    let title: String
    let description: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(.blue)
                    .frame(width: 50, height: 50)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)

                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}

#Preview {
    NavigationView {
        ContactView()
    }
}
