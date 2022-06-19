import SwiftUI
import XCSnippets

struct SnippetDetailsView: View {
    @Binding var snippet: XCSnippet
    @Binding var interactionState: SnippetInteractionState

    var body: some View {
        VStack(alignment: .leading) {
            switch interactionState {
            case .readOnly:
                SnippetDetailsReadOnly(snippet: snippet, interactionState: $interactionState)
            case .editing:
                SnippetDetailsEditing(snippet: $snippet, interactionState: $interactionState)
            case .creating:
                SnippetDetailsEditing(snippet: $snippet, interactionState: $interactionState)
            }
        }
    }
}

struct SnippetDetailsReadOnly: View {
    @EnvironmentObject var store: AppStore

    var snippet: XCSnippet
    @Binding var interactionState: SnippetInteractionState

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let title = snippet.title {
                Text(title).font(.title)
            }
            if let summary = snippet.summary {
                Text(summary).font(.subheadline)
            }
            if let contents = snippet.contents {
                VStack {
                    CodeEditorView(content: .constant(contents))
                }
            }
            HStack {
                Spacer()
                VStack(alignment: .center, spacing: 10) {
                    HStack {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Language").font(.subheadline)
                            Text("Platform").font(.subheadline)
                            Text("Completion").font(.subheadline)
                            Text("Availability").font(.subheadline)
                        }
                        VStack(alignment: .leading, spacing: 10) {
                            Text(snippet.language?.rawValue ?? "N/A").font(.subheadline)
                            Text(snippet.platform?.rawValue ?? "All").font(.subheadline)
                            Text(snippet.completionPrefix ?? "None").font(.subheadline)
                            Text(snippet.availability?.first?.rawValue ?? "All").font(.subheadline)
                        }
                    }
                }
                Spacer()
            }
            HStack {
                Button {
                    do {
                        try store.delete(items: [self.snippet])
                    } catch {
                        store.latestError = error
                    }
                } label: {
                    Text("Delete")
                }
                .help("Delete")

                Spacer()

                Button {
                    self.interactionState = .editing
                } label: {
                    Image(systemName: "pencil")
                }
                .help("Edit")

                Button {
                    do {
                        try snippet.write(to: .codeSnippetsUserDirectoryURL)
                        XcodeSnippetCache.shared.getXcodeSnippets()
                        store.latestInfo = "Done"
                    } catch {
                        store.latestError = error
                    }
                } label: {
                    Text(getXcodeButtonText())
                }
                .help(getXcodeButtonText())
            }
        }
        .padding()
    }

    func getXcodeButtonText() -> String {
        snippet.isAvailableInXcode ? "Override in Xcode" : "Add to Xcode"
    }
}

struct SnippetDetails_Previews: PreviewProvider {
    static var previews: some View {
        SnippetDetailsView(snippet: .constant(.init(title: "Title", summary: "Summary", language: .swift, platform: .all, completion: "demo", availability: [.all], content: "print(\"Hello, World\")")), interactionState: .constant(.readOnly))
        // .frame(width: 1000, height: 500)
    }
}
