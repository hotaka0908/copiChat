import SwiftUI

struct PersonaCarouselView: View {
    @ObservedObject private var personaData = PersonaData.shared
    @ObservedObject private var appSettings = AppSettings.shared
    @State private var currentRotation: Double = 0
    @State private var dragStartRotation: Double = 0
    @State private var isDragging = false
    @State private var navigateToChat = false
    @State private var selectedPersona: Persona?
    @State private var showingPersonaDetail = false
    @State private var navigateToPersonaList = false
    @State private var navigateToBookshelf = false
    @State private var navigateToSettings = false
    @State private var carouselRefreshKey = UUID()

    private let radius: CGFloat = 180
    private var personas: [Persona] {
        // マイリストの人物を表示
        personaData.getMyListPersonas()
    }
    private var angleStep: Double {
        360.0 / Double(personas.count)
    }

    var body: some View {
        GeometryReader { fullGeometry in
            ZStack {
                // 黒色背景
                Color.black
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // トークアイコンと本アイコン
                    HStack {
                        Spacer()

                        // 本アイコン
                        Button(action: {
                            navigateToBookshelf = true
                        }) {
                            Image(systemName: "book.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .padding()
                        }

                        // トークアイコン
                        Button(action: {
                            navigateToPersonaList = true
                        }) {
                            Image(systemName: "message.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .padding()
                        }

                        // プロフィール画像（設定へのリンク）
                        Button(action: {
                            navigateToSettings = true
                        }) {
                            if let profileImage = appSettings.userProfileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 36, height: 36)
                                    .clipShape(Circle())
                                    .padding(.horizontal, 8)
                            } else {
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.3))
                                        .frame(width: 36, height: 36)

                                    Image(systemName: "person.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 8)
                            }
                        }
                    }
                    .padding(.top, 10)
                    .padding(.horizontal, 10)

                    // ヘッダー
                    VStack(spacing: 6) {
                        Text("select_person_prompt")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(.white)

                        Text("swipe_to_select")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.top, 40)

                    Spacer()

                    // 選択ボタン
                    VStack(spacing: 15) {
                        Button(action: selectCurrentPerson) {
                            Text("talk_with_person")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.white)
                                .cornerRadius(25)
                                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        }
                        .padding(.horizontal, 30)
                    }
                    .padding(.bottom, 30)
                }

                // カルーセルコンテナ（画面中央に配置）
                ZStack {
                    ForEach(Array(personas.enumerated()), id: \.element.id) { index, persona in
                        PersonaCard3D(
                            persona: persona,
                            index: index,
                            currentRotation: currentRotation,
                            angleStep: angleStep,
                            radius: radius,
                            containerSize: CGSize(width: fullGeometry.size.width, height: 350),
                            onTap: {
                                // 中央の人物のみタップ可能
                                let angle = (angleStep * Double(index) - currentRotation) * .pi / 180
                                let z = cos(angle) * radius - radius
                                if abs(z) < 30 {
                                    selectedPersona = persona
                                    showingPersonaDetail = true
                                }
                            }
                        )
                    }
                }
                .id(carouselRefreshKey)
                .frame(width: fullGeometry.size.width, height: 350)
                .position(x: fullGeometry.size.width / 2, y: fullGeometry.size.height / 2)
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            if !isDragging {
                                isDragging = true
                                dragStartRotation = currentRotation
                            }
                            let dragAmount = value.translation.width
                            currentRotation = dragStartRotation - dragAmount * 0.3
                        }
                        .onEnded { value in
                            isDragging = false

                            // 慣性スクロール：速度に応じて追加回転
                            let velocity = value.predictedEndTranslation.width - value.translation.width
                            let extraRotation = -velocity * 0.15
                            currentRotation += extraRotation

                            snapToNearest()
                        }
                )
            }

        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToChat) {
            if let persona = selectedPersona {
                ChatView(persona: persona).id(persona.id)
            }
        }
        .navigationDestination(isPresented: $navigateToPersonaList) {
            PersonaListView()
        }
        .navigationDestination(isPresented: $navigateToBookshelf) {
            BookshelfView()
        }
        .navigationDestination(isPresented: $navigateToSettings) {
            SettingsView()
        }
        .onChange(of: navigateToChat) {
            if !navigateToChat {
                // ナビゲーションから戻った時に選択状態をクリア
                selectedPersona = nil
            }
        }
        .onChange(of: navigateToBookshelf) {
            // Bookshelfから戻ってきたときに画像を再読み込み
            if !navigateToBookshelf {
                // 少し遅延させて確実に再生成
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    carouselRefreshKey = UUID()
                }
            }
        }
        .sheet(isPresented: $showingPersonaDetail) {
            if let persona = selectedPersona {
                PersonaDetailView(persona: persona, onStartChat: {
                    showingPersonaDetail = false
                    navigateToChat = true
                })
            }
        }
        .onChange(of: personaData.myListPersonaIds) {
            // マイリストが変更されたらカルーセルの位置をリセット
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                currentRotation = 0
            }
        }
    }

    private func snapToNearest() {
        let nearestAngle = round(currentRotation / angleStep) * angleStep
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75, blendDuration: 0)) {
            currentRotation = nearestAngle
        }
    }

    private func getCurrentPersonIndex() -> Int {
        let normalizedRotation = ((currentRotation.truncatingRemainder(dividingBy: 360)) + 360).truncatingRemainder(dividingBy: 360)
        let index = Int(round(normalizedRotation / angleStep)) % personas.count
        return index
    }

    private func selectCurrentPerson() {
        let index = getCurrentPersonIndex()
        selectedPersona = personas[index]
        navigateToChat = true
    }
}

struct PersonaCard3D: View {
    let persona: Persona
    let index: Int
    let currentRotation: Double
    let angleStep: Double
    let radius: CGFloat
    let containerSize: CGSize
    let onTap: () -> Void

    var body: some View {
        let angle = (angleStep * Double(index) - currentRotation) * .pi / 180
        let x = sin(angle) * radius
        let z = cos(angle) * radius - radius

        let distanceFromFront = abs(z)
        let maxDistance = radius * 2
        let scale = max(0.3, 1.3 - (distanceFromFront / maxDistance) * 1.0)
        let opacity = max(0.15, 1 - (distanceFromFront / maxDistance) * 0.85)

        let isCenter = abs(z) < 30

        // 滑らかなY軸オフセットの計算
        let maxOffsetDistance: CGFloat = 100
        let smoothYOffset = max(0, 40 * (1 - min(1, abs(z) / maxOffsetDistance)))

        return VStack(spacing: 10) {
            // 人物画像
            ZStack {
                if let url = persona.avatarURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ZStack {
                                Color.white
                                ProgressView()
                                    .tint(.gray)
                            }
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            ZStack {
                                Color.white
                                Text(String(persona.nameEn.prefix(1)))
                                    .font(.system(size: 55, weight: .semibold))
                                    .foregroundColor(.gray)
                            }
                        @unknown default:
                            ZStack {
                                Color.white
                                Text(String(persona.nameEn.prefix(1)))
                                    .font(.system(size: 55, weight: .semibold))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                } else {
                    ZStack {
                        Color.white
                        Text(String(persona.nameEn.prefix(1)))
                            .font(.system(size: 55, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                }
            }
            .frame(width: 180, height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay(
                Group {
                    if !isCenter {
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.white.opacity(0.2), lineWidth: 3)
                    }
                }
            )
            .shadow(
                color: .black.opacity(isCenter ? 0.6 : 0.4),
                radius: isCenter ? 20 : 8,
                x: 0,
                y: isCenter ? 10 : 4
            )

            // すべての人物の名前を画像の下に表示
            Text(persona.name)
                .font(.system(
                    size: isCenter ? 20 : 12,
                    weight: isCenter ? .bold : .medium
                ))
                .foregroundColor(.white)
                .opacity(isCenter ? 1.0 : 0.2)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                .frame(maxWidth: 150)
                .multilineTextAlignment(.center)
                .lineLimit(isCenter ? 1 : 2)
                .minimumScaleFactor(isCenter ? 0.5 : 1.0)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(width: containerSize.width, height: containerSize.height)
        .offset(x: x, y: smoothYOffset)
        .scaleEffect(scale)
        .opacity(opacity)
        .zIndex(100 + z)
        .rotation3DEffect(
            .degrees(-angleStep * Double(index) + currentRotation),
            axis: (x: 0, y: 1, z: 0),
            perspective: 0
        )
        .onTapGesture {
            onTap()
        }
    }
}

struct PersonaDetailView: View {
    let persona: Persona
    let onStartChat: () -> Void
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var personaData = PersonaData.shared
    @State private var showMyListFullAlert = false

    var isInMyList: Bool {
        personaData.isInMyList(persona.id)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // ヘッダー
                HStack {
                    Spacer()

                    // マイリスト追加/削除ボタン
                    Button(action: {
                        withAnimation {
                            if isInMyList {
                                personaData.removeFromMyList(persona.id)
                            } else {
                                // 上限チェック
                                if personaData.isMyListFull() {
                                    showMyListFullAlert = true
                                } else {
                                    personaData.addToMyList(persona.id)
                                }
                            }
                        }
                    }) {
                        Image(systemName: isInMyList ? "heart.fill" : "heart")
                            .font(.system(size: 28))
                            .foregroundColor(isInMyList ? .red : .gray)
                    }
                    .padding(.trailing, 8)

                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)

                // 人物画像
                ZStack {
                    if let url = persona.avatarURL {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            ZStack {
                                Color.white
                                Text(String(persona.nameEn.prefix(1)))
                                    .font(.system(size: 60, weight: .bold))
                                    .foregroundColor(.gray)
                            }
                        }
                    } else {
                        ZStack {
                            Color.white
                            Text(String(persona.nameEn.prefix(1)))
                                .font(.system(size: 60, weight: .bold))
                                .foregroundColor(.gray)
                        }
                    }
                }
                .frame(width: 200, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)

                // 名前と時代
                VStack(spacing: 8) {
                    Text(persona.name)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primary)

                    Text(persona.nameEn)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.secondary)

                    Text(persona.era)
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }

                // 肩書き
                Text(persona.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // 専門分野
                VStack(alignment: .leading, spacing: 12) {
                    Text("specialties")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.secondary)

                    FlowLayout(spacing: 8) {
                        ForEach(persona.specialties, id: \.self) { specialty in
                            Text(specialty)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.primary)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                        }
                    }
                }
                .padding(.horizontal)

                // 歴史的背景
                VStack(alignment: .leading, spacing: 12) {
                    Text("profile")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.secondary)

                    Text(persona.historicalContext)
                        .font(.system(size: 15))
                        .foregroundColor(.primary)
                        .lineSpacing(4)
                }
                .padding(.horizontal)

                // 哲学・信念
                if !persona.traits.philosophy.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("philosophy_beliefs")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.secondary)

                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(persona.traits.philosophy.prefix(3), id: \.self) { philosophy in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("•")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.primary)
                                    Text(philosophy)
                                        .font(.system(size: 15))
                                        .foregroundColor(.primary)
                                        .lineSpacing(4)
                                    Spacer()
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // 名言
                if !persona.traits.famousQuotes.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("famous_quotes")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.secondary)

                        VStack(spacing: 12) {
                            ForEach(persona.traits.famousQuotes.prefix(2), id: \.self) { quote in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("\"")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.secondary.opacity(0.5))
                                        .offset(y: -4)

                                    Text(quote)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(.primary)
                                        .italic()
                                        .lineSpacing(4)

                                    Spacer()
                                }
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // キーフレーズ
                if !persona.traits.keyPhrases.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("key_phrases")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.secondary)

                        FlowLayout(spacing: 8) {
                            ForEach(persona.traits.keyPhrases.prefix(5), id: \.self) { phrase in
                                Text(phrase)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // この人と話すボタン
                Button(action: {
                    onStartChat()
                }) {
                    Text("talk_with_person")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(25)
                        .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
                }
                .padding(.top, 10)
                .padding(.bottom, 30)
            }
        }
        .alert("my_list_full_title", isPresented: $showMyListFullAlert) {
            Button("ok", role: .cancel) { }
        } message: {
            Text("my_list_full_message")
        }
    }
}

// カスタムFlowLayout
struct FlowLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: currentX, y: currentY))
                currentX += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }

            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

#Preview {
    NavigationStack {
        PersonaCarouselView()
    }
}
