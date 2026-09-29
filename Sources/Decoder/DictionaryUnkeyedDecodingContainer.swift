internal final class DictionaryUnkeyedDecodingContainer:
    UnkeyedDecodingContainer,
    DictionaryComponentDecoder {

    // MARK: - Instance Properties

    internal let components: [Any?]
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
        components: [Any?],
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
