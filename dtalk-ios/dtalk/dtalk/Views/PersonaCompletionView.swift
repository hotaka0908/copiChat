import SwiftUI

struct PersonaCompletionView: View {
    let persona: Persona
    let onStartChat: () -> Void
    let onClose: () -> Void

    var body: some View {
        ZStack {
            // 黒色背景
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 30) {
                Spacer()

                // チェックマークアニメーション
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 100, height: 100)

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                }
                .scaleEffect(1.0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: persona.id)

                // 完了メッセージ
                Text("人物誕生！")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)

                // 人物カード
                VStack(spacing: 20) {
                    // 人物画像
                    if let url = URL(string: persona.avatar), !persona.avatar.isEmpty {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 120, height: 120)
                                    .overlay(
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    )
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white.opacity(0.2), lineWidth: 3)
                                    )
                            case .failure:
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 120, height: 120)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.white.opacity(0.5))
                                    )
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 120, height: 120)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white.opacity(0.5))
                            )
                    }

                    // 人物名
                    Text(persona.name)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)

                    // タイトル（職業）
                    Text(persona.title)
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)

                    // 時代
                    Text(persona.era)
                        .font(.system(size: 14))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.vertical, 30)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.1))
                )
                .padding(.horizontal, 30)

                Spacer()

                // ボタン
                VStack(spacing: 15) {
                    // 会話を始めるボタン
                    Button(action: onStartChat) {
                        HStack {
                            Image(systemName: "message.fill")
                                .font(.system(size: 16))
                            Text("会話を始める")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(25)
                        .shadow(color: .white.opacity(0.3), radius: 8, x: 0, y: 4)
                    }

                    // 戻るボタン
                    Button(action: onClose) {
                        Text("戻る")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    PersonaCompletionView(
        persona: Persona(
            id: "preview",
            name: "テスト太郎",
            nameEn: "Test Taro",
            era: "2000-2025",
            title: "テストエンジニア",
            avatar: "",
            systemPrompt: "テスト用",
            backgroundGradient: ["blue-500", "purple-600"],
            textColor: "white",
            traits: PersonaTraits(
                speechPattern: [],
                philosophy: [],
                decisionMaking: "",
                keyPhrases: [],
                famousQuotes: []
            ),
            specialties: [],
            historicalContext: "",
            category: .science
        ),
        onStartChat: {},
        onClose: {}
    )
}
