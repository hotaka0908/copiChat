import SwiftUI

struct ProfileNameEditView: View {
    @ObservedObject private var appSettings = AppSettings.shared
    @State private var editedUserName: String = ""
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // メインコンテンツ
            VStack(alignment: .leading, spacing: 16) {
                Text("名前")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)

                TextField("名前を入力", text: $editedUserName)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 16))
                    .focused($isTextFieldFocused)
                    .submitLabel(.done)
                    .onSubmit {
                        saveName()
                    }
            }
            .padding()

            Spacer()
        }
        .navigationTitle("名前の編集")
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

            ToolbarItem(placement: .navigationBarTrailing) {
                Button("保存") {
                    saveName()
                }
                .disabled(editedUserName.trimmingCharacters(in: .whitespaces).isEmpty || editedUserName == appSettings.userName)
            }
        }
        .onAppear {
            editedUserName = appSettings.userName
            // 画面表示時にキーボードを表示
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isTextFieldFocused = true
            }
        }
    }

    private func saveName() {
        let trimmedName = editedUserName.trimmingCharacters(in: .whitespaces)
        if !trimmedName.isEmpty && trimmedName != appSettings.userName {
            appSettings.userName = trimmedName
            dismiss()
        }
    }
}

#Preview {
    NavigationView {
        ProfileNameEditView()
    }
}
