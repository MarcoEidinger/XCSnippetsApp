import Foundation
import XCSnippets

class XcodeSnippetCache {
    static var shared: XcodeSnippetCache = .init()

    var xcodeSnippets: [XCSnippet] = []

    init() {
        getXcodeSnippets()
        Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { [self] _ in
            getXcodeSnippets()
        }
    }

    func getXcodeSnippets() {
        do {
            xcodeSnippets = try PersistentCodeSnippetDirectory().readContents()
        } catch {}
    }
}
