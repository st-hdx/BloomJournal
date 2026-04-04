import SwiftUI

enum Theme {
    static let background   = Color(red: 0.99, green: 0.96, blue: 0.85)  // 温かみのある薄黄
    static let card         = Color(red: 1.00, green: 0.99, blue: 0.93)  // クリーム白
    static let cardBorder   = Color(red: 0.25, green: 0.18, blue: 0.10).opacity(0.12)
    static let cardShadow   = Color(red: 0.25, green: 0.18, blue: 0.10)
    static let text         = Color(red: 0.25, green: 0.18, blue: 0.10)  // 深い温かいブラウン
    static let secondaryText = Color(red: 0.25, green: 0.18, blue: 0.10).opacity(0.50)
    static let tertiaryText = Color(red: 0.25, green: 0.18, blue: 0.10).opacity(0.30)
    static let accent1      = Color(red: 0.88, green: 0.55, blue: 0.12)  // アンバー
    static let accent2      = Color(red: 0.82, green: 0.32, blue: 0.42)  // ローズ
    static let ringBg       = Color(red: 0.91, green: 0.87, blue: 0.76)

    static let accentGradient = LinearGradient(
        colors: [accent1, accent2],
        startPoint: .leading,
        endPoint: .trailing
    )

    static func cardStyle() -> some ViewModifier {
        CardModifier()
    }
}

private struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Theme.cardBorder, lineWidth: 1)
            )
            .shadow(color: Theme.cardShadow.opacity(0.08), radius: 6, y: 2)
    }
}

extension View {
    func cardStyle() -> some View {
        self.modifier(Theme.cardStyle())
    }
}

// MARK: - TextInputSheet

struct TextInputSheet: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    let buttonLabel: String
    let onConfirm: () -> Void

    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool

    private var trimmed: String { text.trimmingCharacters(in: .whitespaces) }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {
                Text(title)
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundColor(Theme.text)

                TextField(placeholder, text: $text)
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(Theme.text)
                    .focused($isFocused)
                    .submitLabel(.done)
                    .onSubmit { submit() }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .cardStyle()

                Button(action: submit) {
                    Text(buttonLabel)
                        .font(.system(.body, design: .rounded).weight(.semibold))
                        .foregroundColor(trimmed.isEmpty ? Theme.secondaryText : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            trimmed.isEmpty
                            ? AnyShapeStyle(Theme.ringBg)
                            : AnyShapeStyle(Theme.accentGradient)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: trimmed.isEmpty ? .clear : Theme.accent1.opacity(0.3), radius: 8, y: 3)
                }
                .disabled(trimmed.isEmpty)
            }
            .padding(.horizontal, 24)
            .padding(.top, 28)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .presentationDetents([.height(260)])
        .presentationDragIndicator(.visible)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { isFocused = true }
        }
    }

    private func submit() {
        guard !trimmed.isEmpty else { return }
        onConfirm()
        dismiss()
    }
}
