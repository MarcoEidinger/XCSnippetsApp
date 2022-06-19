import SwiftUI
import XCSnippets

@main
struct XCSnippetsApp: App {
    var store: AppStore = .init()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
        .commands {
            MenuCommands(store: store)
        }
    }
}
