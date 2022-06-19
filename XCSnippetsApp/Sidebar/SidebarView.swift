import SwiftUI
import XCSnippets

struct SidebarView: View {
    @EnvironmentObject var store: AppStore

    @State var filterSelection: Filter = .init()

    @State var languages: [FilterLanguage] = [.any, .swift, .objc, .others]
    @State var platforms: [FilterPlatform] = [.any, .universal, .iOS, .macOS]

    var body: some View {
        VStack(alignment: .leading) {
            List(selection: $filterSelection.language) {
                Section("Language") {
                    ForEach(languages, id: \.id) { type in
                        Text(type.rawValue).badge(count(for: type))
                    }
                }
            }
            .frame(height: 150)
            List(selection: $filterSelection.platform) {
                Section("Platform") {
                    ForEach(platforms, id: \.id) { type in
                        type.displayText.badge(count(for: type))
                    }
                }
            }
            .frame(height: 150)
            Spacer()
        }
        .listStyle(.sidebar)
        .onChange(of: filterSelection, perform: { newValue in
            store.filter = newValue
        })
    }

    func count(for platform: FilterPlatform) -> Int {
        let snippetsConformingToFilter = store.snippets.filter { snippet in
            guard let snippetsPlatform = snippet.platform else { return false }
            switch platform {
            case .iOS:
                return snippetsPlatform == .iOS
            case .macOS:
                return snippetsPlatform == .macOS
            case .universal:
                return snippetsPlatform == .all
            case .any:
                return true
            }
        }
        return snippetsConformingToFilter.count
    }

    func count(for language: FilterLanguage) -> Int {
        let snippetsConformingToFilter = store.snippets.filter { snippet in
            guard let snippetsLanguage = snippet.language else { return false }
            switch language {
            case .swift:
                return snippetsLanguage == .swift
            case .objc:
                return snippetsLanguage == .objc
            case .others:
                return (snippetsLanguage != .swift && snippetsLanguage != .objc)
            case .any:
                return true
            }
        }
        return snippetsConformingToFilter.count
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView()
            .frame(width: 400, height: 1000)
            .environmentObject(AppStore())
    }
}
