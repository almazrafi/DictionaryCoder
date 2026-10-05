import Foundation

/// The styles of dates formatted according to the ISO 8601 standard.
public enum DictionaryISO8601Style: Sendable {

    // MARK: - Enumeration Cases

    /// The style of `ISO8601DateFormatter`, the default one.
    case dateFormatter

    /// The style of `Date.ISO8601FormatStyle`, as in `JSONEncoder` and `JSONDecoder`:
    /// fractions of a second are dropped when encoding and accepted when decoding.
    case formatStyle
}

extension DictionaryISO8601Style {

    // MARK: - Instance Methods

    internal func string(from date: Date) -> String {
        switch self {
        case .dateFormatter:
            // `ISO8601DateFormatter` rounds dates to milliseconds before dropping fractions of a second.
            let milliseconds = (date.timeIntervalSince1970 * 1000 + 0.5).rounded(.down)
            let seconds = (milliseconds / 1000).rounded(.down)

            return Date.ISO8601FormatStyle.internetDateTime.format(Date(timeIntervalSince1970: seconds))

        case .formatStyle:
            return Date.ISO8601FormatStyle.internetDateTime.format(date)
        }
    }

    internal func date(from string: String) -> Date? {
        switch self {
        case .dateFormatter:
            // Both parse dates with whole seconds alike, but the format style is much faster.
            if string.isInternetDateTimeWithWholeSeconds,
               let date = try? Date.ISO8601FormatStyle.internetDateTime.parse(string) {
                return date
            }

            return ISO8601DateFormatter().date(from: string)

        case .formatStyle:
            return try? Date.ISO8601FormatStyle.internetDateTime.parse(string)
        }
    }
}

extension Date.ISO8601FormatStyle {

    // MARK: - Type Properties

    // Creating a style costs nearly as much as formatting a date with it, so a single one is shared.
    fileprivate static let internetDateTime = Self()
}

extension String {

    // MARK: - Type Properties

    // The ranges of the year, month, day, hour, minute, second and time zone offset in hours and minutes.
    private static let internetDateTimeFieldRanges = [1...9999, 1...12, 1...31, 0...23, 0...59, 0...59, 0...23, 0...59]

    // MARK: - Instance Properties

    // Whether the string is like `2001-02-03T04:05:06Z` or `2001-02-03T04:05:06+07:00` with fields in their ranges,
    // unlike strings with fractions of a second or a leap second, for example,
    // which only `Date.ISO8601FormatStyle` accepts.
    fileprivate var isInternetDateTimeWithWholeSeconds: Bool {
        let template = utf8.count == 20 ? "0000-00-00T00:00:00Z" : "0000-00-00T00:00:00+00:00"

        guard utf8.count == template.utf8.count else {
            return false
        }

        var field = 0
        var value = 0

        for (character, templateCharacter) in zip(utf8, template.utf8) {
            if templateCharacter == UInt8(ascii: "0") {
                guard (UInt8(ascii: "0")...UInt8(ascii: "9")).contains(character) else {
                    return false
                }

                value = value * 10 + Int(character - UInt8(ascii: "0"))
                continue
            }

            let isSeparator = character == templateCharacter
                || templateCharacter == UInt8(ascii: "+") && character == UInt8(ascii: "-")

            guard isSeparator, Self.internetDateTimeFieldRanges[field].contains(value) else {
                return false
            }

            field += 1
            value = 0
        }

        // A time zone offset ends with its minutes rather than a separator.
        return field == 6 || Self.internetDateTimeFieldRanges[field].contains(value)
    }
}
