import SwiftUI

struct PersonaCategory {
    let title: String
    let personas: [Persona]
}

struct BookshelfView: View {
    private let personas = PersonaData.shared.getAllPersonas()
    @State private var selectedPersona: Persona?
    @State private var navigateToChat = false
    @State private var searchText = ""
    @State private var showSearchBar = false
    @Environment(\.dismiss) private var dismiss

    private var categories: [PersonaCategory] {
        [
            PersonaCategory(title: "テクノロジー & イノベーション", personas: personas.filter { ["steve-jobs", "alan-turing"].contains($0.id) }),
            PersonaCategory(title: "哲学者たち", personas: personas.filter { ["aristotle"].contains($0.id) }),
            PersonaCategory(title: "芸術家 & 万能人", personas: personas.filter { ["leonardo-da-vinci"].contains($0.id) }),
            PersonaCategory(title: "科学者", personas: personas.filter { ["albert-einstein"].contains($0.id) }),
            PersonaCategory(title: "ミュージシャン", personas: personas.filter { ["avicii", "john-lennon"].contains($0.id) }),
            PersonaCategory(title: "スピリチュアルリーダー", personas: personas.filter { ["mother-teresa", "jesus-christ", "buddha"].contains($0.id) }),
            PersonaCategory(title: "スポーツ", personas: personas.filter { ["shigeo-nagashima"].contains($0.id) }),
            PersonaCategory(title: "すべての偉人", personas: personas)
        ].filter { !$0.personas.isEmpty }
    }

    private var filteredCategories: [PersonaCategory] {
        if searchText.isEmpty {
            return categories
        } else {
            return categories.compactMap { category in
                let filtered = category.personas.filter { persona in
                    persona.name.localizedCaseInsensitiveContains(searchText) ||
                    persona.nameEn.localizedCaseInsensitiveContains(searchText) ||
                    persona.title.localizedCaseInsensitiveContains(searchText)
                }
                return filtered.isEmpty ? nil : PersonaCategory(title: category.title, personas: filtered)
            }
        }
    }

    var body: some View {
        ZStack {
            // Netflix風の黒背景
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // ヘッダー
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .semibold))
                            Text("戻る")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.white)
                    }

                    Spacer()

                    Text("偉人を選ぶ")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)

                    Spacer()

                    // 検索アイコン
                    Button(action: {
                        withAnimation {
                            showSearchBar.toggle()
                            if !showSearchBar {
                                searchText = ""
                            }
                        }
                    }) {
                        Image(systemName: showSearchBar ? "xmark" : "magnifyingglass")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                    }
                }
                .frame(height: 44)
                .padding(.horizontal, 16)
                .background(Color.black)

                // 検索バー（条件付き表示）
                if showSearchBar {
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray.opacity(0.6))
                            .font(.system(size: 16))

                        TextField("偉人を検索", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.system(size: 15))
                            .foregroundColor(.white)

                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray.opacity(0.5))
                                    .font(.system(size: 16))
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(8)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                // カテゴリー別スクロールビュー
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 24) {
                        ForEach(Array(filteredCategories.enumerated()), id: \.offset) { index, category in
                            CategoryRowView(
                                category: category,
                                onPersonaTapped: { persona in
                                    selectedPersona = persona
                                    navigateToChat = true
                                }
                            )
                        }
                    }
                    .padding(.bottom, 40)
                }
            }

            // NavigationLink（非表示）
            NavigationLink(
                destination: selectedPersona.map { ChatView(persona: $0) },
                isActive: $navigateToChat
            ) {
                EmptyView()
            }
            .hidden()
        }
        .navigationBarHidden(true)
    }
}

// Netflix風のカテゴリー行ビュー
struct CategoryRowView: View {
    let category: PersonaCategory
    let onPersonaTapped: (Persona) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // カテゴリータイトル
            Text(category.title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 16)

            // 横スクロールカルーセル
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(category.personas) { persona in
                        NetflixPersonaCard(persona: persona)
                            .onTapGesture {
                                onPersonaTapped(persona)
                            }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

// Netflix風のPersonaカード
struct NetflixPersonaCard: View {
    let persona: Persona
    @State private var isPressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // メイン画像
            ZStack(alignment: .bottomLeading) {
                AsyncImage(url: persona.avatarURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    ZStack {
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.gray.opacity(0.3),
                                Color.gray.opacity(0.5)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        Text(String(persona.nameEn.prefix(1)))
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
                .frame(width: 140, height: 200)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )

                // グラデーションオーバーレイ（下部）
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.clear,
                        Color.black.opacity(0.7)
                    ]),
                    startPoint: .center,
                    endPoint: .bottom
                )
                .frame(height: 200)
                .cornerRadius(8)
            }
            .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 4)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isPressed)

            // 名前
            Text(persona.name)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(2)
                .frame(width: 140, alignment: .leading)
                .minimumScaleFactor(0.9)

            // 時代
            Text(persona.era)
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(.gray)
                .frame(width: 140, alignment: .leading)
        }
        .frame(width: 140)
        .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

struct BookshelfView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            BookshelfView()
        }
    }
}
