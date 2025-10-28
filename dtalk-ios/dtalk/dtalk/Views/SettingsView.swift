import SwiftUI
import PhotosUI

struct SettingsView: View {
    @ObservedObject private var appSettings = AppSettings.shared
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            // プロフィール設定
            Section(header: Text("プロフィール")) {
                HStack {
                    Spacer()

                    Button(action: {
                        showImagePicker = true
                    }) {
                        if let profileImage = appSettings.userProfileImage {
                            Image(uiImage: profileImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1))
                        } else {
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 80, height: 80)

                                Image(systemName: "person.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                            }
                        }
                    }

                    Spacer()
                }
                .padding(.vertical, 8)

                NavigationLink(destination: ProfileNameEditView()) {
                    HStack {
                        Text("名前")
                        Spacer()
                        Text(appSettings.userName.isEmpty ? "未設定" : appSettings.userName)
                            .foregroundColor(.secondary)
                    }
                }
            }

            // サポート
            Section(header: Text("サポート")) {
                NavigationLink(destination: ContactView()) {
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.blue)
                        Text("お問い合わせ")
                    }
                }

                Link(destination: URL(string: "https://dtalk-dusky.vercel.app/terms")!) {
                    HStack {
                        Image(systemName: "doc.text.fill")
                            .foregroundColor(.blue)
                        Text("利用規約")
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }

                Link(destination: URL(string: "https://dtalk-dusky.vercel.app/privacy")!) {
                    HStack {
                        Image(systemName: "shield.fill")
                            .foregroundColor(.blue)
                        Text("プライバシーポリシー")
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
            }

            // アプリ情報
            Section(header: Text("アプリ情報")) {
                HStack {
                    Text("バージョン")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("設定")
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
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .onChange(of: selectedImage) { oldValue, newValue in
            if let image = newValue {
                appSettings.userProfileImage = image
                selectedImage = nil // リセット
            }
        }
    }
}

// ImagePicker for selecting profile image
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    SettingsView()
}
