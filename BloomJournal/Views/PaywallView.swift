import SwiftUI

struct PaywallView: View {
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @Environment(\.dismiss) private var dismiss

    @State private var isPurchasing = false
    @State private var isRestoring = false
    @State private var errorMessage: String?

    private var upgradeButtonTitle: String {
        guard let price = purchaseManager.priceString else {
            return NSLocalizedString("アップグレードする", comment: "Upgrade button, price unknown yet")
        }
        return String(format: NSLocalizedString("upgrade_button_with_price", comment: "Upgrade button with price"), price)
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 28) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 52))
                        .foregroundStyle(Theme.accentGradient)

                    VStack(spacing: 10) {
                        Text("すべてのビジョンを\n解き放とう")
                            .font(.system(.title2, design: .rounded).weight(.bold))
                            .foregroundColor(Theme.text)
                            .multilineTextAlignment(.center)
                        Text("無料版はビジョン2件まで。\nProにアップグレードして制限なく引き寄せよう。")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(Theme.secondaryText)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }

                    VStack(spacing: 12) {
                        FeatureRow(icon: "infinity", text: "ビジョンを無制限に追加")
                        FeatureRow(icon: "pencil.line", text: "毎日のジャーナリングで加速")
                        FeatureRow(icon: "chart.line.uptrend.xyaxis", text: "追記で現実との距離を縮める")
                    }
                    .padding(.horizontal, 32)
                }
                .padding(.horizontal, 24)

                Spacer()

                VStack(spacing: 12) {
                    if let error = errorMessage {
                        Text(error)
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }

                    Button {
                        Task { await doPurchase() }
                    } label: {
                        Group {
                            if isPurchasing {
                                ProgressView().tint(.white)
                            } else {
                                Text(upgradeButtonTitle)
                                    .font(.system(.body, design: .rounded).weight(.semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Theme.accentGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Theme.accent1.opacity(0.35), radius: 10, y: 4)
                    }
                    .disabled(isPurchasing || isRestoring)
                    .padding(.horizontal, 24)

                    Button {
                        Task { await doRestore() }
                    } label: {
                        Group {
                            if isRestoring {
                                ProgressView()
                            } else {
                                Text("購入を復元する")
                                    .font(.system(.body, design: .rounded))
                                    .foregroundColor(Theme.secondaryText)
                            }
                        }
                    }
                    .disabled(isPurchasing || isRestoring)
                }
                .padding(.bottom, 40)
            }

            VStack {
                HStack {
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
                    .padding(.trailing, 20)
                    .padding(.top, 20)
                }
                Spacer()
            }
        }
    }

    private func doPurchase() async {
        isPurchasing = true
        errorMessage = nil
        do {
            try await purchaseManager.purchase()
            dismiss()
        } catch {
            errorMessage = NSLocalizedString("purchase_failed_message", comment: "Shown when a purchase attempt fails")
        }
        isPurchasing = false
    }

    private func doRestore() async {
        isRestoring = true
        errorMessage = nil
        do {
            try await purchaseManager.restore()
            dismiss()
        } catch {
            errorMessage = NSLocalizedString("restore_failed_message", comment: "Shown when restoring purchases fails")
        }
        isRestoring = false
    }
}

private struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(.body))
                .foregroundStyle(Theme.accentGradient)
                .frame(width: 24)
            Text(text)
                .font(.system(.body, design: .rounded))
                .foregroundColor(Theme.text)
            Spacer()
        }
    }
}
