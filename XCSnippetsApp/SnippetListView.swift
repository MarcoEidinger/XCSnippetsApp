import SwiftUI
import XCSnippets

struct SnippetListView: View {
    @State private var searchText = ""

    @EnvironmentObject var store: AppStore

    @Binding var selectedItems: Set<XCSnippet>
    @State var showAddToXcodeAlert = false
    @State var showDeleteAlert = false

    var body: some View {
        VStack {
            List(selection: $selectedItems) {
                ForEach(sortedSearchResults, id: \.self) { item in
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "curlybraces").font(.system(size: 15))
                            Text(item.displayName).bold()
                            Spacer()
                            item.languageImage
                                .foregroundColor(.orange)
                                .font(.system(size: 20))
                                .help("Written in Swift")
                            if item.isAvailableInXcode {
                                Image(systemName: "note.text")
                                    .font(.system(size: 20))
                                    .opacity(0.5)
                                    .help("Already added to Xcode")
                            }
                        }.padding()
                    }
                    .tag(item.id)
                }
                .contextMenu {
                    Button {
                        showAddToXcodeAlert = true
                    } label: {
                        Text("Add To Xcode")
                    }
                    Divider().fixedSize()
                    Button {
                        showDeleteAlert = true
                    } label: {
                        Text("Delete")
                    }
                }
                .alert("Do you want to copy the selected item(s) ?", isPresented: $showAddToXcodeAlert, actions: {
                    Button {
                        showAddToXcodeAlert = false
                        DispatchQueue.main.async {
                            do {
                                guard selectedItems.count > 0 else { return }
                                let itemsToCopy = Array(selectedItems)
                                let dir = try PersistentCodeSnippetDirectory(directoryURL: .codeSnippetsUserDirectoryURL)
                                try dir.write(contents: itemsToCopy)
                                self.selectedItems = Set<XCSnippet>()
                                store.loadSnippets()
                            } catch {
                                store.latestError = error
                            }
                        }
                    } label: {
                        Text("""
                        Copy
                        """)
                    }
                    Button("Cancel") {
                        showAddToXcodeAlert = false
                    }
                })
                .alert("Do you want to delete the selected item(s) ?", isPresented: $showDeleteAlert, actions: {
                    Button {
                        showDeleteAlert = false
                        DispatchQueue.main.async {
                            do {
                                guard selectedItems.count > 0 else { return }
                                try store.delete(items: Array(selectedItems))
                            } catch {
                                store.latestError = error
                            }
                        }
                    } label: {
                        Text("""
                        Delete
                        """)
                    }
                    Button("Cancel") {
                        showDeleteAlert = false
                    }
                })
            }
            .listStyle(.bordered(alternatesRowBackgrounds: true))
            .searchable(text: $searchText, prompt: Text("Snippets"))
            .onAppear {
                store.loadSnippets()
            }
            .onChange(of: searchText) { _ in
                self.selectedItems = []
            }
        }
        .frame(minWidth: 300)
    }

    var searchResults: [XCSnippet] {
        if searchText.isEmpty {
            return store.snippets
        } else {
            return store.snippets.filter { snippet in
                snippet.title?.contains(searchText) ?? false ||
                    snippet.summary?.contains(searchText) ?? false ||
                    snippet.contents?.contains(searchText) ?? false
            }
        }
    }

    var filteredSearchResults: [XCSnippet] {
        searchResults
    }

    var sortedSearchResults: [XCSnippet] {
        filteredSearchResults.sorted { one, two in
            one.displayName < two.displayName
        }
    }
}

struct SnippetList_Previews: PreviewProvider {
    static var previews: some View {
        SnippetListView(selectedItems: .constant([])).environmentObject(AppStore())
    }
}
