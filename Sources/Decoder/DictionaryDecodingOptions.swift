import Foundation

internal struct DictionaryDecodingOptions {

    // MARK: - Instance Properties

    internal let dateDecodingStrategy: DictionaryDateDecodingStrategy
    internal let dataDecodingStrategy: DictionaryDataDecodingStrategy
    internal let nonConformingFloatDecodingStrategy: DictionaryNonConformingFloatDecodingStrategy
    internal let keyDecodingStrategy: DictionaryKeyDecodingStrategy
}
