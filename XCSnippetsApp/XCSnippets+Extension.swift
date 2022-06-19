import Foundation
import SwiftUI
import XCSnippets

extension XCSnippet {
    var displayName: String {
        title ?? summary ?? id
    }
}

extension XCSnippet {
    var languagePrefix: String {
        switch language {
        case .swift:
            return "Swift"
        case .objc:
            return "Objc"
        case .generic:
            return "Generic"
        default:
            return "Other"
        }
    }
}

extension XCSnippet {
    var languageImage: some View {
        switch language {
        case .swift:
            return AnyView(Image(systemName: "swift"))
        default:
            return AnyView(EmptyView())
        }
    }
}

extension XCSnippet {
    var platformImage: Image {
        guard let ptf = platform else { return Image(systemName: "globe") }
        switch ptf {
        case .iOS:
            return Image(systemName: "iphone")
        case .macOS:
            return Image(systemName: "macpro.gen1")
        case .watchOS:
            return Image(systemName: "applewatch")
        case .tvOS:
            return Image(systemName: "appletv")
        default:
            return Image(systemName: "globe")
        }
    }
}

extension XCSnippet.Platform: CaseIterable {
    public static var allCases: [XCSnippet.Platform] = [.all, .iOS, .macOS, .watchOS, .tvOS]
}

extension XCSnippet.Language: Identifiable {
    public var id: String {
        rawValue
    }
}

extension XCSnippet.Platform: Identifiable {
    public var id: String {
        rawValue
    }
}

extension XCSnippet.Platform {
    var platformImage: Image {
        switch self {
        case .iOS:
            return Image(systemName: "iphone")
        case .macOS:
            return Image(systemName: "macpro.gen1")
        case .watchOS:
            return Image(systemName: "applewatch")
        case .tvOS:
            return Image(systemName: "appletv")
        default:
            return Image(systemName: "globe")
        }
    }
}

extension XCSnippet.Platform {
    var displayText: Text {
        switch self {
        case .iOS:
            return Text("\(platformImage) iOS")
        case .macOS:
            return Text("\(platformImage) macOs")
        case .tvOS:
            return Text("\(platformImage) tvOS")
        case .watchOS:
            return Text("\(platformImage) watchOS")
        default:
            return Text("\(platformImage) All")
        }
    }
}

extension XCSnippet {
    var isAvailableInXcode: Bool {
        XcodeSnippetCache.shared.xcodeSnippets.contains(where: { $0.id == id })
    }
}
