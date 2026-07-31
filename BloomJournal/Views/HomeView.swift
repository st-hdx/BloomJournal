import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: VisionStore
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @ObservedObject private var notificationManager = NotificationManager.shared
    @State private var showJournaling = false
    @State private var showAddVision = false
    @State private var newVisionTitle = ""
    @State private var isReordering = false
    @State private var showPaywall = false
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            if store.visions.isEmpty {
                OnboardingView()
                    .environmentObject(store)
                    .environmentObject(purchaseManager)
                    .transition(.opacity)
            } else {
                mainView
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: store.visions.isEmpty)
        .fullScreenCover(isPresented: $showJournaling) {
            JournalingView().environmentObject(store)
        }
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale.autoupdatingCurrent
        f.setLocalizedDateFormatFromTemplate(LocalizedContent.isJapanese ? "MdE" : "MMMdEEE")
        return f
    }()

    private var todayDateString: String {
        Self.dateFormatter.string(from: Date())
    }

    private var todayPrompt: String {
        let prompts = LocalizedContent.writingPrompts
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return prompts[dayOfYear % prompts.count]
    }

    private var mainView: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Bloom Journal")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.text)
                        Text("ビジョンを現実に引き寄せる")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(Theme.secondaryText)
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.system(size: 10))
                                .foregroundColor(Theme.tertiaryText)
                            Text(todayDateString)
                                .font(.system(.caption2, design: .rounded))
                                .foregroundColor(Theme.tertiaryText)
                        }
                        .padding(.top, 2)
                        #if DEBUG
                        Button {
                            purchaseManager.toggleProForDebug()
                        } label: {
                            Text(purchaseManager.isPro ? "DEBUG: Pro ON" : "DEBUG: Pro OFF")
                                .font(.system(.caption2, design: .monospaced))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(purchaseManager.isPro ? Color.green : Color.gray)
                                .clipShape(Capsule())
                        }
                        #endif
                    }
                    Spacer()
                    if isReordering {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) { isReordering = false }
                        } label: {
                            Text("完了")
                                .font(.system(.body, design: .rounded).weight(.semibold))
                                .foregroundColor(Theme.accent1)
                                .frame(height: 38)
                                .padding(.horizontal, 4)
                        }
                    } else {
                        HStack(spacing: 10) {
                            Button { showSettings = true } label: {
                                Image(systemName: "gearshape")
                                    .font(.system(.body, design: .rounded).weight(.semibold))
                                    .foregroundColor(Theme.text)
                                    .frame(width: 38, height: 38)
                                    .background(Theme.card)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Theme.cardBorder, lineWidth: 1))
                                    .shadow(color: Theme.cardShadow.opacity(0.08), radius: 4, y: 2)
                            }
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) { isReordering = true }
                            } label: {
                                Image(systemName: "arrow.up.arrow.down")
                                    .font(.system(.body, design: .rounded).weight(.semibold))
                                    .foregroundColor(Theme.text)
                                    .frame(width: 38, height: 38)
                                    .background(Theme.card)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Theme.cardBorder, lineWidth: 1))
                                    .shadow(color: Theme.cardShadow.opacity(0.08), radius: 4, y: 2)
                            }
                            Button {
                                if !purchaseManager.isPro && store.visions.count >= PurchaseManager.freeVisionLimit {
                                    showPaywall = true
                                } else {
                                    showAddVision = true
                                }
                            } label: {
                                Image(systemName: "plus")
                                    .font(.system(.body, design: .rounded).weight(.semibold))
                                    .foregroundColor(Theme.text)
                                    .frame(width: 38, height: 38)
                                    .background(Theme.card)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Theme.cardBorder, lineWidth: 1))
                                    .shadow(color: Theme.cardShadow.opacity(0.08), radius: 4, y: 2)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 16)

                // Vision section label
                HStack {
                    Text("引き寄せたいビジョン")
                        .font(.system(.caption, design: .rounded).weight(.medium))
                        .foregroundColor(Theme.secondaryText)
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 10)

                if isReordering {
                    List {
                        ForEach(store.visions) { vision in
                            VisionCard(vision: vision)
                                .listRowBackground(Theme.background)
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                        }
                        .onMove { store.moveVision(from: $0, to: $1) }
                    }
                    .listStyle(.plain)
                    .environment(\.editMode, .constant(.active))
                    .scrollContentBackground(.hidden)
                } else {
                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(store.visions) { vision in
                                NavigationLink(destination: VisionDetailView(vision: vision)) {
                                    VisionCard(vision: vision)
                                }
                                .buttonStyle(.plain)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .opacity
                                ))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: store.visions.count)
                    }
                }

                Spacer(minLength: 0)

                // Journaling section
                VStack(spacing: 0) {
                    // グラデーション区切り線
                    LinearGradient(
                        colors: [Theme.accent1.opacity(0.3), Theme.accent2.opacity(0.3)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(height: 1)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 20)

                    // 今日のお題ティーザー
                    VStack(spacing: 6) {
                        HStack(spacing: 5) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(Theme.accentGradient)
                            Text("今日のお題")
                                .font(.system(.caption2, design: .rounded).weight(.bold))
                                .foregroundColor(Theme.accent1)
                        }
                        Text(todayPrompt)
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(Theme.text)
                            .multilineTextAlignment(.center)
                            .lineSpacing(2)
                            .padding(.horizontal, 12)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)

                    Button {
                        showJournaling = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "pencil.line")
                            Text("今日のイメージを書き出す")
                                .fontWeight(.semibold)
                        }
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Theme.accentGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Theme.accent1.opacity(0.35), radius: 10, y: 4)
                    }
                    .padding(.horizontal, 24)

                    Text("書き出すことで現実が動き始める")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundColor(Theme.tertiaryText)
                        .padding(.top, 10)
                }
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView().environmentObject(purchaseManager)
        }
        .sheet(isPresented: $showSettings) {
            NotificationSettingsView(manager: notificationManager)
                .environmentObject(purchaseManager)
        }
        .sheet(isPresented: $showAddVision, onDismiss: { newVisionTitle = "" }) {
            TextInputSheet(
                title: "ビジョンを追加",
                placeholder: "副業を成功させるぞ",
                text: $newVisionTitle,
                buttonLabel: "追加する"
            ) {
                let trimmed = newVisionTitle.trimmingCharacters(in: .whitespaces)
                guard !trimmed.isEmpty else { return }
                store.add(title: trimmed)
                newVisionTitle = ""
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
        }
    }
}

// MARK: - Onboarding

struct OnboardingView: View {
    @EnvironmentObject private var store: VisionStore
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @State private var step: Step = .welcome
    @State private var inputText = ""
    @State private var addedVisions: [String] = []
    @FocusState private var isInputFocused: Bool
    @State private var showPaywall = false

    private var atLimit: Bool {
        !purchaseManager.isPro && addedVisions.count >= PurchaseManager.freeVisionLimit
    }

    enum Step { case welcome, input, done }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            switch step {
            case .welcome: welcomeView
            case .input:   inputView
            case .done:    doneView
            }
        }
        .animation(.easeInOut(duration: 0.4), value: step)
    }

    private var welcomeView: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 24) {
                Image(systemName: "sparkles")
                    .font(.system(size: 52))
                    .foregroundStyle(Theme.accentGradient)

                VStack(spacing: 10) {
                    Text("Bloom Journal へようこそ")
                        .font(.system(.title2, design: .rounded).weight(.bold))
                        .foregroundColor(Theme.text)
                        .multilineTextAlignment(.center)
                    Text("ビジョンを毎日イメージして書き出すことで\n現実が加速していきます")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(Theme.secondaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
            }
            .padding(.horizontal, 32)
            Spacer()
            Button {
                step = .input
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { isInputFocused = true }
            } label: {
                Text("はじめる")
                    .font(.system(.body, design: .rounded).weight(.semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Theme.accentGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Theme.accent1.opacity(0.35), radius: 10, y: 4)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }

    private var inputView: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 24) {
                VStack(spacing: 10) {
                    Text("あなたのビジョンを教えて")
                        .font(.system(.title2, design: .rounded).weight(.bold))
                        .foregroundColor(Theme.text)
                        .multilineTextAlignment(.center)
                    Text("引き寄せたい未来を、言い切りで書こう")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(Theme.secondaryText)
                        .multilineTextAlignment(.center)
                }

                if !addedVisions.isEmpty {
                    VStack(spacing: 8) {
                        ForEach(addedVisions, id: \.self) { v in
                            HStack(spacing: 10) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Theme.accentGradient)
                                Text(v)
                                    .font(.system(.body, design: .rounded))
                                    .foregroundColor(Theme.text)
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .cardStyle()
                        }
                    }
                    .padding(.horizontal, 24)
                }

                HStack(spacing: 12) {
                    TextField("副業を成功させるぞ", text: $inputText)
                        .font(.system(.body, design: .rounded))
                        .focused($isInputFocused)
                        .submitLabel(.done)
                        .onSubmit { addVision() }
                        .foregroundColor(Theme.text)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .cardStyle()

                    Button {
                        if atLimit {
                            showPaywall = true
                        } else {
                            addVision()
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(
                                inputText.trimmingCharacters(in: .whitespaces).isEmpty
                                ? AnyShapeStyle(Theme.ringBg)
                                : AnyShapeStyle(Theme.accentGradient)
                            )
                    }
                    .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.horizontal, 24)

                if atLimit {
                    Text(String(format: NSLocalizedString("free_limit_message", comment: "Shown when the user hits the free vision limit"), PurchaseManager.freeVisionLimit))
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(Theme.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                } else {
                    Text("例：車を買うぞ　・　英語ができるようになるぞ")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(Theme.tertiaryText)
                        .multilineTextAlignment(.center)
                }
            }
            Spacer()
            VStack(spacing: 12) {
                if !addedVisions.isEmpty {
                    Button { saveAndFinish() } label: {
                        Text("はじめよう")
                            .font(.system(.body, design: .rounded).weight(.semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Theme.accentGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Theme.accent1.opacity(0.35), radius: 10, y: 4)
                    }
                    .padding(.horizontal, 24)
                }
                Button { step = .welcome } label: {
                    Text("戻る")
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(Theme.secondaryText)
                }
            }
            .padding(.bottom, 40)
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView().environmentObject(purchaseManager)
        }
    }

    private var doneView: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 20) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(Theme.accentGradient)
                VStack(spacing: 10) {
                    Text("準備完了")
                        .font(.system(.title2, design: .rounded).weight(.bold))
                        .foregroundColor(Theme.text)
                    Text("毎日ビジョンをイメージして書き出そう\nそれだけで現実が動き始める")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(Theme.secondaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
            }
            .padding(.horizontal, 32)
            Spacer()
        }
    }

    private func addVision() {
        let trimmed = inputText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        if atLimit {
            showPaywall = true
            return
        }
        addedVisions.append(trimmed)
        inputText = ""
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func saveAndFinish() {
        let trimmed = inputText.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty && !atLimit { addedVisions.append(trimmed) }
        step = .done
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            for title in addedVisions { store.add(title: title) }
        }
    }
}

// MARK: - Vision Card

struct VisionCard: View {
    let vision: Vision

    var body: some View {
        HStack(spacing: 0) {
            // 左グラデーションアクセントバー
            LinearGradient(
                colors: [Theme.accent1, Theme.accent2],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: 4)
            .padding(.vertical, 10)
            .clipShape(Capsule())
            .padding(.leading, 14)
            .padding(.trailing, 12)

            VStack(alignment: .leading, spacing: 5) {
                Text(vision.title)
                    .font(.system(.body, design: .rounded).weight(.medium))
                    .foregroundColor(Theme.text)
                if !vision.details.isEmpty {
                    Text(vision.details.last!)
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(Theme.secondaryText)
                        .lineLimit(1)
                }
            }

            Spacer()

            HStack(spacing: 8) {
                if !vision.details.isEmpty {
                    HStack(spacing: 3) {
                        Image(systemName: "note.text")
                            .font(.system(size: 9, weight: .medium))
                        Text("\(vision.details.count)")
                            .font(.system(.caption2, design: .rounded).weight(.semibold))
                    }
                    .foregroundColor(Theme.accent1)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Theme.accent1.opacity(0.12))
                    .clipShape(Capsule())
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Theme.tertiaryText)
            }
            .padding(.trailing, 16)
        }
        .padding(.vertical, 16)
        .cardStyle()
        .contentShape(Rectangle())
    }
}
