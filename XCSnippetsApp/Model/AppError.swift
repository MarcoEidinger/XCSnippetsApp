import Foundation

enum AppError: Error {
    case incorrectDownloadURL

    var localizedDescription: String {
        switch self {
        case .incorrectDownloadURL:
            return "Incorrect download url"
        }
    }
}

extension AppError: LocalizedError {
    /// A localized message describing what error occurred.
    var errorDescription: String? {
        localizedDescription
    }

    /// A localized message describing the reason for the failure.
    var failureReason: String? {
        nil
    }

    /// A localized message describing how one might recover from the failure.
    var recoverySuggestion: String? {
        nil
    }

    /// A localized message providing "help" text if the user requests help.
    var helpAnchor: String? {
        nil
    }
}
