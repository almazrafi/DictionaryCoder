import Foundation

public enum DictionaryDateEncodingStrategy: Sendable {

    // MARK: - Enumeration Cases

    case deferredToDate

    case millisecondsSince1970
    case secondsSince1970

    case iso8601(style: DictionaryISO8601Style)

    case formatted(DateFormatter)
    case custom(@Sendable (_ date: Date, _ encoder: Encoder) throws -> Void)

    // MARK: - Type Properties

    public static var iso8601: Self {
        .iso8601(style: .dateFormatter)
    }
}
