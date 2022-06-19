import Foundation

extension URL {
    static var resourceURL: URL {
        Bundle.main.resourceURL!
    }

    static var storageURL: URL {
        let fileManager = FileManager.default

        let folder = fileManager.urls(for: .applicationSupportDirectory,
                                      in: .userDomainMask).first!

        let appFolder = folder.appendingPathComponent(Bundle.main.bundleIdentifier ?? "XCSnippetsApp")
        var isDirectory: ObjCBool = false
        let folderExists = fileManager.fileExists(atPath: appFolder.path,
                                                  isDirectory: &isDirectory)
        if !folderExists || !isDirectory.boolValue {
            // swiftlint:disable:next force_try
            try! fileManager.createDirectory(at: appFolder,
                                             withIntermediateDirectories: true,
                                             attributes: nil)
        }

        return appFolder
    }
}
