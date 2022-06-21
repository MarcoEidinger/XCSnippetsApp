import Foundation
import XCSnippets

let currentDirectoryPath = FileManager.default.currentDirectoryPath
let currentDirectoryPathURL = URL(fileURLWithPath: currentDirectoryPath)
let collectionParentDirectory = currentDirectoryPathURL.deletingLastPathComponent()
let CodeSnippets = collectionParentDirectory.path

print(shell("rm -r \(CodeSnippets)/Collection"))
print(shell("mkdir \(CodeSnippets)/Collection"))
print(shell("cp \(CodeSnippets)/me.codesnippet/*.codesnippet \(CodeSnippets)/Collection"))
print(shell("cp \(CodeSnippets)/ios-xcode-snippets/*.codesnippet \(CodeSnippets)/Collection"))
print(shell("cp \(CodeSnippets)/SwiftSnippets/Snippets/*.codesnippet \(CodeSnippets)/Collection"))
print(shell("cp \(CodeSnippets)/QMUI_iOS_CodeSnippets/*.codesnippet \(CodeSnippets)/Collection"))
print(shell("cp \(CodeSnippets)/XcodeSwiftSnippets/*.codesnippet \(CodeSnippets)/Collection"))
print(shell("rm \(CodeSnippets)/Collection/swift-createproperty.codesnippet"))

//let currentDirectoryPath = FileManager.default.currentDirectoryPath
//let currentDirectoryPathURL = URL(fileURLWithPath: currentDirectoryPath)
let collectionURL = collectionParentDirectory.appendingPathComponent("Collection")
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

func shell(_ command: String) -> String {
    let task = Process()
    let pipe = Pipe()

    task.standardOutput = pipe
    task.standardError = pipe
    task.arguments = ["-c", command]
    task.launchPath = "/bin/zsh"
    task.standardInput = nil
    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)!

    return output
}
