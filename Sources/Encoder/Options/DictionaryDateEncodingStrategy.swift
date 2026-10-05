import Foundation

public enum DictionaryDateEncodingStrategy: Sendable {

    // MARK: - Enumeration Cases

    case deferredToDate

    case millisecondsSince1970
    case secondsSince1970

    case iso8601

    case formatted(DateFormatter)
    case custom(@Sendable (_ date: Date, _ encoder: Encoder) throws -> Void)
}
