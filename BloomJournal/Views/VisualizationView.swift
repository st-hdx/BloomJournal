import SwiftUI
import Combine

struct VisualizationView: View {
    @EnvironmentObject private var store: VisionStore
    @Environment(\.dismiss) private var dismiss

    @State private var phase: Phase = .setup
    @State private var selectedVisionID: UUID?
    @State private var selectedMinutes: Int = 3
    @State private var elapsed: Int = 0
    @State private var isPaused = false
    @State private var showQuitConfirm = false

    private let durations = [1, 3, 5, 10]
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    enum Phase { case setup, running, complete }

    private var selectedVision: Vision? {
        guard let id = selectedVisionID else { return nil }
        return store.visions.first { $0.id == id }
    }

    private var lines: [String] {
        var result: [String] = []
        if let vision = selectedVision {
            result.append(vision.title)
            result.append(contentsOf: vision.details)
        } else {
            result.append(contentsOf: store.visions.map { $0.title })
        }
        result.append(contentsOf: LocalizedContent.visualizationCues)
        return result
    }

    private var totalSeconds: Int { selectedMinutes * 60 }

    private var currentLine: String {
        guard !lines.isEmpty else { return "" }
        let lineDuration = max(5, totalSeconds / max(1, lines.count))
        let lineIndex = (elapsed / lineDuration) % lines.count
        return lines[lineIndex]
    }

    private var remainingText: String {
        let remaining = max(0, totalSeconds - elapsed)
        return String(format: "%d:%02d", remaining / 60, remaining % 60)
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            switch phase {
            case .setup: setupView
            case .running: runningView
            case .complete: completeView
            }
        }
        .onReceive(timer) { _ in
            guard phase == .running, !isPaused else { return }
            elapsed += 1
            if elapsed >= totalSeconds {
                finish()
            }
        }
        .alert("セッションを中断しますか？", isPresented: $showQuitConfirm) {
            Button("やめる", role: .destructive) { dismiss() }
            Button("キャンセル", role: .cancel) {}
        }
    }

    // MARK: - Setup

    private var setupView: some View {
        VStack(spacing: 0) {
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
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            Spacer()

            VStack(spacing: 32) {
                VStack(spacing: 8) {
                    Image(systemName: "wind")
                        .font(.system(size: 40))
                        .foregroundStyle(Theme.accentGradient)
                    Text("ビジュアライゼーション")
                        .font(.system(.title2, design: .rounded).weight(.bold))
                        .foregroundColor(Theme.text)
                    Text("イメージしたいビジョンを選んでください")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(Theme.secondaryText)
                        .multilineTextAlignment(.center)
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        chip(
                            title: NSLocalizedString("すべてのビジョン", comment: "Chip to visualize across all visions"),
                            isSelected: selectedVisionID == nil
                        ) {
                            selectedVisionID = nil
                        }
                        ForEach(store.visions) { vision in
                            chip(title: vision.title, isSelected: selectedVisionID == vision.id) {
                                selectedVisionID = vision.id
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("時間を選ぶ")
                        .font(.system(.caption, design: .rounded).weight(.bold))
                        .foregroundColor(Theme.secondaryText)
                        .padding(.horizontal, 24)

                    HStack(spacing: 10) {
                        ForEach(durations, id: \.self) { minutes in
                            chip(title: minutesLabel(minutes), isSelected: selectedMinutes == minutes) {
                                selectedMinutes = minutes
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                }
            }

            Spacer()

            Button {
                start()
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

    private func chip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(.footnote, design: .rounded).weight(.medium))
                .foregroundColor(isSelected ? .white : Theme.text)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? AnyShapeStyle(Theme.accentGradient) : AnyShapeStyle(Theme.card))
                .clipShape(Capsule())
                .overlay(
                    Capsule().stroke(Theme.cardBorder, lineWidth: isSelected ? 0 : 1)
                )
        }
        .buttonStyle(.plain)
    }

    private func minutesLabel(_ minutes: Int) -> String {
        String(format: NSLocalizedString("visualization_minutes_format", comment: "Duration chip label, e.g. \"3 min\""), minutes)
    }

    // MARK: - Running

    private var runningView: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button { showQuitConfirm = true } label: {
                    Image(systemName: "xmark")
                        .font(.system(.subheadline).weight(.medium))
                        .foregroundColor(Theme.secondaryText)
                        .frame(width: 32, height: 32)
                        .background(Theme.card)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Theme.cardBorder, lineWidth: 1))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)

            Spacer()

            ZStack {
                Circle()
                    .stroke(Theme.ringBg, lineWidth: 6)
                Circle()
                    .trim(from: 0, to: totalSeconds > 0 ? CGFloat(elapsed) / CGFloat(totalSeconds) : 0)
                    .stroke(Theme.accentGradient, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: elapsed)
                Text(remainingText)
                    .font(.system(.title, design: .rounded).weight(.semibold))
                    .foregroundColor(Theme.text)
            }
            .frame(width: 140, height: 140)

            Spacer()

            Text(currentLine)
                .id(currentLine)
                .font(.system(.title3, design: .rounded).weight(.medium))
                .foregroundColor(Theme.text)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.horizontal, 36)
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.6), value: currentLine)

            Spacer()

            Button {
                isPaused.toggle()
            } label: {
                Image(systemName: isPaused ? "play.fill" : "pause.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Theme.text)
                    .frame(width: 56, height: 56)
                    .background(Theme.card)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Theme.cardBorder, lineWidth: 1))
            }
            .padding(.bottom, 50)
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
                    Text("イメージが鮮明になった")
                        .font(.system(.title3, design: .rounded).weight(.semibold))
                        .foregroundColor(Theme.text)
                        .multilineTextAlignment(.center)
                    Text("思い描くことで、未来はもっと近づく")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(Theme.secondaryText)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 32)
            Spacer()
            Button {
                dismiss()
            } label: {
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
            .padding(.bottom, 40)
        }
    }

    // MARK: - Actions

    private func start() {
        elapsed = 0
        isPaused = false
        phase = .running
        Analytics.shared.track(AnalyticsEvent.visualizationStarted, ["minutes": "\(selectedMinutes)"])
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    private func finish() {
        phase = .complete
        Analytics.shared.track(AnalyticsEvent.visualizationCompleted)
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
