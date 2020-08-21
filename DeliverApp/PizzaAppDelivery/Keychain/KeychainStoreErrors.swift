import Foundation

enum KeychainStoreErrors: Error {
    case string2DataConversionError
    case data2StringConversionError
    case addToStoreError(returnSingal: String)
    case unhandledError(message: String)
}

extension KeychainStoreErrors: LocalizedError {
    var errorDescription: String? {
        switch self {
            case .string2DataConversionError:
                return NSLocalizedString("String to Data conversion error", comment: "")
            case .addToStoreError(let returnSignal):
                return NSLocalizedString("Error occurred when storing item to keychain. Exited with exit code \(returnSignal).", comment: "")
            case .data2StringConversionError:
                return NSLocalizedString("Data to String conversion error", comment: "")
            case .unhandledError(let message):
                return NSLocalizedString(message, comment: "")
        }
    }
}
