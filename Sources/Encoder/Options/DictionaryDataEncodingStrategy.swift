import Foundation

public enum DictionaryDataEncodingStrategy: Sendable {

    // MARK: - Enumeration Cases

    case deferredToData
    case base64
    case custom(@Sendable (_ data: Data, _ encoder: Encoder) throws -> Void)
}
