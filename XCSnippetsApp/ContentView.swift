import SwiftUI
import XCSnippets

struct ContentView: View {
    @EnvironmentObject var store: AppStore

    var body: some View {
        NavigationView {
            SidebarView()

            SnippetListView(selectedItems: $store.selectedItems)

            if store.selectedItem != nil, store.selectedItems.count == 1 {
                Binding($store.selectedItem).map {
                    SnippetDetailsView(snippet: $0, interactionState: $store.interactionState)
                        .frame(height: 600)
                }
            } else {
                if store.selectedItems.count > 1 {
                    MultiSelectionView()
                } else {
                    InitialMainView(interactionState: $store.interactionState) // .background(Color(NSColor.textBackgroundColor))
                }
            }
        }
        .errorAlert(error: $store.latestError)
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: SidebarController.toggle, label: {
                    Image(systemName: "sidebar.leading")
                })
            }
            ToolbarItem(placement: .status) {
                if let info = self.store.latestInfo {
                    Text("\(Image(systemName: "info.circle")) \(info)").bold()
                } else {
                    EmptyView()
                }
            }
            ToolbarItem(placement: .automatic) {
                Button("\(Image(systemName: "plus"))") {
                    store.createNewSnippet()
                }
            }
        }
        .navigationTitle("Code Snippet Viewer")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
