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

        case .blob:
            return encodePrimitiveValue(data, at: codingPath)

        case let .custom(closure):
            return try encodeCustomizedValue(data, at: codingPath, closure: closure)
        }
    }

    private func encodeDecimal(_ decimal: Decimal, at codingPath: [CodingKey]) throws -> DictionaryComponent {
        switch options.decimalEncodingStrategy {
        case .deferredToDecimal:
            return try encodeNonPrimitiveValue(decimal, at: codingPath)

        case .number:
            return encodePrimitiveValue(decimal, at: codingPath)
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

#if compiler(>=6.0)
    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    internal func encodeComponentValue(_ value: Int128, at codingPath: [CodingKey]) -> DictionaryComponent {
        encodePrimitiveValue(value, at: codingPath)
    }
#endif

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

#if compiler(>=6.0)
    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    internal func encodeComponentValue(_ value: UInt128, at codingPath: [CodingKey]) -> DictionaryComponent {
        encodePrimitiveValue(value, at: codingPath)
    }
#endif

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
        // The type is compared rather than the value cast, as a cast costs much more and is made for every value.
        switch ObjectIdentifier(T.self) {
        case ObjectIdentifier(Date.self):
            return try encodeDate(value as! Date, at: codingPath)

        case ObjectIdentifier(Data.self):
            return try encodeData(value as! Data, at: codingPath)

        case ObjectIdentifier(URL.self):
            return try encodeURL(value as! URL, at: codingPath)

        case ObjectIdentifier(Decimal.self):
            return try encodeDecimal(value as! Decimal, at: codingPath)

        default:
            return try encodeNonPrimitiveValue(value, at: codingPath)
        }
    }
}

extension TimeZone {

    // MARK: - Type Properties

    fileprivate static let iso8601TimeZone = TimeZone(secondsFromGMT: 0)!
}

extension EncodingError {

    // MARK: - Type Methods

    fileprivate static func invalidFloatingPointValue<T: FloatingPoint>(
        _ value: T,
        at codingPath: [CodingKey]
    ) -> EncodingError {
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

        return .invalidValue(value, Context(codingPath: codingPath, debugDescription: debugDescription))
    }
}
