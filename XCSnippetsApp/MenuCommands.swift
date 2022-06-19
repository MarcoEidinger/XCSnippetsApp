import SwiftUI
import XCSnippets

struct MenuCommands: Commands {
    var store: AppStore

    var body: some Commands {
        SidebarCommands()
        CommandMenu("Community Snippets") {
            Button("Download Latest") {
                store.downloadLatestCommunitySnippets()
            }
            Button("Restore (Un-delete)") {
                store.restore()
            }
        }
        CommandMenu("Xcode") {
            Button("View snippet directory in Finder") {
                do {
                    let url = try URL.codeSnippetsUserDirectoryURL
                    NSWorkspace.shared.open(url)
                } catch {
                    store.latestError = error
                }
            }
            Button("Restart") {
                if let runningXcode = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.dt.Xcode").first {
                    runningXcode.forceTerminate()
                }
                DispatchQueue.main.async {
                    let task = Process()
                    let pipe = Pipe()

                    task.standardOutput = pipe
                    task.standardError = pipe
                    task.arguments = ["-c", "open -a Xcode"]
                    task.launchPath = "/bin/zsh"
                    task.standardInput = nil
                    task.launch()
                }
            }
        }
        CommandGroup(replacing: .newItem) {
            Button("New Snippet") {
                store.createNewSnippet()
            }.keyboardShortcut("n")
        }
//        CommandGroup(after: .newItem) {
//            Button("Download Latest Community Snippets") {
//                store.downloadLatest()
//            }
//            Button("Restore Community Snippets") {
//                store.restore()
//            }
//        }
        CommandGroup(replacing: .help) {
            Link("GitHub Repo", destination: URL(string: "https://github.com/MarcoEidinger/XCSnippetsApp")!)
            Divider()
            Button("Send Feedback") {
                let service = NSSharingService(named: NSSharingService.Name.composeEmail)
                service?.recipients = ["eidingermarco@gmail.com"]
                service?.subject = "[XCSnippetApp - Feedback]"
                service?.perform(withItems: [])
            }
        }
    }
}
