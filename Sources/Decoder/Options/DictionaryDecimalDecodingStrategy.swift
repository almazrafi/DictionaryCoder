/// The strategies for decoding decimals, which can be combined to accept both representations.
public struct DictionaryDecimalDecodingStrategy: OptionSet, Sendable {

    // MARK: - Type Properties

    /// The strategy that decodes decimals from the keyed representation of the decimal type itself.
    public static let deferredToDecimal = Self(rawValue: 1 << 0)

    /// The strategy that decodes decimals from numbers, such as `Decimal`, `NSDecimalNumber` or `Double`.
    public static let number = Self(rawValue: 1 << 1)

    // MARK: - Instance Properties

    public let rawValue: Int

    // MARK: - Initializers

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}
