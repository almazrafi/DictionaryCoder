import XCTest

@testable import DictionaryCoder

final class DictionaryEncoderStrategiesTests: XCTestCase, DictionaryEncoderTesting {

    // MARK: - Instance Properties

    private(set) var encoder: DictionaryEncoder!

    // MARK: - Instance Methods

    func testThatEncoderSucceedsWhenEncodingStructUsingDefaultKeys() {
        struct EncodableStruct: Encodable {
            let foo = 123
            let bar = 456
        }

        encoder.keyEncodingStrategy = .useDefaultKeys

        assertEncoderSucceeds(encoding: EncodableStruct())
    }

    func testThatEncoderSucceedsWhenEncodingStructUsingCustomFunctionForKeys() {
        struct EncodableStruct: Encodable {
            let foo = true
            let bar = false
        }

        encoder.keyEncodingStrategy = .custom { codingPath in
            codingPath.last.map { AnyCodingKey("\($0.stringValue).value") } ?? AnyCodingKey("unknown")
        }

        assertEncoderSucceeds(encoding: EncodableStruct())
    }

    // MARK: -

    func testThatEncoderSucceedsWhenEncodingDate() {
        encoder.dateEncodingStrategy = .deferredToDate

        let value = ["foobar": Date(timeIntervalSinceReferenceDate: 123.456)]

        assertEncoderSucceeds(encoding: value)
    }

    func testThatEncoderSucceedsWhenEncodingDateToMillisecondsSince1970() {
        encoder.dateEncodingStrategy = .millisecondsSince1970

        let value = ["foobar": Date(timeIntervalSinceReferenceDate: 123.456)]

        assertEncoderSucceeds(encoding: value)
    }

    func testThatEncoderSucceedsWhenEncodingDateToSecondsSince1970() {
        encoder.dateEncodingStrategy = .secondsSince1970

        let value = ["foobar": Date(timeIntervalSinceReferenceDate: 123.456)]

        assertEncoderSucceeds(encoding: value)
    }

    func testThatEncoderSucceedsWhenEncodingDateToISO8601Format() {
        encoder.dateEncodingStrategy = .iso8601

        let value = ["foobar": Date(timeIntervalSinceReferenceDate: 123.456)]

        assertEncoderSucceeds(encoding: value)
    }

    func testThatEncoderSucceedsWhenEncodingDateWithFractionalSecondsToISO8601Format() {
        encoder.dateEncodingStrategy = .iso8601

        let value = ["foobar": Date(timeIntervalSince1970: 0.9999)]

        // Dates are rounded to milliseconds before fractions of a second are dropped, as in `ISO8601DateFormatter`.
        assertEncoderSucceeds(encoding: value, expecting: ["foobar": "1970-01-01T00:00:01Z"])
    }

    func testThatEncoderSucceedsWhenEncodingDateToISO8601FormatStyle() {
        encoder.dateEncodingStrategy = .iso8601(style: .formatStyle)

        let value = ["foobar": Date(timeIntervalSince1970: 0.9999)]

        assertEncoderSucceeds(encoding: value, expecting: ["foobar": "1970-01-01T00:00:00Z"])
    }

    func testThatEncoderSucceedsWhenEncodingDateUsingFormatter() {
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

        encoder.dateEncodingStrategy = .formatted(dateFormatter)

        let value = ["foobar": Date(timeIntervalSinceReferenceDate: 123.456)]

        assertEncoderSucceeds(encoding: value)
    }

    func testThatEncoderSucceedsWhenEncodingDateUsingCustomFunction() {
        encoder.dateEncodingStrategy = .custom { date, encoder in
            var container = encoder.singleValueContainer()

            try container.encode("\(date.timeIntervalSince1970)")
        }

        let value = ["foobar": Date(timeIntervalSinceReferenceDate: 123.456)]

        assertEncoderSucceeds(encoding: value)
    }

    // MARK: -

    func testThatEncoderSucceedsWhenEncodingData() {
        encoder.dataEncodingStrategy = .deferredToData

        let value = ["foobar": Data([1, 2, 3])]

        assertEncoderSucceeds(encoding: value)
    }

    func testThatEncoderSucceedsWhenEncodingDataToBase64() {
        encoder.dataEncodingStrategy = .base64

        let value = ["foobar": Data([1, 2, 3])]

        assertEncoderSucceeds(encoding: value)
    }

    func testThatEncoderSucceedsWhenEncodingDataToBlob() {
        encoder.dataEncodingStrategy = .blob

        let value = ["foobar": Data([1, 2, 3])]

        assertEncoderSucceeds(encoding: value, expecting: value)
    }

    func testThatEncoderSucceedsWhenEncodingDataUsingCustomFunction() {
        encoder.dataEncodingStrategy = .custom { data, encoder in
            var container = encoder.singleValueContainer()

            let string = data
                .map { "\($0)" }
                .joined(separator: ", ")

            try container.encode(string)
        }

        let value = ["foobar": Data([1, 2, 3])]

        assertEncoderSucceeds(encoding: value)
    }

    // MARK: -

    func testThatEncoderSucceedsWhenEncodingDecimal() throws {
        struct DeferredDecimal: Encodable {
            let value: Decimal

            func encode(to encoder: Encoder) throws {
                try value.encode(to: encoder)
            }
        }

        let decimal = Decimal(string: "1.5")!
        let expectedDictionary = try encoder.encode(["foobar": DeferredDecimal(value: decimal)])

        XCTAssert(expectedDictionary["foobar"] is [String: Any])

        assertEncoderSucceeds(encoding: ["foobar": decimal], expecting: expectedDictionary)
    }

    func testThatEncoderSucceedsWhenEncodingDecimalToNumber() {
        encoder.decimalEncodingStrategy = .number

        let value = [
            "foo": Decimal(string: "1.5")!,
            "bar": Decimal(string: "-2.25")!
        ]

        assertEncoderSucceeds(encoding: value, expecting: value)
    }

    func testThatEncoderFailsWhenEncodingPositiveInfinityFloat() {
        encoder.nonConformingFloatEncodingStrategy = .throw

        let number = Float.infinity
        let value = ["foobar": number]

        assertEncoderFails(encoding: value) { error in
            switch error {
            case let EncodingError.invalidValue(invalidValue as Float, _):
                return invalidValue == number

            default:
                return false
            }
        }
    }

    func testThatEncoderFailsWhenEncodingNegativeInfinityFloat() {
        encoder.nonConformingFloatEncodingStrategy = .throw

        let number = -Float.infinity
        let value = ["foobar": number]

        assertEncoderFails(encoding: value) { error in
            switch error {
            case let EncodingError.invalidValue(invalidValue as Float, _):
                return invalidValue == number

            default:
                return false
            }
        }
    }

    func testThatEncoderFailsWhenEncodingNanFloat() {
        encoder.nonConformingFloatEncodingStrategy = .throw

        let value = ["foobar": Float.nan]

        assertEncoderFails(encoding: value) { error in
            switch error {
            case let EncodingError.invalidValue(invalidValue as Float, _):
                return invalidValue.isNaN

            default:
                return false
            }
        }
    }

    func testThatEncoderFailsWhenEncodingInfinityFloatInNestedKeyedContainer() {
        encoder.nonConformingFloatEncodingStrategy = .throw

        let value = ["foo": [["bar": 1.0], ["bar": Double.infinity]]]

        assertEncoderFails(encoding: value) { error in
            switch error {
            case let EncodingError.invalidValue(_, context):
                return context.codingPath.map(\.stringValue) == ["foo", "1", "bar"]

            default:
                return false
            }
        }
    }

    func testThatEncoderFailsWhenEncodingInfinityFloatInNestedUnkeyedContainer() {
        encoder.nonConformingFloatEncodingStrategy = .throw

        let value = ["foo": [["bar": [1.0, Double.infinity]]]]

        assertEncoderFails(encoding: value) { error in
            switch error {
            case let EncodingError.invalidValue(_, context):
                return context.codingPath.map(\.stringValue) == ["foo", "0", "bar", "1"]

            default:
                return false
            }
        }
    }

    func testThatEncoderSucceedsWhenEncodingNonConformingFloatToString() {
        encoder.nonConformingFloatEncodingStrategy = .convertToString(
            positiveInfinity: "+∞",
            negativeInfinity: "-∞",
            nan: "¬"
        )

        let value = [
            "foo": Float.infinity,
            "bar": -Float.infinity,
            "baz": Float.nan
        ]

        assertEncoderSucceeds(encoding: value)
    }

    // MARK: -

    func testThatEncoderSucceedsWhenEncodingNil() {
        struct EncodableStruct: Encodable {
            let foobar: Int? = nil
        }

        encoder.nilEncodingStrategy = .useNil

        assertEncoderSucceeds(encoding: EncodableStruct())
    }

    func testThatEncoderSucceedsWhenEncodingNilToNSNull() {
        struct EncodableStruct: Encodable {
            let foobar: Int? = nil
        }

        encoder.nilEncodingStrategy = .useNSNull

        assertEncoderSucceeds(encoding: EncodableStruct())
    }

    // MARK: - XCTestCase

    override func setUp() {
        super.setUp()

        encoder = DictionaryEncoder()
    }
}
