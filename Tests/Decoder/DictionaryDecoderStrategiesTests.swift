import XCTest

@testable import DictionaryCoder

final class DictionaryDecoderStrategiesTests: XCTestCase, DictionaryDecoderTesting {

    // MARK: - Instance Properties

    private(set) var decoder: DictionaryDecoder!

    // MARK: - Instance Methods

    func testThatDecoderSucceedsWhenDecodingStructUsingDefaultKeys() {
        struct DecodableStruct: Decodable, Equatable {
            let foo: Int
            let bar: Int
        }

        decoder.keyDecodingStrategy = .useDefaultKeys

        let dictionary = [
            "foo": 123,
            "bar": 456
        ]

        assertDecoderSucceeds(decoding: DecodableStruct.self, from: dictionary)
    }

    func testThatDecoderSucceedsWhenDecodingStructUsingCustomFunctionForKeys() {
        struct DecodableStruct: Decodable, Equatable {
            let foo: Bool
            let bar: Bool
        }

        decoder.keyDecodingStrategy = .custom { codingPath in
            if let codingKey = codingPath.last?.stringValue.components(separatedBy: ".").first {
                return AnyCodingKey(codingKey)
            }

            return AnyCodingKey("unknown")
        }

        let dictionary = [
            "foo.value": true,
            "bar.value": false
        ]

        assertDecoderSucceeds(decoding: DecodableStruct.self, from: dictionary)
    }

    func testThatDecoderSucceedsWhenDecodingCollidingKeysUsingCustomFunctionForKeys() {
        decoder.keyDecodingStrategy = .custom { _ in AnyCodingKey("foobar") }

        let letters = "abcdefghijklmnopqrstuvwxyz".map(String.init)
        let dictionary = Dictionary(uniqueKeysWithValues: letters.enumerated().map { ($1, $0) })

        assertDecoderSucceeds(decoding: ["foobar": 0], from: dictionary)
    }

    // MARK: -

    func testThatDecoderSucceedsWhenDecodingDate() {
        decoder.dateDecodingStrategy = .deferredToDate

        let dictionary = ["foobar": 123_456.789]

        assertDecoderSucceeds(decoding: [String: Date].self, from: dictionary)
    }

    func testThatDecoderFailsWhenDecodingInvalidDate() {
        decoder.dateDecodingStrategy = .deferredToDate

        let dictionary = ["foobar": "qwe"]

        assertDecoderFails(decoding: [String: Date].self, from: dictionary) { error in
            switch error {
            case let DecodingError.typeMismatch(type, _) where type is Double.Type:
                return true

            default:
                return false
            }
        }
    }

    func testThatDecoderSucceedsWhenDecodingDateFromMillisecondsSince1970() {
        decoder.dateDecodingStrategy = .millisecondsSince1970

        let dictionary = ["foobar": 123_456.789]

        assertDecoderSucceeds(decoding: [String: Date].self, from: dictionary)
    }

    func testThatDecoderSucceedsWhenDecodingDateFromSecondsSince1970() {
        decoder.dateDecodingStrategy = .secondsSince1970

        let dictionary = ["foobar": 123_456.789]

        assertDecoderSucceeds(decoding: [String: Date].self, from: dictionary)
    }

    func testThatDecoderSucceedsWhenDecodingDateFromISO8601Format() {
        decoder.dateDecodingStrategy = .iso8601

        let dictionary = ["foobar": "2001-01-01T00:02:03Z"]

        assertDecoderSucceeds(decoding: [String: Date].self, from: dictionary)
    }

    func testThatDecoderFailsWhenDecodingInvalidDateFromISO8601Format() {
        decoder.dateDecodingStrategy = .iso8601

        let dictionary = ["foobar": "qwe"]

        assertDecoderFails(decoding: [String: Date].self, from: dictionary) { error in
            switch error {
            case DecodingError.dataCorrupted:
                return true

            default:
                return false
            }
        }
    }

    func testThatDecoderSucceedsWhenDecodingDateUsingFormatter() {
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        decoder.dateDecodingStrategy = .formatted(dateFormatter)

        let dictionary = ["foobar": "2001-01-02"]

        assertDecoderSucceeds(decoding: [String: Date].self, from: dictionary)
    }

    func testThatDecoderFailsWhenDecodingInvalidDateUsingFormatter() {
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        decoder.dateDecodingStrategy = .formatted(dateFormatter)

        let dictionary = ["foobar": "qwe"]

        assertDecoderFails(decoding: [String: Date].self, from: dictionary) { error in
            switch error {
            case DecodingError.dataCorrupted:
                return true

            default:
                return false
            }
        }
    }

    func testThatDecoderSucceedsWhenDecodingDateUsingCustomFunction() {
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()

            guard let timeIntervalSince1970 = TimeInterval(try container.decode(String.self)) else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date")
            }

            return Date(timeIntervalSince1970: timeIntervalSince1970)
        }

        let dictionary = ["foobar": "123456.789"]

        assertDecoderSucceeds(decoding: [String: Date].self, from: dictionary)
    }

    // MARK: -

    func testThatDecoderSucceedsWhenDecodingData() {
        decoder.dataDecodingStrategy = .deferredToData

        let dictionary: [String: [UInt8]] = ["foobar": [1, 2, 3]]

        assertDecoderSucceeds(decoding: [String: Data].self, from: dictionary)
    }

    func testThatDecoderFailsWhenDecodingInvalidData() {
        decoder.dataDecodingStrategy = .deferredToData

        let dictionary = ["foobar": "qwe"]

        assertDecoderFails(decoding: [String: Data].self, from: dictionary) { error in
            switch error {
            case let DecodingError.typeMismatch(type, _) where type is [Any].Type:
                return true

            default:
                return false
            }
        }
    }

    func testThatDecoderSucceedsWhenDecodingDataToBase64() {
        decoder.dataDecodingStrategy = .base64

        let dictionary = ["foobar": "AQID"]

        assertDecoderSucceeds(decoding: [String: Data].self, from: dictionary)
    }

    func testThatDecoderFailsWhenDecodingInvalidDataToBase64() {
        decoder.dataDecodingStrategy = .base64

        let dictionary = ["foobar": "123"]

        assertDecoderFails(decoding: [String: Data].self, from: dictionary) { error in
            switch error {
            case DecodingError.dataCorrupted:
                return true

            default:
                return false
            }
        }
    }

    func testThatDecoderSucceedsWhenDecodingDataToBlob() {
        decoder.dataDecodingStrategy = .blob

        let dictionary: [String: Any] = [
            "foo": Data([1, 2, 3]),
            "bar": NSData(data: Data([1, 2, 3]))
        ]

        let value = [
            "foo": Data([1, 2, 3]),
            "bar": Data([1, 2, 3])
        ]

        assertDecoderSucceeds(decoding: value, from: dictionary)
    }

    func testThatDecoderFailsWhenDecodingInvalidDataToBlob() {
        decoder.dataDecodingStrategy = .blob

        let dictionary = ["foobar": "AQID"]

        assertDecoderFails(decoding: [String: Data].self, from: dictionary) { error in
            switch error {
            case let DecodingError.typeMismatch(type, _) where type is Data.Type:
                return true

            default:
                return false
            }
        }
    }

    func testThatDecoderSucceedsWhenDecodingDataUsingCustomFunction() {
        decoder.dataDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)

            let bytes = string
                .components(separatedBy: ", ")
                .compactMap { UInt8($0) }

            return Data(bytes)
        }

        let dictionary = ["foobar": "1, 2, 3"]

        assertDecoderSucceeds(decoding: [String: Data].self, from: dictionary)
    }

    func testThatDecoderFailsWhenDecodingInvalidDataUsingCustomFunction() {
        decoder.dataDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)

            let bytes = string
                .components(separatedBy: ", ")
                .compactMap { UInt8($0) }

            return Data(bytes)
        }

        let dictionary = ["foobar": 123]

        assertDecoderFails(decoding: [String: Data].self, from: dictionary) { error in
            switch error {
            case let DecodingError.typeMismatch(type, _) where type is String.Type:
                return true

            default:
                return false
            }
        }
    }

    // MARK: -

    func testThatDecoderSucceedsWhenDecodingDecimal() throws {
        let value = [
            "foo": Decimal(string: "1.5")!,
            "bar": Decimal(string: "-2.25")!
        ]

        let dictionary = try DictionaryEncoder().encode(value)

        assertDecoderSucceeds(decoding: value, from: dictionary)
    }

    func testThatDecoderFailsWhenDecodingInvalidDecimal() {
        let dictionary = ["foobar": 1.5]

        assertDecoderFails(decoding: [String: Decimal].self, from: dictionary) { error in
            switch error {
            case DecodingError.typeMismatch:
                return true

            default:
                return false
            }
        }
    }

    func testThatDecoderSucceedsWhenDecodingDecimalFromNumber() {
        decoder.decimalDecodingStrategy = .number

        let dictionary: [String: Any] = [
            "foo": Decimal(string: "1.5")!,
            "bar": NSDecimalNumber(string: "-2.25"),
            "baz": 0.1,
            "qux": 3
        ]

        let value = [
            "foo": Decimal(string: "1.5")!,
            "bar": Decimal(string: "-2.25")!,
            "baz": Decimal(string: "0.1")!,
            "qux": Decimal(3)
        ]

        assertDecoderSucceeds(decoding: value, from: dictionary)
    }

    func testThatDecoderFailsWhenDecodingInvalidDecimalFromNumber() throws {
        decoder.decimalDecodingStrategy = .number

        let dictionaries: [[String: Any]] = [
            ["foobar": true],
            try DictionaryEncoder().encode(["foobar": Decimal(string: "1.5")!])
        ]

        for dictionary in dictionaries {
            assertDecoderFails(decoding: [String: Decimal].self, from: dictionary) { error in
                switch error {
                case let DecodingError.typeMismatch(type, _) where type is Decimal.Type:
                    return true

                default:
                    return false
                }
            }
        }
    }

    func testThatDecoderSucceedsWhenDecodingDecimalFromNumberOrKeyedRepresentation() throws {
        decoder.decimalDecodingStrategy = [.deferredToDecimal, .number]

        var dictionary = try DictionaryEncoder().encode(["foo": Decimal(string: "1.5")!])

        dictionary["bar"] = 0.25

        let value = [
            "foo": Decimal(string: "1.5")!,
            "bar": Decimal(string: "0.25")!
        ]

        assertDecoderSucceeds(decoding: value, from: dictionary)
    }

    func testThatDecoderFailsWhenDecodingNonConformingFloat() {
        decoder.nonConformingFloatDecodingStrategy = .throw

        let dictionary = [
            "foo": Float.infinity,
            "bar": -Float.infinity,
            "baz": Float.nan
        ]

        assertDecoderFails(decoding: [String: Float].self, from: dictionary) { error in
            switch error {
            case DecodingError.dataCorrupted:
                return true

            default:
                return false
            }
        }
    }

    func testThatDecoderSucceedsWhenDecodingNonConformingFloatFromString() {
        decoder.nonConformingFloatDecodingStrategy = .convertFromString(
            positiveInfinity: "+∞",
            negativeInfinity: "-∞",
            nan: "¬"
        )

        let dictionary = [
            "foo": "+∞",
            "bar": "-∞",
            "baz": "¬"
        ]

        assertDecoderSucceeds(decoding: [String: Float].self, from: dictionary)
    }

    func testThatDecoderFailsWhenDecodingNonConformingFloatFromInvalidString() {
        decoder.nonConformingFloatDecodingStrategy = .convertFromString(
            positiveInfinity: "+∞",
            negativeInfinity: "-∞",
            nan: "¬"
        )

        let dictionary = ["foobar": "qwe"]

        assertDecoderFails(decoding: [String: Float].self, from: dictionary) { error in
            switch error {
            case let DecodingError.typeMismatch(type, _) where type is Float.Type:
                return true

            default:
                return false
            }
        }
    }

    func testThatDecoderFailsWhenDecodingFloatFromWrongType() {
        let dictionary = ["foobar": true]

        assertDecoderFails(decoding: [String: Float].self, from: dictionary) { error in
            switch error {
            case let DecodingError.typeMismatch(type, _) where type is Float.Type:
                return true

            default:
                return false
            }
        }
    }

    func testThatDecoderFailsWhenDecodingFloatFromNil() {
        let dictionary: [String: [Float?]] = ["foobar": [1.23, nil]]

        assertDecoderFails(decoding: [String: [Float]].self, from: dictionary) { error in
            switch error {
            case let DecodingError.typeMismatch(type, _) where type is Float.Type:
                return true

            default:
                return false
            }
        }
    }

    // MARK: - XCTestCase

    override func setUp() {
        super.setUp()

        decoder = DictionaryDecoder()
    }
}
