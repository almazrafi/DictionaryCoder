import XCTest
import DictionaryCoder

protocol DictionaryEncoderTesting {

    // MARK: - Instance Properties

    var encoder: DictionaryEncoder! { get }
}

extension DictionaryEncoderTesting {

    // MARK: - Instance Methods

    private func makeExpectedDictionary<T: Encodable>(for value: T) throws -> [String: Any] {
        let jsonEncoder = JSONEncoder()

        jsonEncoder.keyEncodingStrategy = encoder.keyEncodingStrategy.jsonEncodingStrategy
        jsonEncoder.dateEncodingStrategy = encoder.dateEncodingStrategy.jsonEncodingStrategy
        jsonEncoder.dataEncodingStrategy = try XCTUnwrap(
            encoder.dataEncodingStrategy.jsonEncodingStrategy,
            "JSON has no data type, pass the expected dictionary instead."
        )
        jsonEncoder.nonConformingFloatEncodingStrategy = encoder.nonConformingFloatEncodingStrategy.jsonEncodingStrategy

        let data = try jsonEncoder.encode(value)
        let json = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)

        return json as? [String: Any] ?? [:]
    }

    // MARK: -

    func assertEncoderSucceeds<T: Encodable>(
        encoding value: T,
        expecting expectedDictionary: [String: Any],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        do {
            let dictionary = try encoder.encode(value)

            XCTAssertEqual(
                NSDictionary(dictionary: expectedDictionary),
                NSDictionary(dictionary: dictionary),
                file: file,
                line: line
            )
        } catch {
            XCTFail("Test encountered unexpected error: \(error)")
        }
    }

    func assertEncoderSucceeds<T: Encodable>(
        encoding value: T,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        do {
            let expectedDictionary = try makeExpectedDictionary(for: value)

            assertEncoderSucceeds(
                encoding: value,
                expecting: expectedDictionary,
                file: file,
                line: line
            )
        } catch {
            XCTFail("Test encountered unexpected error: \(error)")
        }
    }

    func assertEncoderFails<T: Encodable>(
        encoding value: T,
        file: StaticString = #filePath,
        line: UInt = #line,
        errorValidation: (_ error: Error) -> Bool
    ) {
        do {
            _ = try encoder.encode(value)

            XCTFail("Test encountered unexpected behavior")
        } catch {
            if !errorValidation(error) {
                XCTFail("Test encountered unexpected error: \(error)", file: file, line: line)
            }
        }
    }
}

extension DictionaryKeyEncodingStrategy {

    // MARK: - Instance Properties

    fileprivate var jsonEncodingStrategy: JSONEncoder.KeyEncodingStrategy {
        switch self {
        case .useDefaultKeys:
            return .useDefaultKeys

        case let .custom(closure):
            return .custom(closure)
        }
    }
}

extension DictionaryDateEncodingStrategy {

    // MARK: - Instance Properties

    fileprivate var jsonEncodingStrategy: JSONEncoder.DateEncodingStrategy {
        switch self {
        case .deferredToDate:
            return .deferredToDate

        case .millisecondsSince1970:
            return .millisecondsSince1970

        case .secondsSince1970:
            return .secondsSince1970

        case .iso8601(style: .dateFormatter):
            return .custom { date, encoder in
                var container = encoder.singleValueContainer()

                try container.encode(
                    ISO8601DateFormatter.string(
                        from: date,
                        timeZone: TimeZone(secondsFromGMT: 0)!,
                        formatOptions: .withInternetDateTime
                    )
                )
            }

        case .iso8601(style: .formatStyle):
            return .custom { date, encoder in
                var container = encoder.singleValueContainer()

                try container.encode(Date.ISO8601FormatStyle().format(date))
            }

        case let .formatted(dateFormatter):
            return .formatted(dateFormatter)

        case let .custom(closure):
            return .custom(closure)
        }
    }
}

extension DictionaryDataEncodingStrategy {

    // MARK: - Instance Properties

    fileprivate var jsonEncodingStrategy: JSONEncoder.DataEncodingStrategy? {
        switch self {
        case .deferredToData:
            return .deferredToData

        case .base64:
            return .base64

        case .blob:
            return nil

        case let .custom(closure):
            return .custom(closure)
        }
    }
}

extension DictionaryNonConformingFloatEncodingStrategy {

    // MARK: - Instance Properties

    fileprivate var jsonEncodingStrategy: JSONEncoder.NonConformingFloatEncodingStrategy {
        switch self {
        case let .convertToString(positiveInfinity, negativeInfinity, nan):
            return .convertToString(
                positiveInfinity: positiveInfinity,
                negativeInfinity: negativeInfinity,
                nan: nan
            )

        case .throw:
            return .throw
        }
    }
}
