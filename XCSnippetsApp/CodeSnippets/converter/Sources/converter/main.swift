import Foundation
import XCSnippets

let currentDirectoryPath = FileManager.default.currentDirectoryPath
let currentDirectoryPathURL = URL(fileURLWithPath: currentDirectoryPath)
let collectionURL = currentDirectoryPathURL.deletingLastPathComponent().appendingPathComponent("Collection")
let localDirectory = collectionURL

let files = try! FileManager.default.contentsOfDirectory(at: localDirectory, includingPropertiesForKeys: nil)
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
            print("Conversion error \(error.localizedDescription) for  \(file.debugDescription)")
            throw error
        }
    }

    let encoder = PropertyListEncoder()
    encoder.outputFormat = .xml
    var jsonRoot = ["list": []]
    for item in loadedSnippets {
        let data = try encoder.encode(item)
        let dict = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as! [String: Any]
        jsonRoot["list"]?.append(dict)
    }
    let jsonData: Data
    if #available(macOS 10.13, *) {
        jsonData = try JSONSerialization.data(withJSONObject: jsonRoot, options: .sortedKeys)
    } else {
        jsonData = try JSONSerialization.data(withJSONObject: jsonRoot, options: .prettyPrinted)
    }
    let targetDirectory = currentDirectoryPathURL.deletingLastPathComponent()
    try jsonData.write(to: targetDirectory.appendingPathComponent("snippets.json"))

} catch {
    print(error.localizedDescription)
}
