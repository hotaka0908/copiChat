import SwiftUI
import PhotosUI

struct SettingsView: View {
    @ObservedObject private var appSettings = AppSettings.shared
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            // プロフィール画像
            Section {
                VStack(spacing: 16) {
                    // プロフィール画像とカメラボタン
                    ZStack(alignment: .bottomTrailing) {
                        Button(action: {
                            showImagePicker = true
                        }) {
                            if let profileImage = appSettings.userProfileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                            } else {
                                ZStack {
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 120, height: 120)

                                    Image(systemName: "person.fill")
                                        .font(.system(size: 50))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .buttonStyle(.plain)

                        // カメラボタン
                        Button(action: {
                            showImagePicker = true
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.9))
                                    .frame(width: 44, height: 44)

                                Image(systemName: "camera.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                            }
                        }
                        .offset(x: -4, y: -4)
                    }

                    // 名前（表示のみ）
                    Text(appSettings.userName.isEmpty ? String(localized: "set_name") : appSettings.userName)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())

            // 名前編集
            Section {
                NavigationLink(destination: ProfileNameEditView()) {
                    HStack {
                        Text("name")
                        Spacer()
                        Text(appSettings.userName.isEmpty ? String(localized: "not_set") : appSettings.userName)
                            .foregroundColor(.secondary)
                    }
                }
            }

            // サポート
            Section(header: Text("support")) {
                NavigationLink(destination: ContactView()) {
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.black)
                        Text("contact_us")
                    }
                }

                Link(destination: URL(string: "https://copichat.vercel.app/terms")!) {
                    HStack {
                        Image(systemName: "doc.text.fill")
                            .foregroundColor(.black)
                        Text("terms_of_service")
                            .foregroundColor(.black)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }

                Link(destination: URL(string: "https://copichat.vercel.app/privacy")!) {
                    HStack {
                        Image(systemName: "shield.fill")
                            .foregroundColor(.black)
                        Text("privacy_policy")
                            .foregroundColor(.black)
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
            }

            // アプリ情報
            Section(header: Text("app_info")) {
                HStack {
                    Text("version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("settings")
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
