import SwiftUI
import XCSnippets

final class AppStore: ObservableObject {
    @Published var latestError: Error?

    @Published var latestInfo: String? {
        didSet {
            if latestInfo != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.latestInfo = nil
                }
            }
        }
    }

    @Published var filter: Filter = .init() {
        didSet {
            let all: [XCSnippet] = getAllSnippets()
            let languageFiltered: [XCSnippet] = all.filter { snippet in
                guard let selectedFilterLanguageID = filter.language else { return true }
                let selectedFilterLanguage = FilterLanguage(rawValue: selectedFilterLanguageID)!
                guard let language = snippet.language else { return true }
                switch selectedFilterLanguage {
                case .swift:
                    return language == .swift
                case .objc:
                    return language == .objc
                case .others:
                    return language != .swift && language != .objc
                case .any:
                    return true
                }
            }

            let platformAndLanguageFiltered = languageFiltered.filter { snippet in
                guard let selectedFilterPlatformID = filter.platform else { return true }
                guard let platform = snippet.platform else { return true }
                let selectedFilterPlatform = FilterPlatform(rawValue: selectedFilterPlatformID)!
                switch selectedFilterPlatform {
                case .any:
                    return true
                case .iOS:
                    return platform == .iOS
                case .macOS:
                    return platform == .macOS
                case .universal:
                    return platform == .all
                }
            }

            snippets = platformAndLanguageFiltered
        }
    }

    @Published private(set) var snippets: [XCSnippet] = []
    @Published var selectedItems = Set<XCSnippet>() {
        didSet {
            if selectedItems.count == 1 {
                selectedItem = Array(selectedItems).first!
            } else {
                selectedItem = nil
            }
        }
    }

    @Published var interactionState: SnippetInteractionState = .readOnly

    @Published var selectedItem: XCSnippet? {
        didSet {
            guard let item = selectedItem, selectedItems.count == 0 else { return }
            selectedItems = [item]
        }
    }
}

extension AppStore: CustomDebugStringConvertible {
    var debugDescription: String {
        "\(snippets.count) with selectedItems \(selectedItems.count) and selected item \(selectedItem?.displayName ?? "N/A")"
    }
}

extension AppStore {
    private func getAllSnippets() -> [XCSnippet] {
        let userDefaults = UserDefaults.standard
        let deletedSnippetIds = userDefaults.object(forKey: "deletedSnippetIds") as? [String] ?? []

        var communitySnippets = getCommunitySnippets()
        var modifiedSnippets = loadSnippets(localDirectory: .storageURL)
        communitySnippets.removeAll { snippet in
            guard modifiedSnippets.first(where: { $0.id == snippet.id }) != nil else { return false }
            return true
        }
        communitySnippets.removeAll(where: { deletedSnippetIds.contains($0.id) })
        modifiedSnippets.removeAll(where: { deletedSnippetIds.contains($0.id) })
        return communitySnippets + modifiedSnippets
    }

    private func loadSnippets(jsonFile: URL) -> [XCSnippet] {
        do {
            let jsonData = try Data(contentsOf: jsonFile)
            let jsonRoot = try JSONDecoder().decode(CodeSnippets.self, from: jsonData)
            let loadedSnippets = jsonRoot.list
            return loadedSnippets
        } catch {
            print("\(jsonFile.absoluteString) is not available (which is allowed)")
        }

        return []
    }

    func loadSnippets(localDirectory: URL) -> [XCSnippet] {
        let files = try! FileManager.default.contentsOfDirectory(at: localDirectory, includingPropertiesForKeys: nil) // swiftlint:disable:this force_try

        let sURLs = files.filter { file in
            let filePath = file.absoluteString
            return filePath.contains("codesnippet")
        }
        do {
            let loadedSnippets: [XCSnippet] = try sURLs.map { file in
                do {
                    return try Data(contentsOf: file)
                        .toXCSnippet()
                } catch {
                    print(error.localizedDescription)
                    throw error
                }
            }
            return loadedSnippets
        } catch {
            print(error.localizedDescription)
            return []
        }
    }

    func loadSnippets() {
        snippets = getAllSnippets()
        // exportToJson()
    }

    func exportToJson() {
        do {
            let encoder = PropertyListEncoder()
            encoder.outputFormat = .xml
            var jsonRoot = ["list": []]
            for item in snippets {
                let data = try encoder.encode(item)
                let dict = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as! [String: Any] // swiftlint:disable:this force_cast
                jsonRoot["list"]?.append(dict)
            }
            let jsonData = try JSONSerialization.data(withJSONObject: jsonRoot, options: .prettyPrinted)
            try jsonData.write(to: .storageURL.appendingPathComponent("test.json"))
        } catch {
            latestError = error
        }
    }

    func createNewSnippet() {
        interactionState = .creating
        let newSnippet = XCSnippet(title: "New", content: "")
        snippets.append(newSnippet)
        DispatchQueue.main.async {
            self.selectedItems = [newSnippet]
        }
    }

    func removeNewSnippet(_ snippet: XCSnippet) {
        guard let idx = snippets.firstIndex(where: { $0.id == snippet.id }) else { return }
        snippets.remove(at: idx)
        DispatchQueue.main.async {
            self.selectedItems = []
        }
    }

    func addSnippet(_ snippet: XCSnippet) {
        snippets.append(snippet)
        DispatchQueue.main.async {
            self.selectedItem = snippet
        }
    }

    func saveSnippet(_ snippet: XCSnippet) {
        do {
            try snippet.write(to: .storageURL)
            let restoreSelection = snippet
            interactionState = .readOnly
            loadSnippets()
            DispatchQueue.main.async {
                self.selectedItems = [restoreSelection]
            }
        } catch {
            latestError = error
        }
    }

    func delete(items: [XCSnippet]) throws {
        do {
            let itemsToDelete = Array(selectedItems)
            let dir = try PersistentCodeSnippetDirectory(directoryURL: .storageURL)
            try dir.delete(contents: itemsToDelete)
        } catch {
            print("Deletion was on a community snippet")

            let userDefaults = UserDefaults.standard
            var deletedSnippetIds = userDefaults.object(forKey: "deletedSnippetIds") as? [String] ?? []
            let new = items.map(\.id)
            deletedSnippetIds.append(contentsOf: new)
            userDefaults.set(deletedSnippetIds, forKey: "deletedSnippetIds")
        }
        selectedItems = Set<XCSnippet>()
        loadSnippets()
    }

    func restore() {
        let userDefaults = UserDefaults.standard
        userDefaults.set([], forKey: "deletedSnippetIds")
        selectedItems = Set<XCSnippet>()
        loadSnippets()
    }

    func getCommunitySnippets() -> [XCSnippet] {
        // latest download by user (if ever done)
        var communitySnippets = loadSnippets(jsonFile: .storageURL.appendingPathComponent("snippets.json"))
        if communitySnippets.count == 0 {
            communitySnippets = loadSnippets(jsonFile: Bundle.main.url(forResource: "snippets", withExtension: "json")!)
        }
        return communitySnippets
    }

    func compareStoredCommunitySnippets(with jsonData: Data) -> Bool {
        do {
            let storedCommunitySnippets = getCommunitySnippets()
            let jsonRoot = try JSONDecoder().decode(CodeSnippets.self, from: jsonData)
            let newCommunitySnippets = jsonRoot.list
            return storedCommunitySnippets != newCommunitySnippets
        } catch {
            return true
        }
    }

    func downloadLatestCommunitySnippets() {
        Task {
            do {
                guard let downloadURL = URL(string: "https://gist.githubusercontent.com/MarcoEidinger/d716f1264d936e0615f6ed8c3dc34c0a/raw/4bb4bf67c73d1775a27c16ef2709afe512c98009/Snippets.json") else {
                    throw AppError.incorrectDownloadURL
                }
                let response = try await URLSession.shared.data(from: downloadURL)

                if self.compareStoredCommunitySnippets(with: response.0) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.latestInfo = "Latest version downloaded and applied"
                    }
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        self.latestInfo = "No new snippets"
                    }
                }

                try response.0.write(to: .storageURL.appendingPathComponent("snippets.json"))
                DispatchQueue.main.async {
                    self.selectedItems = Set<XCSnippet>()
                    self.loadSnippets()
                }
            } catch {
                DispatchQueue.main.async {
                    self.latestError = error
                }
            }
        }
    }
}
