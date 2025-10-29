import SwiftUI

struct ChatView: View {
    let persona: Persona
    @StateObject private var viewModel: ChatViewModel
    @FocusState private var isInputFocused: Bool
    @Environment(\.dismiss) private var dismiss

    init(persona: Persona) {
        self.persona = persona
        _viewModel = StateObject(wrappedValue: ChatViewModel(persona: persona))
    }

    var body: some View {
        VStack(spacing: 0) {
            // メッセージリスト
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.messages) { message in
                            MessageRow(message: message, persona: persona)
                                .id(message.id)
                        }

                        if viewModel.isLoading {
                            LoadingIndicator(persona: persona)
                        }
                    }
                    .padding()
                }
                .onTapGesture {
                    // メッセージリストをタップしたらキーボードを閉じる
                    isInputFocused = false
                }
                .onChange(of: viewModel.messages.count) {
                    if let lastMessage = viewModel.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            .background(Color(.systemGroupedBackground))

            Divider()

            // 入力エリア
            InputArea(
                text: $viewModel.currentInput,
                isLoading: viewModel.isLoading,
                persona: persona,
                isFocused: $isInputFocused,
                hasReachedLimit: viewModel.hasReachedMessageLimit,
                isInMyList: viewModel.isInMyList,
                onSend: {
                    // キーボードを閉じる
                    isInputFocused = false
                    Task {
                        await viewModel.sendMessage()
                    }
                }
            )
            .background(Color(.systemBackground))
        }
        .navigationTitle(persona.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarColorScheme(.light, for: .navigationBar)
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
                Menu {
                    Button(role: .destructive, action: {
                        viewModel.clearMessages()
                    }) {
                        Label("clear_conversation", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.black)
                }
            }
        }
        .tint(.black)
    }
}

struct MessageRow: View {
    let message: Message
    let persona: Persona

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if message.role == .assistant {
                // アシスタントのアバター
                AsyncImage(url: persona.avatarURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.3))
                        Text(persona.nameEn.prefix(1))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            }

            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.system(size: 16))
                    .foregroundColor(message.role == .user ? .white : .primary)
                    .padding(12)
                    .background(
                        message.role == .user
                            ? Color.blue
                            : Color(.systemBackground)
                    )
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)

                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 10))
                    Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                        .font(.system(size: 12))
                }
                .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: message.role == .user ? .trailing : .leading)
        }
    }
}

struct LoadingIndicator: View {
    let persona: Persona

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: persona.avatarURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                    Text(persona.nameEn.prefix(1))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
            }
            .frame(width: 40, height: 40)
            .clipShape(Circle())

            HStack(spacing: 8) {
                ProgressView()
                    .scaleEffect(0.8)
                Text("thinking")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .padding(12)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)

            Spacer()
        }
    }
}

struct InputArea: View {
    @Binding var text: String
    let isLoading: Bool
    let persona: Persona
    var isFocused: FocusState<Bool>.Binding
    let hasReachedLimit: Bool
    let isInMyList: Bool
    let onSend: () -> Void
    @ObservedObject private var personaData = PersonaData.shared

    var body: some View {
        VStack(spacing: 8) {
            // 制限メッセージ
            if hasReachedLimit {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(.orange)
                    Text("free_message_limit")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)

                    Button(action: {
                        if !personaData.isMyListFull() {
                            personaData.addToMyList(persona.id)
                        }
                    }) {
                        Text("add")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(personaData.isMyListFull() ? Color.gray : Color.blue)
                            .cornerRadius(12)
                    }
                    .disabled(personaData.isMyListFull())
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 4)
            }

            HStack(alignment: .bottom, spacing: 12) {
                // テキスト入力
                TextField("", text: $text, axis: .vertical)
                    .textFieldStyle(.plain)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
                    .lineLimit(1...5)
                    .focused(isFocused)
                    .disabled(isLoading || hasReachedLimit)
                    .onSubmit {
                        if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !hasReachedLimit {
                            onSend()
                        }
                    }

                // 送信ボタン
                Button(action: onSend) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading || hasReachedLimit ? .gray : .blue)
                }
                .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading || hasReachedLimit)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    NavigationStack {
        ChatView(persona: Persona.preview)
    }
}
