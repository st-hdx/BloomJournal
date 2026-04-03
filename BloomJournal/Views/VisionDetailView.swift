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
    @State private var showDeleteVisionConfirm = false
    @FocusState private var isTitleFocused: Bool

    private var currentVision: Vision {
        store.visions.first(where: { $0.id == vision.id }) ?? vision
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

                Divider().overlay(Theme.cardBorder)

                if currentVision.details.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "square.and.pencil")
                            .font(.system(size: 36))
                            .foregroundColor(Theme.tertiaryText)
                        Text("詳細をまだ追加していません")
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(Theme.tertiaryText)
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(Array(currentVision.details.enumerated()), id: \.offset) { index, detail in
                            Button {
                                editingDetailIndex = index
                                editingDetailText = detail
                            } label: {
                                HStack(alignment: .top, spacing: 12) {
                                    Circle()
                                        .fill(Theme.accentGradient)
                                        .frame(width: 6, height: 6)
                                        .padding(.top, 7)
                                    Text(detail)
                                        .font(.system(.body, design: .rounded))
                                        .foregroundColor(Theme.text)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .onDelete { offsets in
                            store.deleteDetail(at: offsets, for: vision)
                        }
                        .onMove { source, destination in
                            store.moveDetail(from: source, to: destination, for: vision)
                        }
                        .listRowBackground(Theme.card)
                    }
                    .listStyle(.plain)
                    .background(Theme.background)
                    .scrollContentBackground(.hidden)
                }

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
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Theme.background, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 14) {
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
        .alert("詳細を追記", isPresented: $showAddDetail) {
            TextField("ベンツのGLB、駐車場...", text: $newDetail)
            Button("追加") {
                let trimmed = newDetail.trimmingCharacters(in: .whitespaces)
                guard !trimmed.isEmpty else { return }
                store.addDetail(trimmed, to: vision)
                newDetail = ""
            }
            Button("キャンセル", role: .cancel) { newDetail = "" }
        }
        .alert("詳細を編集", isPresented: Binding(
            get: { editingDetailIndex != nil },
            set: { if !$0 { editingDetailIndex = nil } }
        )) {
            TextField("内容", text: $editingDetailText)
            Button("保存") {
                let trimmed = editingDetailText.trimmingCharacters(in: .whitespaces)
                if !trimmed.isEmpty, let idx = editingDetailIndex {
                    store.updateDetail(at: idx, with: trimmed, for: vision)
                }
                editingDetailIndex = nil
            }
            Button("キャンセル", role: .cancel) { editingDetailIndex = nil }
        }
        .alert("ビジョンを削除しますか？", isPresented: $showDeleteVisionConfirm) {
            Button("削除", role: .destructive) {
                store.delete(vision)
                dismiss()
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("「\(currentVision.title)」と追記した内容がすべて削除されます")
        }
        .onAppear {
            if focusOnAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { showAddDetail = true }
            }
        }
    }
}
