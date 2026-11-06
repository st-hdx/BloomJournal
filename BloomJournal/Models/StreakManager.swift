import Foundation

class StreakManager: ObservableObject {
    static let shared = StreakManager()

    @Published private(set) var currentStreak: Int = 0

    private let key = "practicedDates"
    private var practicedDates: Set<String> = []

    private static let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = .current
        return f
    }()

    private init() {
        if ProcessInfo.processInfo.arguments.contains("-uitestSeedStreak") {   // スクリーンショット撮影用
            let calendar = Calendar.current
            practicedDates = Set((0..<7).compactMap { offset in
                calendar.date(byAdding: .day, value: -offset, to: Date()).map(Self.dayFormatter.string(from:))
            })
            recalculate()
            return
        }
        if let saved = UserDefaults.standard.array(forKey: key) as? [String] {
            practicedDates = Set(saved)
        }
        recalculate()
    }

    func recordCompletion() {
        let today = Self.dayFormatter.string(from: Date())
        guard !practicedDates.contains(today) else { return }
        practicedDates.insert(today)
        UserDefaults.standard.set(Array(practicedDates), forKey: key)
        recalculate()
    }

    private func recalculate() {
        let calendar = Calendar.current
        var day = calendar.startOfDay(for: Date())
        // 今日分がまだ無くても、昨日まで続いていれば継続中として見せる。
        // そうしないと「今日まだ書いていない」だけで連続日数が0に見えてしまう。
        if !practicedDates.contains(Self.dayFormatter.string(from: day)) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: day) else {
                currentStreak = 0
                return
            }
            day = yesterday
        }

        var streak = 0
        while practicedDates.contains(Self.dayFormatter.string(from: day)) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }
        currentStreak = streak
    }
}
