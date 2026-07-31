import Foundation

/// Centralizes locale-dependent app content (writing prompts, quotes) so
/// HomeView and JournalingView stay in sync instead of keeping separate copies.
enum LocalizedContent {
    struct Quote {
        let text: String
        let author: String
    }

    static var isJapanese: Bool {
        Locale.preferredLanguages.first?.hasPrefix("ja") ?? true
    }

    /// Wraps a quote in the locale-appropriate quotation marks.
    static func quoted(_ text: String) -> String {
        isJapanese ? "「\(text)」" : "\u{201C}\(text)\u{201D}"
    }

    static var writingPrompts: [String] {
        isJapanese ? ja_writingPrompts : en_writingPrompts
    }

    static var quotes: [Quote] {
        isJapanese ? ja_quotes : en_quotes
    }

    private static let ja_writingPrompts = [
        "今どんな自分をイメージしていますか？",
        "もし全てが思い通りになったら、今日どんな一日を過ごしていますか？",
        "ビジョンが実現した瞬間、何を感じていますか？",
        "今のあなたに向けて、未来の自分から何を伝えますか？",
        "すでにそれを手にしているとしたら、今日何をしますか？",
    ]

    private static let en_writingPrompts = [
        "What version of yourself are you picturing right now?",
        "If everything went exactly as you wanted, how would today unfold?",
        "What do you feel the moment your vision becomes real?",
        "What would your future self tell you today?",
        "If you already had it, what would you do today?",
    ]

    private static let ja_quotes: [Quote] = [
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

    private static let en_quotes: [Quote] = [
        Quote(text: "If today were the last day of my life, would I want to do what I am about to do today?", author: "Steve Jobs"),
        Quote(text: "Anything one man can imagine, other men can make real.", author: "Jules Verne"),
        Quote(text: "If you can dream it, you can do it.", author: "Walt Disney"),
        Quote(text: "The future depends on what you do today.", author: "Mahatma Gandhi"),
        Quote(text: "Whatever the mind can conceive and believe, it can achieve.", author: "Napoleon Hill"),
        Quote(text: "Impossible is a word found only in the dictionary of fools.", author: "Napoleon Bonaparte"),
        Quote(text: "Your nervous system can't tell the difference between an imagined experience and a real one.", author: "Maxwell Maltz"),
        Quote(text: "When you change the way you look at things, the things you look at change.", author: "Wayne Dyer"),
        Quote(text: "Every morning we are born again. What we do today matters most.", author: "Dalai Lama"),
        Quote(text: "See yourself succeeding first, and your brain will move toward it.", author: "John Assaraf"),
        Quote(text: "Your subconscious mind follows your thoughts, so plant good ones.", author: "Joseph Murphy"),
        Quote(text: "A person becomes what they believe they will become.", author: "Goethe"),
    ]
}
