import Foundation
import SwiftUI

enum SidebarController {
    static func open() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            guard let nsSplitView = findNSSplitVIew(view: NSApp.windows.first?.contentView), let controller = nsSplitView.delegate as? NSSplitViewController else {
                return
            }
            if controller.splitViewItems.first?.isCollapsed == true {
                toggle()
            }
        }
    }

    static func toggle() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }

    private static func findNSSplitVIew(view: NSView?) -> NSSplitView? {
        var queue = [NSView]()
        if let root = view {
            queue.append(root)
        }
        while !queue.isEmpty {
            let current = queue.removeFirst()
            if current is NSSplitView {
                return current as? NSSplitView
            }
            for subview in current.subviews {
                queue.append(subview)
            }
        }
        return nil
    }
}
