import Foundation

public final class DictionaryEncoder: Sendable {

    // MARK: - Instance Properties

    public let dateEncodingStrategy: DictionaryDateEncodingStrategy
    public let dataEncodingStrategy: DictionaryDataEncodingStrategy
    public let nonConformingFloatEncodingStrategy: DictionaryNonConformingFloatEncodingStrategy
    public let nilEncodingStrategy: DictionaryNilEncodingStrategy
    public let keyEncodingStrategy: DictionaryKeyEncodingStrategy
    public let userInfo: [CodingUserInfoKey: Sendable]

    // MARK: - Initializers

    public init(
        dateEncodingStrategy: DictionaryDateEncodingStrategy = .deferredToDate,
        dataEncodingStrategy: DictionaryDataEncodingStrategy = .base64,
        nonConformingFloatEncodingStrategy: DictionaryNonConformingFloatEncodingStrategy = .throw,
        nilEncodingStrategy: DictionaryNilEncodingStrategy = .useNil,
        keyEncodingStrategy: DictionaryKeyEncodingStrategy = .useDefaultKeys,
        userInfo: [CodingUserInfoKey: Sendable] = [:]
    ) {
        self.dateEncodingStrategy = dateEncodingStrategy
        self.dataEncodingStrategy = dataEncodingStrategy
        self.nonConformingFloatEncodingStrategy = nonConformingFloatEncodingStrategy
        self.nilEncodingStrategy = nilEncodingStrategy
        self.keyEncodingStrategy = keyEncodingStrategy
        self.userInfo = userInfo
    }

    // MARK: - Instance Methods

    public func encode<T: Encodable>(_ value: T) throws -> [String: Sendable] {
        let options = DictionaryEncodingOptions(
            dateEncodingStrategy: dateEncodingStrategy,
            dataEncodingStrategy: dataEncodingStrategy,
            nonConformingFloatEncodingStrategy: nonConformingFloatEncodingStrategy,
            nilEncodingStrategy: nilEncodingStrategy,
            keyEncodingStrategy: keyEncodingStrategy
        )

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
