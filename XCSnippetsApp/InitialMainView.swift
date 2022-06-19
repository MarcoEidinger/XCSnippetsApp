import SwiftUI
import UniformTypeIdentifiers
import XCSnippets

struct InitialMainView: View {
    @EnvironmentObject var store: AppStore

    @State private var dragOver = false
    @State var snippet: XCSnippet?
    @Binding var interactionState: SnippetInteractionState
    @State var errorMsg: String?
    var body: some View {
        VStack {
            if snippet == nil {
                VStack(spacing: 20) {
                    VStack {
                        Text("Explore code snippets from the Swift and iOS community, view and edit the snippets before adding them conveniently to Xcode").font(.title2)
                            .frame(width: 400)
                    }

                    VStack {
                        Text("OR")
                    }
                }
                VStack {
                    Button("Import files...") {
                        self.errorMsg = nil
                        let panel = NSOpenPanel()
                        panel.allowsMultipleSelection = true
                        panel.canChooseDirectories = true
                        if let type = UTType(filenameExtension: "codesnippet") {
                            panel.allowedContentTypes = [type]
                        }
                        if panel.runModal() == .OK {
                            for url in panel.urls {
                                do {
                                    let isDirectory = (try? url.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false

                                    if isDirectory {
                                        let dir = try PersistentCodeSnippetDirectory(directoryURL: url)
                                        let snippets = try dir.readContents()
                                        let lib = try PersistentCodeSnippetDirectory(directoryURL: .storageURL)
                                        try lib.write(contents: snippets)
                                    } else {
                                        if let data = FileManager.default.contents(atPath: url.path) {
                                            try data.toXCSnippet().write(to: .storageURL)
                                        }
                                    }

                                    store.loadSnippets()
                                } catch {
                                    store.latestError = error
                                }
                            }
                        }
                    }
                    Image(systemName: "square.and.arrow.down").font(.system(size: 60)).opacity(0.4)
                    Text("Drag & Drop a .codesnippet file here").font(.footnote).padding(1)
                }
                .padding()
                .onDrop(of: [.fileURL], isTargeted: $dragOver, perform: { providers in
                    providers.first?.loadDataRepresentation(forTypeIdentifier: UTType.fileURL.identifier, completionHandler: { data, error in
                        guard let data = data,
                              let path = String(data: data, encoding: .utf8),
                              let url = URL(string: path as String) else { return }
                        do {
                            let importedSnippet = try Data(contentsOf: url).toXCSnippet()
                            try importedSnippet.write(to: .storageURL)
                            DispatchQueue.main.async {
                                store.addSnippet(importedSnippet)
                            }
                        } catch {
                            store.latestError = error
                        }
                    })
                    return true
                })
            }
            if let errorMsg = errorMsg {
                Text(errorMsg).foregroundColor(.red)
            }
        }
    }
}

struct InitialMainView_Previews: PreviewProvider {
    static var previews: some View {
        InitialMainView(interactionState: .constant(.readOnly))
            .frame(width: 600, height: 600)
            .preferredColorScheme(.dark)
    }
}
