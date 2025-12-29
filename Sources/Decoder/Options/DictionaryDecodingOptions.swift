import Foundation

internal struct DictionaryDecodingOptions {

    // MARK: - Instance Properties

    internal var dateDecodingStrategy: DictionaryDateDecodingStrategy
    internal var dataDecodingStrategy: DictionaryDataDecodingStrategy
    internal var nonConformingFloatDecodingStrategy: DictionaryNonConformingFloatDecodingStrategy
    internal var keyDecodingStrategy: DictionaryKeyDecodingStrategy
}
