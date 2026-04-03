import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: VisionStore
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @State private var showJournaling = false
    @State private var showAddVision = false
    @State private var newVisionTitle = ""
    @State private var isReordering = false
    @State private var showPaywall = false

    var body: some View {
        NavigationStack {
            if store.visions.isEmpty {
                OnboardingView().environmentObject(store).environmentObject(purchaseManager)
            } else {
                mainView
            }
        }
        .fullScreenCover(isPresented: $showJournaling) {
            JournalingView().environmentObject(store)
        }
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
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                    }
                }

                Spacer(minLength: 0)

                // Journaling section
                VStack(spacing: 0) {
                    Divider()
                        .background(Theme.cardBorder)
                        .padding(.bottom, 20)

                    VStack(spacing: 6) {
                        Text("浮かんだイメージや気づきを書き出して")
                            .font(.system(.subheadline, design: .rounded).weight(.medium))
                            .foregroundColor(Theme.text)
                        Text("ビジョンの実現に近づけよう")
                            .font(.system(.subheadline, design: .rounded).weight(.medium))
                            .foregroundColor(Theme.text)
                    }
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 16)

                    Button {
                        showJournaling = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "pencil.line")
                            Text("イメージを書き出す")
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
                }
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView().environmentObject(purchaseManager)
        }
        .alert("ビジョンを追加", isPresented: $showAddVision) {
            TextField("副業を成功させるぞ", text: $newVisionTitle)
            Button("追加") {
                let trimmed = newVisionTitle.trimmingCharacters(in: .whitespaces)
                guard !trimmed.isEmpty else { return }
                store.add(title: trimmed)
                newVisionTitle = ""
            }
            Button("キャンセル", role: .cancel) { newVisionTitle = "" }
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
                    Text("無料版はビジョン\(PurchaseManager.freeVisionLimit)件まで。Proにアップグレードすると無制限に追加できます。")
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
    }

    private func saveAndFinish() {
        let trimmed = inputText.trimmingCharacters(in: .whitespaces)
        if !trimmed.isEmpty && !atLimit { addedVisions.append(trimmed) }
        step = .done
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            for title in addedVisions { store.add(title: title) }
        }
    }
}

// MARK: - Vision Card

struct VisionCard: View {
    let vision: Vision

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            Circle()
                .fill(Theme.accentGradient)
                .frame(width: 7, height: 7)
                .padding(.top, 7)

            VStack(alignment: .leading, spacing: 5) {
                Text(vision.title)
                    .font(.system(.body, design: .rounded).weight(.medium))
                    .foregroundColor(Theme.text)
                if !vision.details.isEmpty {
                    Text("└ \(vision.details.last!)")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(Theme.secondaryText)
                        .lineLimit(1)
                }
            }
            Spacer()
            if !vision.details.isEmpty {
                Text("\(vision.details.count)")
                    .font(.system(.caption2, design: .rounded).weight(.semibold))
                    .foregroundColor(Theme.secondaryText)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Theme.ringBg)
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .cardStyle()
    }
}
