import SwiftUI

struct AddPersonaView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AddPersonaViewModel()
    @State private var personaName: String = ""
    @FocusState private var isInputFocused: Bool

    var body: some View {
        ZStack {
            // 黒色背景
            Color.black
                .ignoresSafeArea()

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
                            dismiss()
                        }
                    }
                }) {
                    HStack {
                        if viewModel.isLoading {
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
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
        .onTapGesture {
            isInputFocused = false
        }
    }
}

#Preview {
    NavigationStack {
        AddPersonaView()
    }
}
