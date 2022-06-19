import SwiftUI
import XCSnippets

struct SnippetDetailsEditing: View {
    @EnvironmentObject var store: AppStore

    @Binding var snippet: XCSnippet
    @Binding var interactionState: SnippetInteractionState
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            TextField("Title", text: $snippet.title.toUnwrapped(defaultValue: "")).font(.title)
            TextField("Summary", text: $snippet.summary.toUnwrapped(defaultValue: "")).font(.subheadline)
            CodeEditorView(content: $snippet.contents.toUnwrapped(defaultValue: ""))
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
                            TextField("Completion Prefix", text: $snippet.completionPrefix.toUnwrapped(defaultValue: "")).font(.subheadline).fixedSize()
                            Text(snippet.availability?.first?.rawValue ?? "All").font(.subheadline)
                        }
                    }
                }
                Spacer()
            }
            HStack {
                Button("Cancel") {
                    switch interactionState {
                    case .readOnly:
                        ()
                    case .editing:
                        self.interactionState = .readOnly
                    case .creating:
                        self.interactionState = .readOnly
                        store.removeNewSnippet(snippet)
                    }
                }
                Spacer()
                Button("Save") {
                    store.saveSnippet(snippet)
                }
            }
        }.padding()
    }
}

struct SnippetDetailsEditing_Previews: PreviewProvider {
    static var previews: some View {
        SnippetDetailsEditing(snippet: .constant(XCSnippet(title: "Title", content: "Content")), interactionState: .constant(.editing))
    }
}
