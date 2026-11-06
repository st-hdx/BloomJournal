import Foundation
import Combine

class AffirmationStore: ObservableObject {
    @Published private(set) var favorites: Set<String> = []

    private let key = "favoriteAffirmations"

    init() {
        if ProcessInfo.processInfo.arguments.contains("-uitestSeedFavorite") {   // スクリーンショット撮影用
            let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
            let affirmations = LocalizedContent.affirmations
            favorites = [affirmations[dayOfYear % affirmations.count]]
            return
        }
        if let saved = UserDefaults.standard.array(forKey: key) as? [String] {
            favorites = Set(saved)
        }
    }

    func isFavorite(_ text: String) -> Bool {
        favorites.contains(text)
    }

    func toggleFavorite(_ text: String) {
        if favorites.contains(text) {
            favorites.remove(text)
        } else {
            favorites.insert(text)
        }
        UserDefaults.standard.set(Array(favorites), forKey: key)
    }

    var favoritesInOrder: [String] {
        LocalizedContent.affirmations.filter { favorites.contains($0) }
    }
}
