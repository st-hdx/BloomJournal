import SwiftUI

struct VisionDetailView: View {
    @EnvironmentObject private var store: VisionStore
    let vision: Vision
    var focusOnAppear: Bool = false

    @Environment(\.dismiss) private var dismiss
    @State private var showAddDetail = false
    @State private var newDetail = ""
    @State private var editingDetailIndex: Int? = nil
    @State private var editingDetailText = ""
    @State private var showEditDetail = false
    @State private var showDeleteVisionConfirm = false
    @FocusState private var isTitleFocused: Bool

    private var currentVision: Vision {
        store.visions.first(where: { $0.id == vision.id }) ?? vision
    }

    private var shareText: String {
        var lines = ["✨ \(currentVision.title)"]
        if !currentVision.details.isEmpty {
            lines.append("")
            lines.append(contentsOf: currentVision.details.map { "・\($0)" })
        }
        lines.append("")
        lines.append(NSLocalizedString("share_footer", comment: "Appended to shared vision text"))
        return lines.joined(separator: "\n")
    }

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Editable title
                HStack(spacing: 8) {
                    TextField("ビジョン名", text: Binding(
                        get: { currentVision.title },
                        set: { store.updateTitle($0, for: vision) }
                    ))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Theme.text)
                    .focused($isTitleFocused)
                    .submitLabel(.done)

                    if !isTitleFocused {
                        Image(systemName: "pencil")
                            .font(.system(.caption))
                            .foregroundColor(Theme.tertiaryText)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 16)

                LinearGradient(
                    colors: [Theme.accent1.opacity(0.3), Theme.accent2.opacity(0.3)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 1)

                if currentVision.details.isEmpty {
                    Spacer()
                    VStack(spacing: 20) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 44))
                            .foregroundStyle(Theme.accentGradient)

                        VStack(spacing: 8) {
                            Text("まだ詳細がありません")
                                .font(.system(.headline, design: .rounded).weight(.semibold))
                                .foregroundColor(Theme.text)
                            Text("ジャーナリングで気づいたこと、\n具体的なイメージを追記しよう")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(Theme.secondaryText)
                                .multilineTextAlignment(.center)
                                .lineSpacing(3)
                        }

                        Button {
                            showAddDetail = true
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "plus.circle.fill")
                                Text("最初の詳細を追記する")
                            }
                            .font(.system(.body, design: .rounded).weight(.semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 14)
                            .background(Theme.accentGradient)
                            .clipShape(Capsule())
                            .shadow(color: Theme.accent1.opacity(0.3), radius: 8, y: 3)
                        }
                    }
                    .padding(.horizontal, 32)
                    Spacer()
                } else {
                    List {
                        ForEach(Array(currentVision.details.enumerated()), id: \.offset) { index, detail in
                            Button {
                                editingDetailIndex = index
                                editingDetailText = detail
                                showEditDetail = true
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            } label: {
                                HStack(alignment: .top, spacing: 12) {
                                    LinearGradient(
                                        colors: [Theme.accent1, Theme.accent2],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                    .frame(width: 3)
                                    .clipShape(Capsule())
                                    .frame(height: 18)
                                    .padding(.top, 2)

                                    Text(detail)
                                        .font(.system(.body, design: .rounded))
                                        .foregroundColor(Theme.text)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(.vertical, 6)
                            }
                            .listRowSeparator(.hidden)
                        }
                        .onDelete { offsets in
                            store.deleteDetail(at: offsets, for: vision)
                        }
                        .onMove { source, destination in
                            store.moveDetail(from: source, to: destination, for: vision)
                        }
                        .listRowBackground(Theme.background)
                    }
                    .listStyle(.plain)
                    .background(Theme.background)
                    .scrollContentBackground(.hidden)
                }

                if !currentVision.details.isEmpty {
                    Button {
                        showAddDetail = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                            Text("追記する")
                        }
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
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.background, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 14) {
                    ShareLink(item: shareText) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(Theme.text)
                    }
                    EditButton()
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(Theme.text)
                    Button(role: .destructive) {
                        showDeleteVisionConfirm = true
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(Theme.accent2)
                    }
                }
            }
        }
        .sheet(isPresented: $showAddDetail, onDismiss: { newDetail = "" }) {
            TextInputSheet(
                title: "詳細を追記",
                placeholder: "ベンツのGLB、駐車場...",
                text: $newDetail,
                buttonLabel: "追記する"
            ) {
                let trimmed = newDetail.trimmingCharacters(in: .whitespaces)
                guard !trimmed.isEmpty else { return }
                store.addDetail(trimmed, to: vision)
                newDetail = ""
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
        }
        .sheet(isPresented: $showEditDetail, onDismiss: { editingDetailIndex = nil }) {
            TextInputSheet(
                title: "詳細を編集",
                placeholder: "内容",
                text: $editingDetailText,
                buttonLabel: "保存する"
            ) {
                let trimmed = editingDetailText.trimmingCharacters(in: .whitespaces)
                if !trimmed.isEmpty, let idx = editingDetailIndex {
                    store.updateDetail(at: idx, with: trimmed, for: vision)
                }
                editingDetailIndex = nil
            }
        }
        .alert("ビジョンを削除しますか？", isPresented: $showDeleteVisionConfirm) {
            Button("削除", role: .destructive) {
                store.delete(vision)
                dismiss()
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text(String(format: NSLocalizedString("delete_vision_confirm_message", comment: "Confirmation message before deleting a vision"), currentVision.title))
        }
        .onAppear {
            if focusOnAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { showAddDetail = true }
            }
        }
    }
}
