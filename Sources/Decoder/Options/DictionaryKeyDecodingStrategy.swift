import Foundation

/// The values that determine how to decode a type’s coding keys from Dictionary keys.
public enum DictionaryKeyDecodingStrategy: Sendable {

    // MARK: - Enumeration Cases

    /// A key decoding strategy that doesn’t change key names during decoding.
    case useDefaultKeys

    /// A key decoding strategy defined by the closure you supply.
    ///
    /// If several keys are converted to the same key,
    /// the value of the lexicographically smallest original key is used.
    case custom(@Sendable (_ codingPath: [CodingKey]) -> CodingKey)
}
