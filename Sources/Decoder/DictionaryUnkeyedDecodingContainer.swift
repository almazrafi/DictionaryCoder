import Foundation

/// Components of an unkeyed container. Arrays of `Any`, as the encoder writes them, and Foundation arrays,
/// such as the ones from `JSONSerialization` or property lists, are read in place,
/// as converting an array wraps or bridges every element up front.
internal enum DictionaryUnkeyedComponents {

    // MARK: - Enumeration Cases

    case native([Any])
    case foundation(NSArray)

    // Other arrays, such as `[Int?]`, are converted, which unwraps their optional elements.
    case optionals([Any?])

    // MARK: - Type Methods

    // Casting to `Any?` unwraps a wrapped optional, though a direct cast is reported to always succeed.
    private static func cast<T>(_ component: Any, to type: T.Type) -> T {
        component as! T
    }

    // MARK: - Instance Properties

    internal var count: Int {
        switch self {
        case let .native(components):
            components.count

        case let .foundation(components):
            components.count

        case let .optionals(components):
            components.count
        }
    }

    // MARK: - Initializers

    internal init?(_ component: Any?) {
        guard let component else {
            return nil
        }

        let componentType = type(of: component)

        if componentType == [Any].self, let components = component as? [Any] {
            self = .native(components)
        } else if componentType is NSArray.Type, let components = component as? NSArray {
            self = .foundation(components)
        } else if let components = component as? [Any?] {
            self = .optionals(components)
        } else {
            return nil
        }
    }

    // MARK: - Subscripts

    @inline(__always)
    internal subscript(index: Int) -> Any? {
        switch self {
        case let .native(components):
            let component = components[index]

            // Optional elements, such as `nil` that the encoder writes, are kept in an array of `Any` wrapped,
            // so they are unwrapped as converting the array to `[Any?]` would.
            return type(of: component) == Optional<Any>.self ? Self.cast(component, to: Any?.self) : component

        case let .foundation(components):
            return components[index]

        case let .optionals(components):
            return components[index]
        }
    }
}

internal final class DictionaryUnkeyedDecodingContainer:
    UnkeyedDecodingContainer,
    DictionaryComponentDecoder {

    // MARK: - Instance Properties

    internal let components: DictionaryUnkeyedComponents
    internal let options: DictionaryDecodingOptions
    internal let userInfo: [CodingUserInfoKey: Any]
    internal let codingPath: [CodingKey]

    internal private(set) var currentIndex = 0

    @inline(__always)
    internal var currentCodingPath: [CodingKey] {
        codingPath.appending(AnyCodingKey(currentIndex))
    }

    internal var count: Int? {
        components.count
    }

    internal var isAtEnd: Bool {
        currentIndex == count
    }

    // MARK: - Initializers

    internal init(
        components: DictionaryUnkeyedComponents,
        options: DictionaryDecodingOptions,
        userInfo: [CodingUserInfoKey: Any],
        codingPath: [CodingKey]
    ) {
        self.components = components
        self.options = options
        self.userInfo = userInfo
        self.codingPath = codingPath
    }

    // MARK: - Instance Methods

    @inline(__always)
    private func peekNextComponent() throws -> Any? {
        guard currentIndex < components.count else {
            let errorContext = DecodingError.Context(
                codingPath: currentCodingPath,
                debugDescription: "Unkeyed container is at end."
            )

            throw DecodingError.valueNotFound(Any.self, errorContext)
        }

        return components[currentIndex]
    }

    @inline(__always)
    private func decodeNextComponent<T>(_ decodeComponent: (_ component: consuming Any?) throws -> T) throws -> T {
        let value = try decodeComponent(try peekNextComponent())

        currentIndex += 1

        return value
    }

    @inline(__always)
    private func superDecoder(for component: consuming Any?, at codingPath: consuming [CodingKey]) -> Decoder {
        DictionarySingleValueDecodingContainer(
            component: component,
            options: options,
            userInfo: userInfo,
            codingPath: codingPath
        )
    }

    // MARK: - UnkeyedDecodingContainer

    internal func decodeNil() throws -> Bool {
        guard decodeNilComponent(from: try peekNextComponent()) else {
            return false
        }

        currentIndex += 1

        return true
    }

    internal func decode(_ type: Bool.Type) throws -> Bool {
        try decodeNextComponent { try decodeComponentValue(from: $0, at: currentCodingPath) }
    }

    internal func decode(_ type: Int.Type) throws -> Int {
        try decodeNextComponent { try decodeComponentValue(from: $0, at: currentCodingPath) }
    }

    internal func decode(_ type: Int8.Type) throws -> Int8 {
        try decodeNextComponent { try decodeComponentValue(from: $0, at: currentCodingPath) }
    }

    internal func decode(_ type: Int16.Type) throws -> Int16 {
        try decodeNextComponent { try decodeComponentValue(from: $0, at: currentCodingPath) }
    }

    internal func decode(_ type: Int32.Type) throws -> Int32 {
        try decodeNextComponent { try decodeComponentValue(from: $0, at: currentCodingPath) }
    }

    internal func decode(_ type: Int64.Type) throws -> Int64 {
        try decodeNextComponent { try decodeComponentValue(from: $0, at: currentCodingPath) }
    }

#if compiler(>=6.0)
    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    internal func decode(_ type: Int128.Type) throws -> Int128 {
        try decodeNextComponent { try decodeComponentValue(from: $0, at: currentCodingPath) }
    }
#endif

    internal func decode(_ type: UInt.Type) throws -> UInt {
        try decodeNextComponent { try decodeComponentValue(from: $0, at: currentCodingPath) }
    }

    internal func decode(_ type: UInt8.Type) throws -> UInt8 {
        try decodeNextComponent { try decodeComponentValue(from: $0, at: currentCodingPath) }
    }

    internal func decode(_ type: UInt16.Type) throws -> UInt16 {
        try decodeNextComponent { try decodeComponentValue(from: $0, at: currentCodingPath) }
    }

    internal func decode(_ type: UInt32.Type) throws -> UInt32 {
        try decodeNextComponent { try decodeComponentValue(from: $0, at: currentCodingPath) }
    }

    internal func decode(_ type: UInt64.Type) throws -> UInt64 {
        try decodeNextComponent { try decodeComponentValue(from: $0, at: currentCodingPath) }
    }

#if compiler(>=6.0)
    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    internal func decode(_ type: UInt128.Type) throws -> UInt128 {
        try decodeNextComponent { try decodeComponentValue(from: $0, at: currentCodingPath) }
    }
#endif

    internal func decode(_ type: Double.Type) throws -> Double {
        try decodeNextComponent { try decodeComponentValue(from: $0, at: currentCodingPath) }
    }

    internal func decode(_ type: Float.Type) throws -> Float {
        try decodeNextComponent { try decodeComponentValue(from: $0, at: currentCodingPath) }
    }

    internal func decode(_ type: String.Type) throws -> String {
        try decodeNextComponent { try decodeComponentValue(from: $0, at: currentCodingPath) }
    }

    internal func decode<T: Decodable>(_ type: T.Type) throws -> T {
        try decodeNextComponent { try decodeComponentValue(of: type, from: $0, at: currentCodingPath) }
    }

    internal func nestedContainer<NestedKey: CodingKey>(
        keyedBy keyType: NestedKey.Type
    ) throws -> KeyedDecodingContainer<NestedKey> {
        try decodeNextComponent { try superDecoder(for: $0, at: currentCodingPath).container(keyedBy: keyType) }
    }

    internal func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        try decodeNextComponent { try superDecoder(for: $0, at: currentCodingPath).unkeyedContainer() }
    }

    internal func superDecoder() throws -> Decoder {
        try decodeNextComponent { superDecoder(for: $0, at: currentCodingPath) }
    }
}
