import Foundation

public final class DictionaryEncoder: Sendable {

    // MARK: - Instance Properties

    private let optionsMutex: Mutex<DictionaryEncodingOptions>
    private let userInfoMutex: Mutex<[CodingUserInfoKey: Sendable]>

    public var dateEncodingStrategy: DictionaryDateEncodingStrategy {
        get { optionsMutex.withLock { $0.dateEncodingStrategy } }
        set { optionsMutex.withLock { $0.dateEncodingStrategy = newValue } }
    }

    public var dataEncodingStrategy: DictionaryDataEncodingStrategy {
        get { optionsMutex.withLock { $0.dataEncodingStrategy } }
        set { optionsMutex.withLock { $0.dataEncodingStrategy = newValue } }
    }

    public var nonConformingFloatEncodingStrategy: DictionaryNonConformingFloatEncodingStrategy {
        get { optionsMutex.withLock { $0.nonConformingFloatEncodingStrategy } }
        set { optionsMutex.withLock { $0.nonConformingFloatEncodingStrategy = newValue } }
    }

    public var nilEncodingStrategy: DictionaryNilEncodingStrategy {
        get { optionsMutex.withLock { $0.nilEncodingStrategy } }
        set { optionsMutex.withLock { $0.nilEncodingStrategy = newValue } }
    }

    public var keyEncodingStrategy: DictionaryKeyEncodingStrategy {
        get { optionsMutex.withLock { $0.keyEncodingStrategy } }
        set { optionsMutex.withLock { $0.keyEncodingStrategy = newValue } }
    }

    public var userInfo: [CodingUserInfoKey: Sendable] {
        get { userInfoMutex.withLock { $0 } }
        set { userInfoMutex.withLock { $0 = newValue } }
    }

    // MARK: - Initializers

    public init(
        dateEncodingStrategy: DictionaryDateEncodingStrategy = .deferredToDate,
        dataEncodingStrategy: DictionaryDataEncodingStrategy = .base64,
        nonConformingFloatEncodingStrategy: DictionaryNonConformingFloatEncodingStrategy = .throw,
        nilEncodingStrategy: DictionaryNilEncodingStrategy = .useNil,
        keyEncodingStrategy: DictionaryKeyEncodingStrategy = .useDefaultKeys,
        userInfo: [CodingUserInfoKey: Sendable] = [:]
    ) {
        let options = DictionaryEncodingOptions(
            dateEncodingStrategy: dateEncodingStrategy,
            dataEncodingStrategy: dataEncodingStrategy,
            nonConformingFloatEncodingStrategy: nonConformingFloatEncodingStrategy,
            nilEncodingStrategy: nilEncodingStrategy,
            keyEncodingStrategy: keyEncodingStrategy
        )

        self.optionsMutex = Mutex(value: options)
        self.userInfoMutex = Mutex(value: userInfo)
    }

    // MARK: - Instance Methods

    public func encode<T: Encodable>(_ value: T) throws -> [String: Sendable] {
        let options = optionsMutex.withLock { $0 }

        let encoder = DictionarySingleValueEncodingContainer(
            options: options,
            userInfo: userInfo,
            codingPath: []
        )

        try value.encode(to: encoder)

        guard let dictionary = encoder.resolveValue() as? [String: Sendable] else {
            let errorContext = EncodingError.Context(
                codingPath: [],
                debugDescription: "Root component cannot be encoded in Dictionary"
            )

            throw EncodingError.invalidValue(value, errorContext)
        }

        return dictionary
    }
}
