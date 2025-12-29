import Foundation

internal struct DictionaryEncodingOptions {

    // MARK: - Instance Properties

    internal var dateEncodingStrategy: DictionaryDateEncodingStrategy
    internal var dataEncodingStrategy: DictionaryDataEncodingStrategy
    internal var nonConformingFloatEncodingStrategy: DictionaryNonConformingFloatEncodingStrategy
    internal var nilEncodingStrategy: DictionaryNilEncodingStrategy
    internal var keyEncodingStrategy: DictionaryKeyEncodingStrategy
}
