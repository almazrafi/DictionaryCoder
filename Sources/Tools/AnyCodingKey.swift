import Foundation

internal struct AnyCodingKey: CodingKey {

    // MARK: - Type Properties

    internal static let `super` = AnyCodingKey("super")

    // MARK: - Instance Properties

    internal let stringValue: String
    internal let intValue: Int?

    // MARK: - Initializers

    internal init(_ stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    internal init(_ intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }

    internal init?(stringValue: String) {
        self.init(stringValue)
    }

    internal init?(intValue: Int) {
        self.init(intValue)
    }
}
