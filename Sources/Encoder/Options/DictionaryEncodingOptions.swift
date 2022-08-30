import Foundation

internal struct DictionaryEncodingOptions {

    // MARK: - Instance Properties

    internal let dateEncodingStrategy: DictionaryDateEncodingStrategy
    internal let dataEncodingStrategy: DictionaryDataEncodingStrategy
    internal let nonConformingFloatEncodingStrategy: DictionaryNonConformingFloatEncodingStrategy
    internal let keyEncodingStrategy: DictionaryKeyEncodingStrategy
}
