import Foundation

/// The strategies available for formatting dates when decoding them from Dictionary.
public enum DictionaryDateDecodingStrategy: Sendable {

    // MARK: - Enumeration Cases

    /// The strategy that uses formatting from the Date structure.
    case deferredToDate

    /// The strategy that decodes dates in terms of seconds since midnight UTC on January 1st, 1970.
    case secondsSince1970

    /// The strategy that decodes dates in terms of milliseconds since midnight UTC on January 1st, 1970.
    case millisecondsSince1970

    /// The strategy that formats dates according to the ISO 8601 standard in the given style.
    case iso8601(style: DictionaryISO8601Style)

    /// The strategy that defers formatting settings to a supplied date formatter.
    case formatted(DateFormatter)

    /// The strategy that formats custom dates by calling a user-defined function.
    case custom(@Sendable (_ decoder: Decoder) throws -> Date)

    // MARK: - Type Properties

    /// The strategy that formats dates according to the ISO 8601 standard in the style of `ISO8601DateFormatter`.
    public static var iso8601: Self {
        .iso8601(style: .dateFormatter)
    }
}
