import SwiftUI

struct PersonaListView: View {
    private let personas = PersonaData.shared.getAllPersonas()
    @State private var selectedPersona: Persona?

    // カテゴリごとにグループ化
    private var groupedPersonas: [(PersonaCategory, [Persona])] {
        let grouped = Dictionary(grouping: personas) { $0.category }
        return PersonaCategory.allCases.compactMap { category in
            guard let personas = grouped[category], !personas.isEmpty else { return nil }
            return (category, personas)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // 人物リスト（カテゴリ別）
            List {
                ForEach(groupedPersonas, id: \.0) { category, personas in
                    Section {
                        ForEach(personas) { persona in
                            NavigationLink(destination: ChatView(persona: persona)) {
                                PersonaCard(persona: persona)
                            }
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.visible)
                        }
                    } header: {
                        HStack(spacing: 8) {
                            Image(systemName: category.icon)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.secondary)
                            Text(category.rawValue)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                                .textCase(nil)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .listStyle(.plain)
        }
        .navigationTitle("トーク")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PersonaCard: View {
    let persona: Persona

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

            // 名前
            Text(persona.name)
                .font(.system(size: 17))
                .foregroundColor(.primary)

            Spacer()

            // 矢印アイコン
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.system(size: 14, weight: .semibold))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }
}

#Preview {
    NavigationStack {
        PersonaListView()
    }
}
