import AppKit
import QuickLookUI

@MainActor
final class QuickLookCoordinator: NSObject, QLPreviewPanelDataSource, QLPreviewPanelDelegate {
    static let shared = QuickLookCoordinator()

    private var items: [URL] = []
    private var selectedIndex: Int = 0

    func show(urls: [URL], selected: URL?) {
        items = urls
        if let selected, let index = urls.firstIndex(of: selected) {
            selectedIndex = index
        } else {
            selectedIndex = 0
        }
        guard let panel = QLPreviewPanel.shared() else { return }
        panel.dataSource = self
        panel.delegate = self
        panel.currentPreviewItemIndex = selectedIndex
        panel.makeKeyAndOrderFront(nil)
    }

    nonisolated func numberOfPreviewItems(in panel: QLPreviewPanel) -> Int {
        MainActor.assumeIsolated { items.count }
    }

    nonisolated func previewPanel(_ panel: QLPreviewPanel, previewItemAt index: Int) -> (any QLPreviewItem)? {
        MainActor.assumeIsolated {
            items[index] as NSURL
        }
    }
}
