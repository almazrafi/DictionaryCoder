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

    @available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
    func testThatEncoderSucceedsWhenEncodingDateToISO8601Format() {
        encoder.dateEncodingStrategy = .iso8601

        let value = ["foobar": Date(timeIntervalSinceReferenceDate: 123.456)]

        assertEncoderSucceeds(encoding: value)
    }

    @available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
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

    override func setUp() {
        super.setUp()

        encoder = DictionaryEncoder()
    }
}
