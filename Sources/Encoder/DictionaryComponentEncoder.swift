import Foundation

internal protocol DictionaryComponentEncoder {

    // MARK: - Instance Properties

    var options: DictionaryEncodingOptions { get }
    var userInfo: [CodingUserInfoKey: Any] { get }
}

extension DictionaryComponentEncoder {

    // MARK: - Instance Methods

    private func encodePrimitiveValue(
        _ value: Any?,
        at codingPath: [CodingKey]
    ) -> DictionaryComponent {
        .value(value)
    }

    private func encodeNonPrimitiveValue<T: Encodable>(
        _ value: T,
        at codingPath: [CodingKey]
    ) throws -> DictionaryComponent {
        let encoder = DictionarySingleValueEncodingContainer(
            options: options,
            userInfo: userInfo,
            codingPath: codingPath
        )

        try value.encode(to: encoder)

        return .value(encoder.resolveValue())
    }

    private func encodeCustomizedValue<T: Encodable>(
        _ value: T,
        at codingPath: [CodingKey],
        closure: (_ value: T, _ encoder: Encoder) throws -> Void
    ) throws -> DictionaryComponent {
        let encoder = DictionarySingleValueEncodingContainer(
            options: options,
            userInfo: userInfo,
            codingPath: codingPath
        )

        try closure(value, encoder)

        return .value(encoder.resolveValue())
    }

    private func encodeNil(at codingPath: [CodingKey]) -> DictionaryComponent {
        switch options.nilEncodingStrategy {
        case .useNil:
            return encodePrimitiveValue(nil, at: codingPath)

        case .useNSNull:
            return encodePrimitiveValue(NSNull(), at: codingPath)
        }
    }

    private func encodeDate(_ date: Date, at codingPath: [CodingKey]) throws -> DictionaryComponent {
        switch options.dateEncodingStrategy {
        case .deferredToDate:
            return try encodeNonPrimitiveValue(date, at: codingPath)

        case .millisecondsSince1970:
            return encodePrimitiveValue(date.timeIntervalSince1970 * 1000.0, at: codingPath)

        case .secondsSince1970:
            return encodePrimitiveValue(date.timeIntervalSince1970, at: codingPath)

        case .iso8601:
            guard #available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) else {
                fatalError("ISO8601DateFormatter is unavailable on this platform.")
            }

            let formattedDate = ISO8601DateFormatter.string(
                from: date,
                timeZone: .iso8601TimeZone,
                formatOptions: .withInternetDateTime
            )

            return encodePrimitiveValue(formattedDate, at: codingPath)

        case let .formatted(dateFormatter):
            return encodePrimitiveValue(dateFormatter.string(from: date), at: codingPath)

        case let .custom(closure):
            return try encodeCustomizedValue(date, at: codingPath, closure: closure)
        }
    }

    private func encodeData(_ data: Data, at codingPath: [CodingKey]) throws -> DictionaryComponent {
        switch options.dataEncodingStrategy {
        case .deferredToData:
            return try encodeNonPrimitiveValue(data, at: codingPath)

        case .base64:
            return encodePrimitiveValue(data.base64EncodedString(), at: codingPath)

        case let .custom(closure):
            return try encodeCustomizedValue(data, at: codingPath, closure: closure)
        }
    }

    private func encodeFloatingPoint<T: FloatingPoint & Encodable>(
        _ value: T,
        at codingPath: [CodingKey]
    ) throws -> DictionaryComponent {
        if value.isFinite {
            return encodePrimitiveValue(value, at: codingPath)
        }

        switch options.nonConformingFloatEncodingStrategy {
        case let .convertToString(positiveInfinity, _, _) where value == T.infinity:
            return encodePrimitiveValue(positiveInfinity, at: codingPath)

        case let .convertToString(_, negativeInfinity, _) where value == -T.infinity:
            return encodePrimitiveValue(negativeInfinity, at: codingPath)

        case let .convertToString(_, _, nan):
            return encodePrimitiveValue(nan, at: codingPath)

        case .throw:
            throw EncodingError.invalidFloatingPointValue(value, at: codingPath)
        }
    }

    private func encodeURL(_ url: URL, at codingPath: [CodingKey]) throws -> DictionaryComponent {
        encodePrimitiveValue(url.absoluteString, at: codingPath)
    }

    // MARK: -

    internal func encodeNilComponent(at codingPath: [CodingKey]) -> DictionaryComponent {
        encodeNil(at: codingPath)
    }

    internal func encodeComponentValue(_ value: Bool, at codingPath: [CodingKey]) -> DictionaryComponent {
        encodePrimitiveValue(value, at: codingPath)
    }

    internal func encodeComponentValue(_ value: Int, at codingPath: [CodingKey]) -> DictionaryComponent {
        encodePrimitiveValue(value, at: codingPath)
    }

    internal func encodeComponentValue(_ value: Int8, at codingPath: [CodingKey]) -> DictionaryComponent {
        encodePrimitiveValue(value, at: codingPath)
    }

    internal func encodeComponentValue(_ value: Int16, at codingPath: [CodingKey]) -> DictionaryComponent {
        encodePrimitiveValue(value, at: codingPath)
    }

    internal func encodeComponentValue(_ value: Int32, at codingPath: [CodingKey]) -> DictionaryComponent {
        encodePrimitiveValue(value, at: codingPath)
    }

    internal func encodeComponentValue(_ value: Int64, at codingPath: [CodingKey]) -> DictionaryComponent {
        encodePrimitiveValue(value, at: codingPath)
    }

    internal func encodeComponentValue(_ value: UInt, at codingPath: [CodingKey]) -> DictionaryComponent {
        encodePrimitiveValue(value, at: codingPath)
    }

    internal func encodeComponentValue(_ value: UInt8, at codingPath: [CodingKey]) -> DictionaryComponent {
        encodePrimitiveValue(value, at: codingPath)
    }

    internal func encodeComponentValue(_ value: UInt16, at codingPath: [CodingKey]) -> DictionaryComponent {
        encodePrimitiveValue(value, at: codingPath)
    }

    internal func encodeComponentValue(_ value: UInt32, at codingPath: [CodingKey]) -> DictionaryComponent {
        encodePrimitiveValue(value, at: codingPath)
    }

    internal func encodeComponentValue(_ value: UInt64, at codingPath: [CodingKey]) -> DictionaryComponent {
        encodePrimitiveValue(value, at: codingPath)
    }

    internal func encodeComponentValue(_ value: Double, at codingPath: [CodingKey]) throws -> DictionaryComponent {
        try encodeFloatingPoint(value, at: codingPath)
    }

    internal func encodeComponentValue(_ value: Float, at codingPath: [CodingKey]) throws -> DictionaryComponent {
        try encodeFloatingPoint(value, at: codingPath)
    }

    internal func encodeComponentValue(_ value: String, at codingPath: [CodingKey]) -> DictionaryComponent {
        encodePrimitiveValue(value, at: codingPath)
    }

    internal func encodeComponentValue<T: Encodable>(
        _ value: T,
        at codingPath: [CodingKey]
    ) throws -> DictionaryComponent {
        switch value {
        case let date as Date:
            return try encodeDate(date, at: codingPath)

        case let data as Data:
            return try encodeData(data, at: codingPath)

        case let url as URL:
            return try encodeURL(url, at: codingPath)

        default:
            return try encodeNonPrimitiveValue(value, at: codingPath)
        }
    }
}

private extension TimeZone {

    // MARK: - Type Properties

    static let iso8601TimeZone = TimeZone(secondsFromGMT: 0)!
}

private extension EncodingError {

    // MARK: - Type Methods

    static func invalidFloatingPointValue<T: FloatingPoint>(_ value: T, at codingPath: [CodingKey]) -> EncodingError {
        let valueDescription: String

        switch value {
        case T.infinity:
            valueDescription = "\(T.self).infinity"

        case -T.infinity:
            valueDescription = "-\(T.self).infinity"

        default:
            valueDescription = "\(T.self).nan"
        }

        let debugDescription = """
            Unable to encode \(valueDescription) directly in Dictionary.
            Use DictionaryNonConformingFloatEncodingStrategy.convertToString to specify how the value should be encoded.
            """

        return .invalidValue(value, EncodingError.Context(codingPath: codingPath, debugDescription: debugDescription))
    }
}
