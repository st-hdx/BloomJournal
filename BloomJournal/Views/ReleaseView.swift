import SwiftUI

struct ReleaseView: View {
    @EnvironmentObject private var store: VisionStore
    let journalText: String
    let onDismiss: () -> Void
    let onJournalAgain: () -> Void

    @State private var phase: Phase = .selectVision
    @State private var expandedVisions: Set<UUID> = []
    @State private var detailTexts: [UUID: String] = [:]
    @State private var textOpacity: Double = 1
    @State private var textOffset: CGFloat = 0
    @State private var showComplete = false

    enum Phase { case selectVision, releasing }

    private var appendedVisions: [Vision] {
        store.visions.filter { v in
            expandedVisions.contains(v.id) &&
            !(detailTexts[v.id] ?? "").trimmingCharacters(in: .whitespaces).isEmpty == false
        }
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            if !showComplete {
                switch phase {
                case .selectVision:
                    selectVisionView.transition(.opacity)
                case .releasing:
                    releasingView
                }
            }

            if showComplete {
                completeView
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
    }

    // MARK: - Phase 1

    private var selectVisionView: some View {
        VStack(spacing: 0) {
            ScrollView {
                Text(journalText)
                    .font(.system(.body, design: .rounded))
                    .lineSpacing(5)
                    .foregroundColor(Theme.text)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(18)
                    .cardStyle()
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
            }
            .frame(maxHeight: 200)

            Text("追記したいビジョンを選んでください")
                .font(.system(.subheadline, design: .rounded).weight(.medium))
                .foregroundColor(Theme.text)
                .padding(.top, 24)
                .padding(.bottom, 14)

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(store.visions) { vision in
                        VisionDetailEntry(
                            vision: vision,
                            journalText: journalText,
                            isExpanded: expandedVisions.contains(vision.id),
                            text: Binding(
                                get: { detailTexts[vision.id] ?? "" },
                                set: { detailTexts[vision.id] = $0 }
                            ),
                            onToggle: {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    if expandedVisions.contains(vision.id) {
                                        expandedVisions.remove(vision.id)
                                    } else {
                                        expandedVisions.insert(vision.id)
                                    }
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }

            Spacer()

            VStack(spacing: 10) {
                Button {
                    saveAndRelease()
                } label: {
                    Text(appendedVisions.isEmpty ? "意識から解き放つ" : "追記して解き放つ")
                        .font(.system(.body, design: .rounded).weight(.semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Theme.accentGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Theme.accent1.opacity(0.35), radius: 10, y: 4)
                }
                .padding(.horizontal, 24)

                Text("書き出すことで頭から手放し、潜在意識に委ねます")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundColor(Theme.tertiaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .padding(.bottom, 40)
        }
    }

    // MARK: - Phase 2

    private var releasingView: some View {
        VStack {
            Spacer()
            Text(journalText)
                .font(.system(.body, design: .rounded))
                .lineSpacing(5)
                .foregroundColor(Theme.text)
                .multilineTextAlignment(.leading)
                .padding(.horizontal, 24)
                .opacity(textOpacity)
                .offset(y: textOffset)
            Spacer()
        }
    }

    // MARK: - Complete

    private var completeView: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 20) {
                Image(systemName: "sparkles")
                    .font(.system(size: 52))
                    .foregroundStyle(Theme.accentGradient)

                VStack(spacing: 10) {
                    Text("ビジョンが現実に近づいている")
                        .font(.system(.title3, design: .rounded).weight(.semibold))
                        .foregroundColor(Theme.text)
                        .multilineTextAlignment(.center)

                    if appendedVisions.count == 1 {
                        Text("「\(appendedVisions[0].title)」への一歩を刻んだ")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(Theme.secondaryText)
                            .multilineTextAlignment(.center)
                    } else if appendedVisions.count > 1 {
                        Text("\(appendedVisions.count)つのビジョンへの一歩を刻んだ")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(Theme.secondaryText)
                            .multilineTextAlignment(.center)
                    } else {
                        Text("書き出したことが現実を引き寄せる")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(Theme.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .padding(.horizontal, 32)
            Spacer()
            VStack(spacing: 12) {
                Button { onDismiss() } label: {
                    Text("ホームへ戻る")
                        .font(.system(.body, design: .rounded).weight(.semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Theme.accentGradient)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Theme.accent1.opacity(0.35), radius: 10, y: 4)
                }
                .padding(.horizontal, 24)
                Button { onJournalAgain() } label: {
                    Text("もう一度書き出す")
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(Theme.secondaryText)
                }
            }
            .padding(.bottom, 40)
        }
    }

    // MARK: - Actions

    private func saveAndRelease() {
        for vision in store.visions {
            let trimmed = (detailTexts[vision.id] ?? "").trimmingCharacters(in: .whitespaces)
            if expandedVisions.contains(vision.id), !trimmed.isEmpty {
                store.addDetail(trimmed, to: vision)
            }
        }
        startRelease()
    }

    private func startRelease() {
        phase = .releasing
        textOpacity = 1
        textOffset = 0
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeIn(duration: 1.0)) {
                textOpacity = 0
                textOffset = -160
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                withAnimation(.easeIn(duration: 0.5)) {
                    showComplete = true
                }
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        }
    }
}

// MARK: - VisionDetailEntry

private struct VisionDetailEntry: View {
    let vision: Vision
    let journalText: String
    let isExpanded: Bool
    @Binding var text: String
    let onToggle: () -> Void
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            Button(action: onToggle) {
                HStack {
                    Text(vision.title)
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(Theme.text)
                    Spacer()
                    if isExpanded {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Theme.accentGradient)
                    } else {
                        Image(systemName: "circle")
                            .foregroundColor(Theme.tertiaryText)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("追記する内容")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(Theme.secondaryText)
                        Spacer()
                        Button {
                            text = journalText
                            isFocused = true
                        } label: {
                            Text("引用する")
                                .font(.system(.caption, design: .rounded))
                                .foregroundColor(Theme.accent1)
                        }
                    }

                    ZStack(alignment: .topLeading) {
                        if text.isEmpty {
                            Text("気づいたこと、感じたこと、次にやること...")
                                .font(.system(.body, design: .rounded))
                                .foregroundColor(Theme.tertiaryText)
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        TextEditor(text: $text)
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(Theme.text)
                            .focused($isFocused)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .frame(minHeight: 72)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 14)
            }
        }
        .background(isExpanded ? Theme.ringBg : Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Theme.cardBorder, lineWidth: 1)
        )
        .onChange(of: isExpanded) { expanded in
            if expanded {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { isFocused = true }
            }
        }
    }
}
