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
        nonConformingFloatDecodingStrategy: DictionaryNonConformingFloatDecodingStrategy = .throw,
        keyDecodingStrategy: DictionaryKeyDecodingStrategy = .useDefaultKeys,
        userInfo: [CodingUserInfoKey: Sendable] = [:]
    ) {
        let options = DictionaryDecodingOptions(
            dateDecodingStrategy: dateDecodingStrategy,
            dataDecodingStrategy: dataDecodingStrategy,
            nonConformingFloatDecodingStrategy: nonConformingFloatDecodingStrategy,
            keyDecodingStrategy: keyDecodingStrategy
        )

        self.optionsMutex = Mutex(value: options)
        self.userInfoMutex = Mutex(value: userInfo)
    }

    // MARK: - Instance Methods

    public func decode<T: Decodable>(_ type: T.Type, from dictionary: [String: Any]) throws -> T {
        let options = optionsMutex.withLock { $0 }

        let decoder = DictionarySingleValueDecodingContainer(
            component: dictionary,
            options: options,
            userInfo: userInfo,
            codingPath: []
        )

        return try T(from: decoder)
    }

    public func decode<T: Decodable>(from dictionary: [String: Any]) throws -> T {
        try decode(T.self, from: dictionary)
    }
}
