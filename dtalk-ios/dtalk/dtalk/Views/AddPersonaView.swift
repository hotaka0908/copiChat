import SwiftUI

struct AddPersonaView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AddPersonaViewModel()
    @StateObject private var limitManager = PersonaGenerationLimitManager.shared
    @State private var personaName: String = ""
    @FocusState private var isInputFocused: Bool
    @State private var showCompletionSheet = false
    @State private var blinkOpacity: Double = 1.0
    @State private var showMyListFullAlert = false
    @State private var showShareSheet = false


    var body: some View {
        ZStack {
            // 黒色背景
            Color.black
                .ignoresSafeArea()

            if viewModel.isGenerating {
                // 進捗表示エリア
                VStack(spacing: 0) {
                    Spacer()

                    // 上部セクション: メッセージ
                    VStack(spacing: 20) {
                        // 現在のステップメッセージ
                        Text(viewModel.currentStepMessage)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .opacity(viewModel.currentStepMessage == "最終調整中" ? blinkOpacity : 1.0)
                            .onChange(of: viewModel.currentStepMessage) { oldValue, newValue in
                                if newValue == "最終調整中" {
                                    // 点滅アニメーション開始
                                    withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                                        blinkOpacity = 0.3
                                    }
                                } else {
                                    // 点滅停止
                                    blinkOpacity = 1.0
                                }
                            }
                    }
                    .frame(height: 180)

                    Spacer()
                        .frame(height: 40)

                    // 中央セクション: プログレスバー（固定位置）
                    VStack(spacing: 8) {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // 背景
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.2))
                                    .frame(height: 20)

                                // 進捗
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white)
                                    .frame(width: geometry.size.width * viewModel.currentProgress, height: 20)
                                    .animation(.linear(duration: 0.1), value: viewModel.currentProgress)
                            }
                        }
                        .frame(height: 20)

                        // パーセンテージ
                        Text("\(Int(viewModel.currentProgress * 100))%")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.horizontal, 40)

                    Spacer()
                        .frame(height: 40)

                    // 下部セクション: 完了したステップのリスト（固定高さ）
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(viewModel.completedSteps, id: \.self) { step in
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.system(size: 14))

                                Text(step)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .transition(.opacity.combined(with: .scale))
                        }
                    }
                    .frame(height: 160, alignment: .top)
                    .padding(.horizontal, 40)

                    Spacer()
                }
                .transition(.opacity)
            } else {
                // 入力エリア
                VStack(spacing: 30) {
                    Spacer()

                    // タイトル
                    VStack(spacing: 10) {
                        Text("新しい人物を追加")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)

                        Text("話したい人物の名前を入力してください")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.8))

                        // 残り生成回数
                        HStack(spacing: 6) {
                            Image(systemName: "person.badge.plus")
                                .font(.system(size: 14))
                            Text("残り\(limitManager.remainingGenerations)回")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(limitManager.remainingGenerations > 0 ? .green : .orange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                    }

                    // 入力フィールド
                    VStack(spacing: 15) {
                        TextField("例：ウォルト・ディズニー", text: $personaName)
                            .font(.system(size: 18))
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .focused($isInputFocused)
                            .disabled(viewModel.isLoading)

                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.horizontal, 30)

                    // 生成ボタン
                    Button(action: {
                        // 残り回数チェック
                        if limitManager.remainingGenerations <= 0 {
                            // 共有シートを表示
                            showShareSheet = true
                        } else {
                            Task {
                                await viewModel.generatePersona(name: personaName)
                                if viewModel.generatedPersona != nil {
                                    // 生成完了画面を表示
                                    showCompletionSheet = true
                                }
                            }
                        }
                    }) {
                        HStack {
                            if viewModel.isLoading && !viewModel.isGenerating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                    .scaleEffect(0.8)
                            }
                            if limitManager.remainingGenerations <= 0 {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 16))
                            }
                            Text(limitManager.remainingGenerations <= 0 ? "友達に共有して生成回数を増やす" : (viewModel.isLoading ? "生成中..." : "人物を生成"))
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(limitManager.remainingGenerations <= 0 ? Color.orange : (personaName.isEmpty || viewModel.isLoading ? Color.gray : Color.white))
                        .cornerRadius(25)
                        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 30)
                    .disabled(limitManager.remainingGenerations > 0 && (personaName.isEmpty || viewModel.isLoading))

                    Spacer()
                }
                .transition(.opacity)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    viewModel.resetProgress()
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
                .disabled(viewModel.isGenerating)
            }
        }
        .onTapGesture {
            if !viewModel.isGenerating {
                isInputFocused = false
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.isGenerating)
        .sheet(isPresented: $showCompletionSheet) {
            if let generatedPersona = viewModel.generatedPersona {
                PersonaCompletionView(
                    persona: generatedPersona,
                    onAddToMyList: {
                        // 上限チェック
                        if PersonaData.shared.isMyListFull() {
                            // 上限に達している場合はアラートを表示
                            showCompletionSheet = false
                            showMyListFullAlert = true
                        } else {
                            // マイリストに追加
                            PersonaData.shared.addToMyList(generatedPersona.id)
                            // 完了画面を閉じる
                            showCompletionSheet = false
                            // AddPersonaViewを閉じてBookshelfに戻る
                            dismiss()
                        }
                    },
                    onClose: {
                        // 完了画面を閉じてBookshelfに戻る
                        showCompletionSheet = false
                        dismiss()
                    }
                )
            }
        }
        .alert("マイリストがいっぱいです", isPresented: $showMyListFullAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("マイリストは11人までです。他の人物を削除してから追加してください。")
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheetView(onDismiss: {
                // 共有シート閉じた時に+2回付与
                limitManager.addGenerationsFromShare()
                showShareSheet = false
            })
        }
    }
}

// 共有シートView
struct ShareSheetView: View {
    @Environment(\.dismiss) private var dismiss
    let onDismiss: () -> Void

    @State private var showingActivityView = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // アイコン
            Image(systemName: "square.and.arrow.up.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)

            // タイトル
            Text("友達に共有しよう！")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)

            // 説明
            VStack(spacing: 12) {
                Text("アプリを共有すると")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)

                HStack(spacing: 8) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 20))
                        .foregroundColor(.green)
                    Text("生成回数 +2回")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.green)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color.green.opacity(0.1))
                .cornerRadius(16)
            }

            Spacer()

            // 共有ボタン
            Button(action: {
                showingActivityView = true
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 18))
                    Text("共有する")
                        .font(.system(size: 18, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.blue)
                .cornerRadius(25)
                .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal, 30)

            // 後で
            Button(action: {
                dismiss()
            }) {
                Text("後で")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 40)
        }
        .padding()
        .sheet(isPresented: $showingActivityView) {
            ActivityViewController(
                activityItems: ["dtalkアプリで歴史上の偉人と会話しよう！\n様々な偉人とAIチャットが楽しめます。"],
                onComplete: { completed in
                    // 共有が完了したら（キャンセルでも）報酬を付与
                    dismiss()
                    onDismiss()
                }
            )
        }
    }
}

// UIActivityViewControllerのSwiftUIラッパー
struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    let onComplete: (Bool) -> Void

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )

        controller.completionWithItemsHandler = { _, completed, _, _ in
            onComplete(completed)
        }

        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // 更新不要
    }
}

#Preview {
    NavigationStack {
        AddPersonaView()
    }
}
