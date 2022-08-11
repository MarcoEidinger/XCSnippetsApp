import SwiftUI
import XCSnippets

@main
struct XCSnippetsApp: App {
    var store: AppStore = .init()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .onAppear {
                    createCodeSnippetsUserDirectoryIfNeccessary()
                }
        }
        .commands {
            MenuCommands(store: store)
        }
    }

    func createCodeSnippetsUserDirectoryIfNeccessary() {
        do {
            guard try URL.xcodeUserDataDirectoryURL.existsAsDirectory == true else { return }
            guard try URL.codeSnippetsUserDirectoryURL.existsAsDirectory == false else { return }

            try FileManager.default.createDirectory(at: URL.codeSnippetsUserDirectoryURL,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
        } catch {
            print(error.localizedDescription)
        }
    }
}
