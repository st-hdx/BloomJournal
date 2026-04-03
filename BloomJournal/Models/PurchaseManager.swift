import Foundation
import Combine
import RevenueCat

class PurchaseManager: ObservableObject {
    @Published private(set) var isPro: Bool = false

    static let freeVisionLimit = 2
    static let entitlementID = "Bloom Journal Pro"
    static let productID = "com.pandagiken.bloomjournal.app.pro"

    init() {
        Purchases.shared.getCustomerInfo { [weak self] customerInfo, _ in
            Task { @MainActor [weak self] in
                self?.updateProStatus(from: customerInfo)
            }
        }
    }

    @MainActor
    func purchase() async throws {
        let products = await Purchases.shared.products([Self.productID])
        guard let product = products.first else {
            throw PurchaseError.productNotFound
        }
        let result = try await Purchases.shared.purchase(product: product)
        updateProStatus(from: result.customerInfo)
        if !isPro {
            throw PurchaseError.notEntitled
        }
    }

    @MainActor
    func restore() async throws {
        let customerInfo = try await Purchases.shared.restorePurchases()
        updateProStatus(from: customerInfo)
        if !isPro {
            throw PurchaseError.notEntitled
        }
    }

    @MainActor
    private func updateProStatus(from customerInfo: CustomerInfo?) {
        isPro = customerInfo?.entitlements[Self.entitlementID]?.isActive == true
    }

    #if DEBUG
    func toggleProForDebug() {
        isPro.toggle()
    }
    #endif
}

enum PurchaseError: LocalizedError {
    case productNotFound
    case notEntitled

    var errorDescription: String? {
        switch self {
        case .productNotFound: return "商品が見つかりませんでした。"
        case .notEntitled: return "購入が確認できませんでした。"
        }
    }
}
