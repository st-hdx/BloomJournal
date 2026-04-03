import SwiftUI
import RevenueCat

@main
struct BloomJournalApp: App {
    @StateObject private var store = VisionStore()
    @StateObject private var purchaseManager = PurchaseManager()

    init() {
        Purchases.configure(withAPIKey: "test_vcIrINAnpgThypZrGauCpxiqKAU")
        #if DEBUG
        Purchases.logLevel = .debug
        #endif
    }

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(store)
                .environmentObject(purchaseManager)
        }
    }
}
