internal final class DictionaryUnkeyedEncodingContainer:
    UnkeyedEncodingContainer,
    DictionaryComponentContainer,
    DictionaryComponentEncoder {

    // MARK: - Instance Properties

    private var components: [DictionaryComponent] = []

    internal let options: DictionaryEncodingOptions
    internal let userInfo: [CodingUserInfoKey: Any]
    internal let codingPath: [CodingKey]

    @inline(__always)
    internal var currentCodingPath: [CodingKey] {
        codingPath.appending(AnyCodingKey(count))
    }

    internal var count: Int {
        components.count
    }

    // MARK: - Initializers

    internal init(
        options: DictionaryEncodingOptions,
        userInfo: [CodingUserInfoKey: Any],
        codingPath: [CodingKey]
    ) {
        self.options = options
        self.userInfo = userInfo
        self.codingPath = codingPath
    }

    // MARK: - Instance Methods

    @inline(__always)
    private func collectComponent(_ component: consuming DictionaryComponent) {
        // Most unkeyed containers of compact encodings hold a couple of elements, so room for two is reserved
        // up front. It saves a reallocation for every container of two and more elements, which grow as usual,
        // and costs memory only for containers of one element.
        if components.isEmpty {
            components.reserveCapacity(2)
        }

        components.append(component)
    }

    // MARK: - UnkeyedEncodingContainer

    internal func encodeNil() throws {
        collectComponent(encodeNilComponent(at: currentCodingPath))
    }

    internal func encode(_ value: Bool) throws {
        collectComponent(encodeComponentValue(value, at: currentCodingPath))
    }

    internal func encode(_ value: Int) throws {
        collectComponent(encodeComponentValue(value, at: currentCodingPath))
    }

    internal func encode(_ value: Int8) throws {
        collectComponent(encodeComponentValue(value, at: currentCodingPath))
    }

    internal func encode(_ value: Int16) throws {
        collectComponent(encodeComponentValue(value, at: currentCodingPath))
    }

    internal func encode(_ value: Int32) throws {
        collectComponent(encodeComponentValue(value, at: currentCodingPath))
    }

    internal func encode(_ value: Int64) throws {
        collectComponent(encodeComponentValue(value, at: currentCodingPath))
    }

#if compiler(>=6.0)
    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    internal func encode(_ value: Int128) throws {
        collectComponent(encodeComponentValue(value, at: currentCodingPath))
    }
#endif

    internal func encode(_ value: UInt) throws {
        collectComponent(encodeComponentValue(value, at: currentCodingPath))
    }

    internal func encode(_ value: UInt8) throws {
        collectComponent(encodeComponentValue(value, at: currentCodingPath))
    }

    internal func encode(_ value: UInt16) throws {
        collectComponent(encodeComponentValue(value, at: currentCodingPath))
    }

    internal func encode(_ value: UInt32) throws {
        collectComponent(encodeComponentValue(value, at: currentCodingPath))
    }

    internal func encode(_ value: UInt64) throws {
        collectComponent(encodeComponentValue(value, at: currentCodingPath))
    }

#if compiler(>=6.0)
    @available(macOS 15.0, iOS 18.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *)
    internal func encode(_ value: UInt128) throws {
        collectComponent(encodeComponentValue(value, at: currentCodingPath))
    }
#endif

    internal func encode(_ value: Double) throws {
        collectComponent(try encodeComponentValue(value, at: currentCodingPath))
    }

    internal func encode(_ value: Float) throws {
        collectComponent(try encodeComponentValue(value, at: currentCodingPath))
    }

    internal func encode(_ value: String) throws {
        collectComponent(encodeComponentValue(value, at: currentCodingPath))
    }

    internal func encode<T: Encodable>(_ value: T) throws {
        collectComponent(try encodeComponentValue(value, at: currentCodingPath))
    }

    internal func nestedContainer<NestedKey: CodingKey>(
        keyedBy keyType: NestedKey.Type
    ) -> KeyedEncodingContainer<NestedKey> {
        let container = DictionaryAnyKeyedEncodingContainer(
            options: options,
            userInfo: userInfo,
            codingPath: currentCodingPath
        )

        collectComponent(.container(container))

        return KeyedEncodingContainer(
            DictionaryKeyedEncodingContainer<NestedKey>(container: container)
        )
    }

    internal func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        let container = DictionaryUnkeyedEncodingContainer(
            options: options,
            userInfo: userInfo,
            codingPath: currentCodingPath
        )

        collectComponent(.container(container))

        return container
    }

    internal func superEncoder() -> Encoder {
        let encoder = DictionarySingleValueEncodingContainer(
            options: options,
            userInfo: userInfo,
            codingPath: currentCodingPath
        )

        collectComponent(.container(encoder))

        return encoder
    }

    // MARK: - DictionaryComponentContainer

    internal func resolveValue() -> Any? {
        components.map { component in
            let value = component.resolveValue()

            return value ?? value as Any
        }
    }
}
