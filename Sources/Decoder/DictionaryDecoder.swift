import Foundation

public final class DictionaryDecoder: Sendable {

    // MARK: - Instance Properties

    private let optionsMutex: Mutex<DictionaryDecodingOptions>
    private let userInfoMutex: Mutex<[CodingUserInfoKey: Sendable]>

    public var dateDecodingStrategy: DictionaryDateDecodingStrategy {
        get { optionsMutex.withLock { $0.dateDecodingStrategy } }
        set { optionsMutex.withLock { $0.dateDecodingStrategy = newValue } }
    }

    public var dataDecodingStrategy: DictionaryDataDecodingStrategy {
        get { optionsMutex.withLock { $0.dataDecodingStrategy } }
        set { optionsMutex.withLock { $0.dataDecodingStrategy = newValue } }
    }

    public var decimalDecodingStrategy: DictionaryDecimalDecodingStrategy {
        get { optionsMutex.withLock { $0.decimalDecodingStrategy } }
        set { optionsMutex.withLock { $0.decimalDecodingStrategy = newValue } }
    }

    public var nonConformingFloatDecodingStrategy: DictionaryNonConformingFloatDecodingStrategy {
        get { optionsMutex.withLock { $0.nonConformingFloatDecodingStrategy } }
        set { optionsMutex.withLock { $0.nonConformingFloatDecodingStrategy = newValue } }
    }

    public var keyDecodingStrategy: DictionaryKeyDecodingStrategy {
        get { optionsMutex.withLock { $0.keyDecodingStrategy } }
        set { optionsMutex.withLock { $0.keyDecodingStrategy = newValue } }
    }

    public var userInfo: [CodingUserInfoKey: Sendable] {
        get { userInfoMutex.withLock { $0 } }
        set { userInfoMutex.withLock { $0 = newValue } }
    }

    // MARK: - Initializers

    public init(
        dateDecodingStrategy: DictionaryDateDecodingStrategy = .deferredToDate,
        dataDecodingStrategy: DictionaryDataDecodingStrategy = .base64,
        decimalDecodingStrategy: DictionaryDecimalDecodingStrategy = .deferredToDecimal,
        nonConformingFloatDecodingStrategy: DictionaryNonConformingFloatDecodingStrategy = .throw,
        keyDecodingStrategy: DictionaryKeyDecodingStrategy = .useDefaultKeys,
        userInfo: [CodingUserInfoKey: Sendable] = [:]
    ) {
        let options = DictionaryDecodingOptions(
            dateDecodingStrategy: dateDecodingStrategy,
            dataDecodingStrategy: dataDecodingStrategy,
            decimalDecodingStrategy: decimalDecodingStrategy,
            nonConformingFloatDecodingStrategy: nonConformingFloatDecodingStrategy,
            keyDecodingStrategy: keyDecodingStrategy
        )

        self.optionsMutex = Mutex(value: options)
        self.userInfoMutex = Mutex(value: userInfo)
    }

    // MARK: - Instance Methods

    private func rootDecoder(for dictionary: [String: Any]) -> DictionarySingleValueDecodingContainer {
        let options = optionsMutex.withLock { $0 }

        return DictionarySingleValueDecodingContainer(
            component: dictionary,
            options: options,
            userInfo: userInfo,
            codingPath: []
        )
    }

    public func decode<T: Decodable>(
        _ type: T.Type = T.self,
        from dictionary: [String: Any]
    ) throws -> T {
        try T(from: rootDecoder(for: dictionary))
    }

    public func decode<T: Decodable>(from dictionary: [String: Any]) throws -> T {
        try decode(T.self, from: dictionary)
    }

    public func decode<T: DecodableWithConfiguration>(
        _ type: T.Type = T.self,
        from dictionary: [String: Any],
        configuration: T.DecodingConfiguration
    ) throws -> T {
        try T(from: rootDecoder(for: dictionary), configuration: configuration)
    }
}
