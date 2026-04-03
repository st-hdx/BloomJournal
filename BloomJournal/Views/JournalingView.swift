import SwiftUI

private let writingPrompts = [
    "今どんな自分をイメージしていますか？",
    "もし全てが思い通りになったら、今日どんな一日を過ごしていますか？",
    "ビジョンが実現した瞬間、何を感じていますか？",
    "今のあなたに向けて、未来の自分から何を伝えますか？",
    "すでにそれを手にしているとしたら、今日何をしますか？",
]

private struct Quote {
    let text: String
    let author: String
}

private let quotes: [Quote] = [
    Quote(text: "今日が人生最後の日だとしたら、今日やろうとしていることをやりたいか？", author: "スティーブ・ジョブズ"),
    Quote(text: "想像できることは、すべて現実になる。", author: "ジュール・ヴェルヌ"),
    Quote(text: "夢を見ることができれば、それは実現できる。", author: "ウォルト・ディズニー"),
    Quote(text: "未来は、今日何をするかにかかっている。", author: "マハトマ・ガンジー"),
    Quote(text: "思考は現実化する。", author: "ナポレオン・ヒル"),
    Quote(text: "人生でもっとも危険なのは、不可能なことが存在すると思い込むことだ。", author: "ナポレオン・ボナパルト"),
    Quote(text: "強くイメージしたことは、脳にとって現実と区別がつかない。", author: "マクスウェル・マルツ"),
    Quote(text: "あなたが心の中で思い描くものが、あなたの現実をつくる。", author: "ウェイン・ダイアー"),
    Quote(text: "毎朝目覚めるとき、それは再生だ。新しいことを始めよう。", author: "ダライ・ラマ"),
    Quote(text: "成功した自分を先にイメージせよ。脳はそこへ向かって動き出す。", author: "ジョン・アサラフ"),
    Quote(text: "あなたの潜在意識はあなたの思考に従う。良い種を蒔け。", author: "ジョセフ・マーフィー"),
    Quote(text: "人は自分が期待した通りの人間になる。", author: "ゲーテ"),
]

struct JournalingView: View {
    @EnvironmentObject private var store: VisionStore
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @State private var showRelease = false
    @FocusState private var isFocused: Bool

    private var prompt: String {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return writingPrompts[dayOfYear % writingPrompts.count]
    }

    private var quote: Quote {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return quotes[dayOfYear % quotes.count]
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Vision Banner
                VStack(spacing: 0) {
                    ScrollingVisionBanner(visions: store.visions)
                        .frame(height: 32)
                        .padding(.top, 20)

                    Text(prompt)
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(Theme.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.top, 10)
                        .padding(.bottom, 14)

                    VStack(spacing: 4) {
                        Text("「\(quote.text)」")
                            .font(.system(.caption, design: .rounded).italic())
                            .foregroundColor(Theme.tertiaryText)
                            .multilineTextAlignment(.center)
                        Text("— \(quote.author)")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundColor(Theme.tertiaryText)
                    }
                    .padding(.horizontal, 36)
                    .padding(.bottom, 16)

                    Divider().overlay(Theme.cardBorder)
                }

                // Text Editor
                ZStack(alignment: .topLeading) {
                    if text.isEmpty {
                        Text("思い浮かんだことを自由に書き出そう\n正しく書こうとしなくていい")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(Theme.tertiaryText)
                            .lineSpacing(6)
                            .padding(.top, 20)
                            .padding(.horizontal, 4)
                    }
                    TextEditor(text: $text)
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(Theme.text)
                        .lineSpacing(4)
                        .focused($isFocused)
                        .scrollContentBackground(.hidden)
                        .background(Color.clear)
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)

                // Bottom
                VStack(spacing: 0) {
                    if !text.isEmpty {
                        Text("書き終わったら完了を押してください")
                            .font(.system(.caption2, design: .rounded))
                            .foregroundColor(Theme.secondaryText)
                            .padding(.bottom, 10)
                    }
                    Button {
                        isFocused = false
                        showRelease = true
                    } label: {
                        Text("完了")
                            .font(.system(.body, design: .rounded).weight(.semibold))
                            .foregroundColor(text.isEmpty ? Theme.secondaryText : .white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                text.isEmpty
                                ? AnyShapeStyle(Theme.ringBg)
                                : AnyShapeStyle(Theme.accentGradient)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: text.isEmpty ? .clear : Theme.accent1.opacity(0.3), radius: 8, y: 3)
                    }
                    .disabled(text.isEmpty)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }

            // Close button
            VStack {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(.subheadline).weight(.medium))
                            .foregroundColor(Theme.secondaryText)
                            .frame(width: 32, height: 32)
                            .background(Theme.card)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Theme.cardBorder, lineWidth: 1))
                    }
                    .padding(.leading, 20)
                    .padding(.top, 20)
                    Spacer()
                }
                Spacer()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { isFocused = true }
        }
        // 閉じる時: まずReleaseViewを閉じてからJournalingViewも閉じる
        .fullScreenCover(isPresented: $showRelease) {
            ReleaseView(
                journalText: text,
                onDismiss: {
                    showRelease = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        dismiss()
                    }
                },
                onJournalAgain: {
                    showRelease = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        text = ""
                        isFocused = true
                    }
                }
            )
            .environmentObject(store)
        }
    }
}

struct ScrollingVisionBanner: View {
    let visions: [Vision]
    @State private var offset: CGFloat = 0
    @State private var contentWidth: CGFloat = 0

    var combinedText: String {
        visions.map { $0.title }.joined(separator: "　　")
    }

    var body: some View {
        GeometryReader { _ in
            HStack(spacing: 0) {
                Text(combinedText + "　　")
                    .font(.system(.subheadline, design: .rounded).weight(.medium))
                    .foregroundColor(Theme.secondaryText)
                    .fixedSize()
                    .background(GeometryReader { g in
                        Color.clear.onAppear { contentWidth = g.size.width }
                    })
                    .offset(x: offset)

                Text(combinedText + "　　")
                    .font(.system(.subheadline, design: .rounded).weight(.medium))
                    .foregroundColor(Theme.secondaryText)
                    .fixedSize()
                    .offset(x: offset)
            }
            .onChange(of: contentWidth) { width in
                guard width > 0 else { return }
                offset = 0
                withAnimation(.linear(duration: Double(width) / 40).repeatForever(autoreverses: false)) {
                    offset = -width
                }
            }
        }
        .clipped()
    }
}
