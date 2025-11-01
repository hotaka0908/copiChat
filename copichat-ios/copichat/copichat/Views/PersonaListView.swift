import SwiftUI

struct PersonaListView: View {
    @ObservedObject var personaData = PersonaData.shared
    @State private var selectedPersona: Persona?
    @State private var personaToDelete: Persona?
    @State private var showDeleteAlert = false
    @Environment(\.dismiss) private var dismiss

    // 会話履歴がある人物のみを取得（最新の会話順）
    private var personasWithHistory: [Persona] {
        let personas = PersonaData.shared.getAllPersonas().filter { persona in
            ChatHistoryManager.shared.hasHistory(for: persona.id)
        }

        // 最後のメッセージのタイムスタンプでソート（新しい順）
        return personas.sorted { persona1, persona2 in
            let lastMessage1 = ChatHistoryManager.shared.getLastMessage(for: persona1.id)
            let lastMessage2 = ChatHistoryManager.shared.getLastMessage(for: persona2.id)

            guard let timestamp1 = lastMessage1?.timestamp else { return false }
            guard let timestamp2 = lastMessage2?.timestamp else { return true }

            return timestamp1 > timestamp2
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // 人物リスト
            if personasWithHistory.isEmpty {
                // 会話履歴がない場合の表示
                VStack(spacing: 16) {
                    Image(systemName: "message.slash")
                        .font(.system(size: 64))
                        .foregroundColor(.gray.opacity(0.5))
                    Text("no_chat_history")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.secondary)
                    Text("select_to_start_chat")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(personasWithHistory) { persona in
                        ZStack {
                            NavigationLink(destination: ChatView(persona: persona)) {
                                EmptyView()
                            }
                            .opacity(0)

                            PersonaCard(persona: persona)
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.visible)
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                personaToDelete = persona
                                showDeleteAlert = true
                            } label: {
                                Label("履歴削除", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("chats")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.black)
                }
            }
        }
        .alert("チャット履歴を削除", isPresented: $showDeleteAlert) {
            Button("キャンセル", role: .cancel) { }
            Button("削除", role: .destructive) {
                if let persona = personaToDelete {
                    clearChatHistory(persona)
                }
            }
        } message: {
            if let persona = personaToDelete {
                Text("\(persona.name)とのチャット履歴を削除しますか？")
            }
        }
    }

    private func clearChatHistory(_ persona: Persona) {
        // チャット履歴のみを削除（人物は削除しない）
        ChatHistoryManager.shared.clearMessages(for: persona.id)
    }
}

struct PersonaCard: View {
    let persona: Persona

    private var lastMessage: Message? {
        ChatHistoryManager.shared.getLastMessage(for: persona.id)
    }

    var body: some View {
        HStack(spacing: 16) {
            // アバター
            AsyncImage(url: persona.avatarURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                    Text(persona.nameEn.prefix(1))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
            }
            .frame(width: 52, height: 52)
            .clipShape(Circle())

            // 名前と最後のメッセージ
            VStack(alignment: .leading, spacing: 4) {
                Text(persona.name)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)

                if let lastMessage = lastMessage {
                    Text(lastMessage.content)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                } else {
                    Text("no_messages_yet")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .italic()
                }
            }

            Spacer()

            // 時間
            if let lastMessage = lastMessage {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(formatTimestamp(lastMessage.timestamp))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }

    private func formatTimestamp(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()

        if calendar.isDateInToday(date) {
            // 今日なら時間のみ
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            // 昨日なら「昨日」
            return String(localized: "yesterday")
        } else if calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear) {
            // 今週なら曜日
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            formatter.locale = Locale(identifier: "ja_JP")
            return formatter.string(from: date)
        } else {
            // それ以外は日付
            let formatter = DateFormatter()
            formatter.dateFormat = "M/d"
            return formatter.string(from: date)
        }
    }
}

#Preview {
    NavigationStack {
        PersonaListView()
    }
}
