import Foundation
import SwiftUI
import XCSnippets

enum FilterPlatform: String, Identifiable {
    case any = "Any"
    case universal = "Universal"
    case iOS
    case macOS

    var id: String {
        rawValue
    }

    var displayText: Text {
        switch self {
        case .iOS:
            return Text("iOS \(XCSnippet.Platform.iOS.platformImage) ")
        case .macOS:
            return Text("macOS \(XCSnippet.Platform.macOS.platformImage) ")
        case .universal:
            return Text("Universal")
        case .any:
            return Text("Any")
        }
    }
}

enum FilterLanguage: String, Identifiable {
    case any = "Any"
    case swift = "Swift"
    case objc = "Objective-C"
    case others = "Others"

    var id: String {
        rawValue
    }
}

struct Filter: Equatable {
    var platform: FilterPlatform.ID? = "Any"
    var language: FilterLanguage.ID? = "Any"
}
