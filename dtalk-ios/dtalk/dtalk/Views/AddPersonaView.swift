import SwiftUI

struct AddPersonaView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AddPersonaViewModel()
    @State private var personaName: String = ""
    @FocusState private var isInputFocused: Bool
    @State private var showCompletionSheet = false
    @State private var blinkOpacity: Double = 1.0

    // 人物生成完了時のコールバック
    var onPersonaGenerated: ((Persona) -> Void)?

    var body: some View {
        ZStack {
            // 黒色背景
            Color.black
                .ignoresSafeArea()

            if viewModel.isGenerating {
                // 進捗表示エリア
                VStack(spacing: 30) {
                    Spacer()

                    // 大きな絵文字アニメーション
                    Text(viewModel.currentStepEmoji)
                        .font(.system(size: 80))
                        .scaleEffect(viewModel.currentProgress > 0 ? 1.0 : 0.8)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: viewModel.currentStepEmoji)

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

                    // プログレスバー
                    VStack(spacing: 8) {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // 背景
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white.opacity(0.2))
                                    .frame(height: 20)

                                // 進捗
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
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

                    // 完了したステップのリスト
                    if !viewModel.completedSteps.isEmpty {
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
                        .padding(.horizontal, 40)
                        .padding(.top, 10)
                    }

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
                    }

                    // 入力フィールド
                    VStack(spacing: 15) {
                        TextField("人物名を入力（例：夏目漱石）", text: $personaName)
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
                        Task {
                            await viewModel.generatePersona(name: personaName)
                            if viewModel.generatedPersona != nil {
                                // 生成完了画面を表示
                                showCompletionSheet = true
                            }
                        }
                    }) {
                        HStack {
                            if viewModel.isLoading && !viewModel.isGenerating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                    .scaleEffect(0.8)
                            }
                            Text(viewModel.isLoading ? "生成中..." : "人物を生成")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(personaName.isEmpty || viewModel.isLoading ? Color.gray : Color.white)
                        .cornerRadius(25)
                        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.horizontal, 30)
                    .disabled(personaName.isEmpty || viewModel.isLoading)

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
                    onStartChat: {
                        // 完了画面を閉じてから会話画面へ
                        showCompletionSheet = false
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            onPersonaGenerated?(generatedPersona)
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
    }
}

#Preview {
    NavigationStack {
        AddPersonaView()
    }
}
