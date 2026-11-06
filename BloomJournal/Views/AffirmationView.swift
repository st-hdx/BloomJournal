import SwiftUI

struct AffirmationView: View {
    @StateObject private var affirmationStore = AffirmationStore()
    @Environment(\.dismiss) private var dismiss
    @State private var index: Int

    private let affirmations = LocalizedContent.affirmations

    init() {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        _index = State(initialValue: dayOfYear % LocalizedContent.affirmations.count)
    }

    private var current: String { affirmations[index] }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Text("今日の言葉")
                        .font(.system(.headline, design: .rounded).weight(.bold))
                        .foregroundColor(Theme.text)
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(.subheadline).weight(.medium))
                            .foregroundColor(Theme.secondaryText)
                            .frame(width: 32, height: 32)
                            .background(Theme.card)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Theme.cardBorder, lineWidth: 1))
                    }
                    .accessibilityIdentifier("affirmation.close")
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 20)

                // Everything below the header flows naturally in one scroll
                // area instead of being split apart by Spacer()s. Two flexible
                // Spacers here used to divide the remaining height evenly
                // above and below the quote regardless of screen size, which
                // left a huge, empty-looking gap on tall phones. A ScrollView
                // keeps the quote right under the header and still scrolls if
                // the favorites list grows long.
                ScrollView {
                    VStack(spacing: 24) {
                        Text(current)
                            .font(.system(.title3, design: .rounded).weight(.semibold))
                            .foregroundColor(Theme.text)
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)
                            .id(index)
                            .transition(.opacity)
                            .padding(.horizontal, 12)

                        HStack(spacing: 32) {
                            Button { move(-1) } label: {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Theme.text)
                                    .frame(width: 44, height: 44)
                                    .background(Theme.card)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Theme.cardBorder, lineWidth: 1))
                            }
                            .accessibilityIdentifier("affirmation.prev")

                            Button { toggleFavorite() } label: {
                                Image(systemName: affirmationStore.isFavorite(current) ? "heart.fill" : "heart")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(
                                        affirmationStore.isFavorite(current)
                                        ? AnyShapeStyle(Theme.accentGradient)
                                        : AnyShapeStyle(Theme.secondaryText)
                                    )
                                    .frame(width: 48, height: 48)
                                    .background(Theme.card)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Theme.cardBorder, lineWidth: 1))
                            }
                            .accessibilityIdentifier("affirmation.favorite")

                            Button { move(1) } label: {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Theme.text)
                                    .frame(width: 44, height: 44)
                                    .background(Theme.card)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Theme.cardBorder, lineWidth: 1))
                            }
                            .accessibilityIdentifier("affirmation.next")
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 40)
                    .padding(.bottom, 40)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("お気に入り")
                            .font(.system(.caption, design: .rounded).weight(.bold))
                            .foregroundColor(Theme.secondaryText)
                            .padding(.horizontal, 24)

                        if affirmationStore.favoritesInOrder.isEmpty {
                            Text("お気に入りはまだありません")
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(Theme.tertiaryText)
                                .padding(.horizontal, 24)
                                .padding(.bottom, 20)
                        } else {
                            VStack(spacing: 8) {
                                ForEach(affirmationStore.favoritesInOrder, id: \.self) { text in
                                    Button {
                                        if let i = affirmations.firstIndex(of: text) {
                                            withAnimation(.easeInOut(duration: 0.2)) { index = i }
                                        }
                                    } label: {
                                        Text(text)
                                            .font(.system(.footnote, design: .rounded))
                                            .foregroundColor(Theme.text)
                                            .multilineTextAlignment(.leading)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(12)
                                            .cardStyle()
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            Analytics.shared.track(AnalyticsEvent.affirmationViewed)
        }
    }

    private func move(_ delta: Int) {
        withAnimation(.easeInOut(duration: 0.2)) {
            index = (index + delta + affirmations.count) % affirmations.count
        }
    }

    private func toggleFavorite() {
        let wasFavorite = affirmationStore.isFavorite(current)
        affirmationStore.toggleFavorite(current)
        if !wasFavorite {
            Analytics.shared.track(AnalyticsEvent.affirmationFavorited)
        }
    }
}
