internal struct DictionaryDecodingOptions {

    // MARK: - Instance Properties

    internal var dateDecodingStrategy: DictionaryDateDecodingStrategy
    internal var dataDecodingStrategy: DictionaryDataDecodingStrategy
    internal var decimalDecodingStrategy: DictionaryDecimalDecodingStrategy
    internal var nonConformingFloatDecodingStrategy: DictionaryNonConformingFloatDecodingStrategy
    internal var keyDecodingStrategy: DictionaryKeyDecodingStrategy
}
