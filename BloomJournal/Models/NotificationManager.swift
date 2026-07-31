import SwiftUI
import UserNotifications

class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var isEnabled: Bool {
        didSet { UserDefaults.standard.set(isEnabled, forKey: "notificationEnabled") }
    }
    @Published var reminderHour: Int {
        didSet {
            UserDefaults.standard.set(reminderHour, forKey: "reminderHour")
            UserDefaults.standard.set(true, forKey: "reminderHourSet")
        }
    }
    @Published var reminderMinute: Int {
        didSet { UserDefaults.standard.set(reminderMinute, forKey: "reminderMinute") }
    }

    private init() {
        self.isEnabled = UserDefaults.standard.bool(forKey: "notificationEnabled")
        let hasSetHour = UserDefaults.standard.bool(forKey: "reminderHourSet")
        self.reminderHour = hasSetHour ? UserDefaults.standard.integer(forKey: "reminderHour") : 9
        self.reminderMinute = UserDefaults.standard.integer(forKey: "reminderMinute")
    }

    func requestPermissionAndSchedule() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                if granted {
                    self.isEnabled = true
                    self.scheduleReminder()
                } else {
                    self.isEnabled = false
                }
            }
        }
    }

    func scheduleReminder() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        guard isEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = "Bloom Journal"
        content.body = NSLocalizedString("daily_reminder_body", comment: "Daily reminder notification body")
        content.sound = .default

        var components = DateComponents()
        components.hour = reminderHour
        components.minute = reminderMinute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func cancelReminder() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        isEnabled = false
    }
}

// MARK: - NotificationSettingsView

struct NotificationSettingsView: View {
    @ObservedObject var manager: NotificationManager
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @State private var showPaywall = false

    private var reminderTime: Binding<Date> {
        Binding(
            get: {
                Calendar.current.date(
                    bySettingHour: manager.reminderHour,
                    minute: manager.reminderMinute,
                    second: 0,
                    of: Date()
                ) ?? Date()
            },
            set: { date in
                let c = Calendar.current.dateComponents([.hour, .minute], from: date)
                manager.reminderHour = c.hour ?? 9
                manager.reminderMinute = c.minute ?? 0
                manager.scheduleReminder()
            }
        )
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                Text("リマインダー設定")
                    .font(.system(.headline, design: .rounded).weight(.bold))
                    .foregroundColor(Theme.text)

                VStack(spacing: 0) {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("毎日のリマインダー")
                                .font(.system(.body, design: .rounded))
                                .foregroundColor(Theme.text)
                            Text("指定した時刻に通知でお知らせします")
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(Theme.secondaryText)
                        }
                        Spacer()
                        Toggle("", isOn: Binding(
                            get: { manager.isEnabled },
                            set: { enabled in
                                if enabled {
                                    manager.requestPermissionAndSchedule()
                                } else {
                                    manager.cancelReminder()
                                }
                            }
                        ))
                        .tint(Theme.accent1)
                        .labelsHidden()
                    }
                    .padding(16)

                    if manager.isEnabled {
                        LinearGradient(
                            colors: [Theme.accent1.opacity(0.2), Theme.accent2.opacity(0.2)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(height: 1)

                        DatePicker("", selection: reminderTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .frame(maxWidth: .infinity)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                    }
                }
                .cardStyle()
                .animation(.easeInOut(duration: 0.2), value: manager.isEnabled)

                if !purchaseManager.isPro {
                    Button {
                        showPaywall = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "sparkles")
                                .font(.system(.body))
                                .foregroundStyle(Theme.accentGradient)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Bloom Journal Pro")
                                    .font(.system(.body, design: .rounded).weight(.semibold))
                                    .foregroundColor(Theme.text)
                                Text(NSLocalizedString("settings_pro_upsell_subtitle", comment: "Settings screen Pro upsell subtitle"))
                                    .font(.system(.caption, design: .rounded))
                                    .foregroundColor(Theme.secondaryText)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(Theme.tertiaryText)
                        }
                        .padding(16)
                    }
                    .buttonStyle(.plain)
                    .cardStyle()
                }

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.top, 28)
        }
        .presentationDetents([.height(presentationHeight)])
        .presentationDragIndicator(.visible)
        .animation(.easeInOut(duration: 0.2), value: manager.isEnabled)
        .sheet(isPresented: $showPaywall) {
            PaywallView().environmentObject(purchaseManager)
        }
    }

    private var presentationHeight: CGFloat {
        var height: CGFloat = manager.isEnabled ? 300 : 190
        if !purchaseManager.isPro { height += 90 }
        return height
    }
}
