internal class DictionaryKeyedDecodingContainer<Key: CodingKey>:
    KeyedDecodingContainerProtocol,
    DictionaryComponentDecoder {

    // MARK: - Instance Properties

    internal let components: [String: Any]
    internal let options: DictionaryDecodingOptions
    internal let userInfo: [CodingUserInfoKey: Any]
    internal let codingPath: [CodingKey]

    internal var allKeys: [Key] {
        components.keys.compactMap { Key(stringValue: $0) }
    }

    // MARK: - Initializers

    internal init(
        components: [String: Any],
        options: DictionaryDecodingOptions,
        userInfo: [CodingUserInfoKey: Any],
        codingPath: [CodingKey]
    ) {
        switch options.keyDecodingStrategy {
        case .useDefaultKeys:
            self.components = components

        case let .custom(closure):
            let componentKeysAndValues = components
                .sorted { $0.key < $1.key }
                .map { key, value in (closure(codingPath.appending(AnyCodingKey(key))).stringValue, value) }

            self.components = Dictionary(componentKeysAndValues) { first, _ in first }
        }

        self.options = options
        self.userInfo = userInfo
        self.codingPath = codingPath
    }

    // MARK: - Instance Methods

    @inline(__always)
    private func component<T>(of type: T.Type = T.self, forKey key: Key) throws -> T {
        let anyComponent = components[key.stringValue]

        guard let component = anyComponent as? T else {
            throw DecodingError.invalidComponent(
                anyComponent,
                forKey: key,
                at: codingPath.appending(key),
                expectation: type
            )
        }

        return component
    }

    @inline(__always)
    private func superDecoder(forAnyKey key: CodingKey) throws -> Decoder {
        DictionarySingleValueDecodingContainer(
            component: components[key.stringValue],
            options: options,
            userInfo: userInfo,
            codingPath: codingPath.appending(key)
        )
    }

    // MARK: - KeyedDecodingContainerProtocol

    internal func contains(_ key: Key) -> Bool {
        components.contains { $0.key == key.stringValue }
    }

    internal func decodeNil(forKey key: Key) throws -> Bool {
        decodeNilComponent(from: try component(forKey: key))
    }

    internal func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        try decodeComponentValue(from: try component(forKey: key), at: codingPath.appending(key))
    }

    internal func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        try decodeComponentValue(from: try component(forKey: key), at: codingPath.appending(key))
    }

    internal func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        try decodeComponentValue(from: try component(forKey: key), at: codingPath.appending(key))
    }

    internal func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        try decodeComponentValue(from: try component(forKey: key), at: codingPath.appending(key))
    }

    internal func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        try decodeComponentValue(from: try component(forKey: key), at: codingPath.appending(key))
    }

    internal func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        try decodeComponentValue(from: try component(forKey: key), at: codingPath.appending(key))
    }

#if compiler(>=6.0)
    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    internal func decode(_ type: Int128.Type, forKey key: Key) throws -> Int128 {
        try decodeComponentValue(from: try component(forKey: key), at: codingPath.appending(key))
    }
#endif

    internal func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        try decodeComponentValue(from: try component(forKey: key), at: codingPath.appending(key))
    }

    internal func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        try decodeComponentValue(from: try component(forKey: key), at: codingPath.appending(key))
    }

    internal func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        try decodeComponentValue(from: try component(forKey: key), at: codingPath.appending(key))
    }

    internal func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        try decodeComponentValue(from: try component(forKey: key), at: codingPath.appending(key))
    }

    internal func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        try decodeComponentValue(from: try component(forKey: key), at: codingPath.appending(key))
    }

#if compiler(>=6.0)
    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    internal func decode(_ type: UInt128.Type, forKey key: Key) throws -> UInt128 {
        try decodeComponentValue(from: try component(forKey: key), at: codingPath.appending(key))
    }
#endif

    internal func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        try decodeComponentValue(from: try component(forKey: key), at: codingPath.appending(key))
    }

    internal func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        try decodeComponentValue(from: try component(forKey: key), at: codingPath.appending(key))
    }

    internal func decode(_ type: String.Type, forKey key: Key) throws -> String {
        try decodeComponentValue(from: try component(forKey: key), at: codingPath.appending(key))
    }

    internal func decode<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T {
        try decodeComponentValue(of: type, from: try component(forKey: key), at: codingPath.appending(key))
    }

    internal func nestedContainer<NestedKey: CodingKey>(
        keyedBy keyType: NestedKey.Type,
        forKey key: Key
    ) throws -> KeyedDecodingContainer<NestedKey> {
        try superDecoder(forAnyKey: key).container(keyedBy: keyType)
    }

    internal func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        try superDecoder(forAnyKey: key).unkeyedContainer()
    }

    internal func superDecoder(forKey key: Key) throws -> Decoder {
        try superDecoder(forAnyKey: key)
    }

    internal func superDecoder() throws -> Decoder {
        try superDecoder(forAnyKey: AnyCodingKey.super)
    }
}

extension DecodingError {

    // MARK: - Type Methods

    fileprivate static func invalidComponent<Key: CodingKey>(
        _ component: Any?,
        forKey key: Key,
        at codingPath: [CodingKey],
        expectation: Any.Type
    ) -> Self {
        switch component {
        case let component?:
            let context = Context(
                codingPath: codingPath,
                debugDescription: "Expected to decode \(expectation) but found \(type(of: component)) instead."
            )

            return .typeMismatch(expectation, context)

        case nil:
            let context = Context(
                codingPath: codingPath,
                debugDescription: "No value associated with key \(key.stringValue)."
            )

            return .keyNotFound(key, context)
        }
    }
}
