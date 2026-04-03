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
