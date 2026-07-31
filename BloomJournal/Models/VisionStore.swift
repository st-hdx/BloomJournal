import Foundation
import Combine
import SwiftUI

class VisionStore: ObservableObject {
    @Published var visions: [Vision] = []

    private let saveURL: URL = {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("visions.json")
    }()

    init() {
        let args = ProcessInfo.processInfo.arguments
        if args.contains("-uitestEmpty") { visions = []; return }          // Onboarding 撮影用
        if args.contains("-uitestSeed") {                                   // Home 以降の撮影用
            var v1 = Vision(title: "Buy my dream home");   v1.details = ["Big kitchen for hosting friends"]
            var v2 = Vision(title: "Reach $150k income");  v2.details = ["Build a stronger investment portfolio"]
            var v3 = Vision(title: "Get fit and healthy"); v3.details = ["Gym 3 times a week"]
            let v4 = Vision(title: "Trip to Hawaii")
            visions = [v1, v2, v3, v4]; return
        }
        load()
    }

    func add(title: String) {
        visions.append(Vision(title: title))
        save()
    }

    func delete(_ vision: Vision) {
        visions.removeAll { $0.id == vision.id }
        save()
    }

    func moveVision(from source: IndexSet, to destination: Int) {
        visions.move(fromOffsets: source, toOffset: destination)
        save()
    }

    func addDetail(_ detail: String, to vision: Vision) {
        guard let index = visions.firstIndex(where: { $0.id == vision.id }) else { return }
        visions[index].details.append(detail)
        save()
    }

    func updateTitle(_ title: String, for vision: Vision) {
        guard let index = visions.firstIndex(where: { $0.id == vision.id }) else { return }
        visions[index].title = title
        save()
    }

    func deleteDetail(at offsets: IndexSet, for vision: Vision) {
        guard let index = visions.firstIndex(where: { $0.id == vision.id }) else { return }
        visions[index].details.remove(atOffsets: offsets)
        save()
    }

    func moveDetail(from source: IndexSet, to destination: Int, for vision: Vision) {
        guard let index = visions.firstIndex(where: { $0.id == vision.id }) else { return }
        visions[index].details.move(fromOffsets: source, toOffset: destination)
        save()
    }

    func updateDetail(at detailIndex: Int, with newText: String, for vision: Vision) {
        guard let index = visions.firstIndex(where: { $0.id == vision.id }) else { return }
        visions[index].details[detailIndex] = newText
        save()
    }

    func binding(for vision: Vision) -> Binding<Vision>? {
        guard let index = visions.firstIndex(where: { $0.id == vision.id }) else { return nil }
        return Binding(
            get: { self.visions[index] },
            set: { self.visions[index] = $0; self.save() }
        )
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(visions) else { return }
        try? data.write(to: saveURL)
    }

    private func load() {
        guard let data = try? Data(contentsOf: saveURL),
              let decoded = try? JSONDecoder().decode([Vision].self, from: data) else { return }
        visions = decoded
    }
}
