import Foundation

public enum DictionaryKeyEncodingStrategy: Sendable {

    // MARK: - Enumeration Cases

    case useDefaultKeys
    case custom(@Sendable (_ codingPath: [CodingKey]) -> CodingKey)
}
