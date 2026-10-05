import Foundation

internal protocol DictionaryComponentDecoder {

    var options: DictionaryDecodingOptions { get }
    var userInfo: [CodingUserInfoKey: Any] { get }
}

extension DictionaryComponentDecoder {

    // MARK: - Instance Methods

    private func decodePrimitiveValue<T: Decodable>(
        of type: T.Type = T.self,
        from component: Any?,
        at codingPath: [CodingKey]
    ) throws -> T {
        guard let value = component as? T else {
            return try decodeConvertedNumber(from: component, at: codingPath)
        }

        return value
    }

    // Numbers of other types are converted the same way as `NSNumber`,
    // so a dictionary decodes equally whether it holds Swift numbers or `NSNumber` instances.
    // Unlike `NSNumber`, booleans are not converted to or from numbers here, as in `JSONDecoder`.
    @inline(never)
    private func decodeConvertedNumber<T: Decodable>(
        from component: Any?,
        at codingPath: [CodingKey]
    ) throws -> T {
        let number = component as? NSNumber

        guard let number, !isBoolean(number), !(T.self is Bool.Type), let value = number as? T else {
            throw DecodingError.invalidComponent(component, of: T.self, at: codingPath)
        }

        return value
    }

    // Booleans are bridged to `NSNumber` too, so they are told apart by their Core Foundation type.
    private func isBoolean(_ number: NSNumber) -> Bool {
        CFGetTypeID(number) == CFBooleanGetTypeID()
    }

    private func decodeDecimal(from component: Any?, at codingPath: [CodingKey]) throws -> Decimal {
        let strategy = options.decimalDecodingStrategy

        if strategy.contains(.number) {
            if let decimal = component as? Decimal {
                return decimal
            }

            if let number = component as? NSNumber, !isBoolean(number) {
                return number.decimalValue
            }
        }

        guard strategy.contains(.deferredToDecimal) else {
            throw DecodingError.invalidComponent(component, of: Decimal.self, at: codingPath)
        }

        return try decodeNonPrimitiveValue(from: component, at: codingPath)
    }

#if compiler(>=6.0)
    // `NSNumber` does not bridge 128-bit integers, so other integers are converted exactly.
    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    private func decodeWideInteger<T: FixedWidthInteger & Decodable>(
        of type: T.Type = T.self,
        from component: Any?,
        at codingPath: [CodingKey]
    ) throws -> T {
        if let value = component as? T {
            return value
        }

        let value: T?

        switch component {
        case let integer as any BinaryInteger:
            value = T(exactly: integer)

        case let number as NSNumber where !isBoolean(number):
            value = (number as? Int64).flatMap(T.init(exactly:)) ?? (number as? UInt64).flatMap(T.init(exactly:))

        default:
            value = nil
        }

        guard let value else {
            throw DecodingError.invalidComponent(component, of: T.self, at: codingPath)
        }

        return value
    }
#endif

    private func decodeNonPrimitiveValue<T: Decodable>(
        of type: T.Type = T.self,
        from component: Any?,
        at codingPath: [CodingKey]
    ) throws -> T {
        let decoder = DictionarySingleValueDecodingContainer(
            component: component,
            options: options,
            userInfo: userInfo,
            codingPath: codingPath
        )

        return try T(from: decoder)
    }

    private func decodeCustomizedValue<T: Decodable>(
        of type: T.Type = T.self,
        from component: Any?,
        at codingPath: [CodingKey],
        closure: (_ decoder: Decoder) throws -> T
    ) throws -> T {
        let decoder = DictionarySingleValueDecodingContainer(
            component: component,
            options: options,
            userInfo: userInfo,
            codingPath: codingPath
        )

        return try closure(decoder)
    }

    private func decodeFloatingPointValue<T: FloatingPoint & Decodable>(
        from component: Any?,
        at codingPath: [CodingKey]
    ) throws -> T {
        switch component {
        case let string as String:
            switch options.nonConformingFloatDecodingStrategy {
            case let .convertFromString(positiveInfinity, _, _) where string == positiveInfinity:
                return T.infinity

            case let .convertFromString(_, negativeInfinity, _) where string == negativeInfinity:
                return -T.infinity

            case let .convertFromString(_, _, nan) where string == nan:
                return T.nan

            case .convertFromString, .throw:
                break
            }

        case let number as T where number.isFinite:
            return number

        case let number as T:
            let errorContext = DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Parsed dictionary number \(number) does not fit in \(T.self)."
            )

            throw DecodingError.dataCorrupted(errorContext)

        default:
            break
        }

        // Numbers of other types are converted, which strings do not survive.
        let number: T = try decodeConvertedNumber(from: component, at: codingPath)

        guard number.isFinite else {
            let errorContext = DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Parsed dictionary number \(number) does not fit in \(T.self)."
            )

            throw DecodingError.dataCorrupted(errorContext)
        }

        return number
    }

    private func decodeDate(from component: Any?, at codingPath: [CodingKey]) throws -> Date {
        switch options.dateDecodingStrategy {
        case .deferredToDate:
            return try decodeNonPrimitiveValue(from: component, at: codingPath)

        case .secondsSince1970:
            return Date(timeIntervalSince1970: try decodePrimitiveValue(from: component, at: codingPath))

        case .millisecondsSince1970:
            return Date(timeIntervalSince1970: try decodePrimitiveValue(from: component, at: codingPath) / 1000.0)

        case let .iso8601(style):
            let formattedDate = try decodePrimitiveValue(of: String.self, from: component, at: codingPath)

            guard let date = style.date(from: formattedDate) else {
                let errorContext = DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Expected date string to be ISO8601-formatted."
                )

                throw DecodingError.dataCorrupted(errorContext)
            }

            return date

        case .formatted(let dateFormatter):
            let formattedDate = try decodePrimitiveValue(of: String.self, from: component, at: codingPath)

            guard let date = dateFormatter.date(from: formattedDate) else {
                let errorContext = DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Date string does not match format expected by formatter."
                )

                throw DecodingError.dataCorrupted(errorContext)
            }

            return date

        case .custom(let closure):
            return try decodeCustomizedValue(from: component, at: codingPath, closure: closure)
        }
    }

    private func decodeData(from component: Any?, at codingPath: [CodingKey]) throws -> Data {
        switch options.dataDecodingStrategy {
        case .deferredToData:
            return try decodeNonPrimitiveValue(from: component, at: codingPath)

        case .base64:
            let base64EncodedString = try decodePrimitiveValue(of: String.self, from: component, at: codingPath)

            guard let data = Data(base64Encoded: base64EncodedString) else {
                let errorContext = DecodingError.Context(
                    codingPath: codingPath,
                    debugDescription: "Encountered Data is not valid Base64."
                )

                throw DecodingError.dataCorrupted(errorContext)
            }

            return data

        case .blob:
            return try decodePrimitiveValue(from: component, at: codingPath)

        case .custom(let closure):
            return try decodeCustomizedValue(from: component, at: codingPath, closure: closure)
        }
    }

    private func decodeURL(from component: Any?, at codingPath: [CodingKey]) throws -> URL {
        if let url = component as? URL {
            return url
        }

        guard let url = URL(string: try decodePrimitiveValue(from: component, at: codingPath)) else {
            let errorContext = DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "String is not valid URL."
            )

            throw DecodingError.dataCorrupted(errorContext)
        }

        return url
    }

    // MARK: -

    internal func decodeNilComponent(from component: Any?) -> Bool {
        component.isNil || component is NSNull
    }

    internal func decodeComponentValue(from component: Any?, at codingPath: [CodingKey]) throws -> Bool {
        try decodePrimitiveValue(from: component, at: codingPath)
    }

    internal func decodeComponentValue(from component: Any?, at codingPath: [CodingKey]) throws -> Int {
        try decodePrimitiveValue(from: component, at: codingPath)
    }

    internal func decodeComponentValue(from component: Any?, at codingPath: [CodingKey]) throws -> Int8 {
        try decodePrimitiveValue(from: component, at: codingPath)
    }

    internal func decodeComponentValue(from component: Any?, at codingPath: [CodingKey]) throws -> Int16 {
        try decodePrimitiveValue(from: component, at: codingPath)
    }

    internal func decodeComponentValue(from component: Any?, at codingPath: [CodingKey]) throws -> Int32 {
        try decodePrimitiveValue(from: component, at: codingPath)
    }

    internal func decodeComponentValue(from component: Any?, at codingPath: [CodingKey]) throws -> Int64 {
        try decodePrimitiveValue(from: component, at: codingPath)
    }

#if compiler(>=6.0)
    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    internal func decodeComponentValue(from component: Any?, at codingPath: [CodingKey]) throws -> Int128 {
        try decodeWideInteger(from: component, at: codingPath)
    }
#endif

    internal func decodeComponentValue(from component: Any?, at codingPath: [CodingKey]) throws -> UInt {
        try decodePrimitiveValue(from: component, at: codingPath)
    }

    internal func decodeComponentValue(from component: Any?, at codingPath: [CodingKey]) throws -> UInt8 {
        try decodePrimitiveValue(from: component, at: codingPath)
    }

    internal func decodeComponentValue(from component: Any?, at codingPath: [CodingKey]) throws -> UInt16 {
        try decodePrimitiveValue(from: component, at: codingPath)
    }

    internal func decodeComponentValue(from component: Any?, at codingPath: [CodingKey]) throws -> UInt32 {
        try decodePrimitiveValue(from: component, at: codingPath)
    }

    internal func decodeComponentValue(from component: Any?, at codingPath: [CodingKey]) throws -> UInt64 {
        try decodePrimitiveValue(from: component, at: codingPath)
    }

#if compiler(>=6.0)
    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    internal func decodeComponentValue(from component: Any?, at codingPath: [CodingKey]) throws -> UInt128 {
        try decodeWideInteger(from: component, at: codingPath)
    }
#endif

    internal func decodeComponentValue(from component: Any?, at codingPath: [CodingKey]) throws -> Double {
        try decodeFloatingPointValue(from: component, at: codingPath)
    }

    internal func decodeComponentValue(from component: Any?, at codingPath: [CodingKey]) throws -> Float {
        try decodeFloatingPointValue(from: component, at: codingPath)
    }

    internal func decodeComponentValue(from component: Any?, at codingPath: [CodingKey]) throws -> String {
        try decodePrimitiveValue(from: component, at: codingPath)
    }

    internal func decodeComponentValue<T: Decodable>(
        of type: T.Type,
        from component: Any?,
        at codingPath: [CodingKey]
    ) throws -> T {
        // The type is compared rather than cast, as a cast costs much more and is made for every value.
        switch ObjectIdentifier(T.self) {
        case ObjectIdentifier(Date.self):
            return try decodeDate(from: component, at: codingPath) as! T

        case ObjectIdentifier(Data.self):
            return try decodeData(from: component, at: codingPath) as! T

        case ObjectIdentifier(URL.self):
            return try decodeURL(from: component, at: codingPath) as! T

        case ObjectIdentifier(Decimal.self):
            return try decodeDecimal(from: component, at: codingPath) as! T

        default:
            return try decodeNonPrimitiveValue(from: component, at: codingPath)
        }
    }
}

extension DecodingError {

    // MARK: - Type Methods

    fileprivate static func invalidComponent(
        _ component: Any?,
        of expectedType: Any.Type,
        at codingPath: [CodingKey]
    ) -> DecodingError {
        let componentDescription = component.map { "\(type(of: $0))" } ?? "nil"

        let context = Context(
            codingPath: codingPath,
            debugDescription: "Expected to decode \(expectedType) but found \(componentDescription) instead."
        )

        return .typeMismatch(expectedType, context)
    }
}
