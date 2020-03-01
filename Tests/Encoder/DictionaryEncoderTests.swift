import XCTest

@testable import DictionaryCoder

final class DictionaryEncoderTests: XCTestCase, DictionaryEncoderTesting {

    // MARK: - Instance Properties

    private(set) var encoder: DictionaryEncoder!

    // MARK: - Instance Methods

    func testThatEncoderSucceedsWhenEncodingEmptyDictionary() {
        let value: [String: String] = [:]

        assertEncoderSucceeds(encoding: value)
    }

    func testThatEncoderSucceedsWhenEncodingStringToBoolDictionary() {
        let value = [
            "foo": true,
            "bar": false
        ]

        assertEncoderSucceeds(encoding: value)
    }

    func testThatEncoderSucceedsWhenEncodingStringToIntDictionary() {
        let value = [
            "foo": 123,
            "bar": -456
        ]

        assertEncoderSucceeds(encoding: value)
    }

    func testThatEncoderSucceedsWhenEncodingStringToInt8Dictionary() {
        let value: [String: Int8] = [
            "foo": 12,
            "bar": -34
        ]

        assertEncoderSucceeds(encoding: value)
    }

    func testThatEncoderSucceedsWhenEncodingStringToInt16Dictionary() {
        let value: [String: Int16] = [
            "foo": 123,
            "bar": -456
        ]

        assertEncoderSucceeds(encoding: value)
    }

    func testThatEncoderSucceedsWhenEncodingStringToInt32Dictionary() {
        let value: [String: Int32] = [
            "foo": 123,
            "bar": -456
        ]

        assertEncoderSucceeds(encoding: value)
    }

    func testThatEncoderSucceedsWhenEncodingStringToInt64Dictionary() {
        let value: [String: Int64] = [
            "foo": 123,
            "bar": -456
        ]

        assertEncoderSucceeds(encoding: value)
    }

    func testThatEncoderSucceedsWhenEncodingStringToUIntDictionary() {
        let value: [String: UInt] = [
            "foo": 123,
            "bar": 456
        ]

        assertEncoderSucceeds(encoding: value)
    }

    func testThatEncoderSucceedsWhenEncodingStringToUInt8Dictionary() {
        let value: [String: UInt8] = [
            "foo": 12,
            "bar": 34
        ]

        assertEncoderSucceeds(encoding: value)
    }

    func testThatEncoderSucceedsWhenEncodingStringToUInt16Dictionary() {
        let value: [String: UInt16] = [
            "foo": 123,
            "bar": 456
        ]

        assertEncoderSucceeds(encoding: value)
    }

    func testThatEncoderSucceedsWhenEncodingStringToUInt32Dictionary() {
        let value: [String: UInt32] = [
            "foo": 123,
            "bar": 456
        ]

        assertEncoderSucceeds(encoding: value)
    }

    func testThatEncoderSucceedsWhenEncodingStringToUInt64Dictionary() {
        let value: [String: UInt64] = [
            "foo": 123,
            "bar": 456
        ]

        assertEncoderSucceeds(encoding: value)
    }

    func testThatEncoderSucceedsWhenEncodingStringToDoubleDictionary() {
        let value = [
            "foo": 1.23,
            "bar": -45.6
        ]

        assertEncoderSucceeds(encoding: value)
    }

    func testThatEncoderSucceedsWhenEncodingStringToFloatDictionary() {
        let value: [String: Float] = [
            "foo": 1.23,
            "bar": -45.6
        ]

        assertEncoderSucceeds(encoding: value)
    }

    func testThatEncoderSucceedsWhenEncodingStringToStringDictionary() {
        let value = [
            "foo": "qwe",
            "bar": "asd"
        ]

        assertEncoderSucceeds(encoding: value)
    }

    func testThatEncoderSucceedsWhenEncodingStringToURLDictionary() {
        let value = [
            "foo": URL(string: "https://swift.org")!,
            "bar": URL(string: "https://apple.com")!
        ]

        assertEncoderSucceeds(encoding: value)
    }

    func testThatEncoderSucceedsWhenEncodingStringToArrayDictionary() {
        let value: [String: [Int?]] = [
            "foo": [1, 2, 3],
            "bar": [4, nil, 6]
        ]

        assertEncoderSucceeds(encoding: value)
    }

    func testThatEncoderSucceedsWhenEncodingNestedStringToIntDictionary() {
        let value = [
            "foo": [
                "bar": 123,
                "baz": -456
            ]
        ]

        assertEncoderSucceeds(encoding: value)
    }

    func testThatEncoderSucceedsWhenEncodingNestedArrayOfStringToIntDictionaries() {
        let value = [
            "foo": [
                [
                    "bar": 123,
                    "baz": 456
                ]
            ]
        ]

        assertEncoderSucceeds(encoding: value)
    }

    // MARK: -

    func testThatEncoderSucceedsWhenEncodingEmptyStruct() {
        struct EncodableStruct: Encodable { }

        assertEncoderSucceeds(encoding: EncodableStruct())
    }

    func testThatEncoderSucceedsWhenEncodingStructWithMultipleProperties() {
        struct EncodableStruct: Encodable {
            let foo = true
            let bar: Int? = 123
            let baz: Int? = nil
            let bat = "qwe"
        }

        assertEncoderSucceeds(encoding: EncodableStruct())
    }

    func testThatEncoderSucceedsWhenEncodingStructWithNestedStruct() {
        struct EncodableStruct: Encodable {
            struct NestedStruct: Encodable {
                let bar = 123
                let baz = 456
            }

            let foo = NestedStruct()
        }

        assertEncoderSucceeds(encoding: EncodableStruct())
    }

    func testThatEncoderSucceedsWhenEncodingStructWithNestedEnum() {
        struct EncodableStruct: Encodable {
            enum NestedEnum: String, Encodable {
                case qwe
                case asd
            }

            let foo = NestedEnum.qwe
            let bar = NestedEnum.asd
        }

        assertEncoderSucceeds(encoding: EncodableStruct())
    }

    func testThatEncoderSucceedsWhenEncodingStructInSeparateKeyedContainers() {
        struct EncodableStruct: Encodable {
            enum CodingKeys: String, CodingKey {
                case foo
                case bar
            }

            let foo = 123
            let bar = 456

            func encode(to encoder: Encoder) throws {
                var fooContainer = encoder.container(keyedBy: CodingKeys.self)
                var barContainer = encoder.container(keyedBy: CodingKeys.self)

                try fooContainer.encode(foo, forKey: .foo)
                try barContainer.encode(bar, forKey: .bar)
            }
        }

        assertEncoderSucceeds(encoding: EncodableStruct())
    }

    func testThatEncoderSucceedsWhenEncodingStructInSeparateUnkeyedContainers() {
        struct EncodableStruct: Encodable {
            enum CodingKeys: String, CodingKey {
                case foo
            }

            let bar = 123
            let baz = 456

            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)

                var barContainer = container.nestedUnkeyedContainer(forKey: .foo)
                var bazContainer = container.nestedUnkeyedContainer(forKey: .foo)

                try barContainer.encode(bar)
                try bazContainer.encode(baz)
            }
        }

        assertEncoderSucceeds(encoding: EncodableStruct())
    }

    func testThatEncoderSucceedsWhenEncodingStructInSeparateKeyedContainersOfUnkeyedContainer() {
        struct EncodableStruct: Encodable {
            enum CodingKeys: String, CodingKey {
                case foo
            }

            enum BarCodingKeys: String, CodingKey {
                case bar
            }

            enum BazCodingKeys: String, CodingKey {
                case baz
            }

            let bar = 123
            let baz = 456

            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                var unkeyedContainer = container.nestedUnkeyedContainer(forKey: .foo)

                var barContainer = unkeyedContainer.nestedContainer(keyedBy: BarCodingKeys.self)
                var bazContainer = unkeyedContainer.nestedContainer(keyedBy: BazCodingKeys.self)

                try barContainer.encode(bar, forKey: .bar)
                try bazContainer.encode(baz, forKey: .baz)
            }
        }

        assertEncoderSucceeds(encoding: EncodableStruct())
    }

    func testThatEncoderSucceedsWhenEncodingStructInSeparateNestedKeyedContainers() {
        struct EncodableStruct: Encodable {
            enum CodingKeys: String, CodingKey {
                case foo
            }

            struct NestedStruct {
                enum CodingKeys: String, CodingKey {
                    case bar
                    case baz
                }

                let bar = 123
                let baz = 456
            }

            let foo = NestedStruct()

            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)

                var barContainer = container.nestedContainer(keyedBy: NestedStruct.CodingKeys.self, forKey: .foo)
                var bazContainer = container.nestedContainer(keyedBy: NestedStruct.CodingKeys.self, forKey: .foo)

                try barContainer.encode(foo.bar, forKey: .bar)
                try bazContainer.encode(foo.baz, forKey: .baz)
            }
        }

        assertEncoderSucceeds(encoding: EncodableStruct())
    }

    func testThatEncoderSucceedsWhenEncodingStructUsingSuperEncoder() {
        struct EncodableStruct: Encodable {
            enum CodingKeys: String, CodingKey {
                case foo
                case bar
                case baz
                case bat
            }

            let foo = "qwe"
            let bar = "asd"
            let baz = 123
            let bat = 456

            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)

                try container.encode(baz, forKey: .baz)
                try container.encode(bat, forKey: .bat)

                let superEncoder = container.superEncoder()
                var superContainer = superEncoder.container(keyedBy: CodingKeys.self)

                try superContainer.encode(foo, forKey: .foo)
                try superContainer.encode(bar, forKey: .bar)
            }
        }

        assertEncoderSucceeds(encoding: EncodableStruct())
    }

    func testThatEncoderSucceedsWhenEncodingStructUsingSuperEncoderForKeys() {
        struct EncodableStruct: Encodable {
            enum CodingKeys: String, CodingKey {
                case foo
                case bar
                case baz
                case bat
            }

            let foo = "qwe"
            let bar = "asd"
            let baz = 123
            let bat = 456

            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)

                try container.encode(baz, forKey: .baz)
                try container.encode(bat, forKey: .bat)

                let fooSuperEncoder = container.superEncoder(forKey: .foo)
                let barSuperEncoder = container.superEncoder(forKey: .bar)

                var fooContainer = fooSuperEncoder.container(keyedBy: CodingKeys.self)
                var barContainer = barSuperEncoder.container(keyedBy: CodingKeys.self)

                try fooContainer.encode(foo, forKey: .foo)
                try barContainer.encode(bar, forKey: .bar)
            }
        }

        assertEncoderSucceeds(encoding: EncodableStruct())
    }

    func testThatEncoderSucceedsWhenEncodingStructUsingSuperEncoderOfNestedUnkeyedContainer() {
        struct EncodableStruct: Encodable {
            enum CodingKeys: String, CodingKey {
                case baz
            }

            let foo = "qwe"
            let bar = "asd"
            let baz = 123
            let bat = 456

            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)

                var bazContainer = container.nestedUnkeyedContainer(forKey: .baz)
                var batContainer = bazContainer.nestedUnkeyedContainer()

                try bazContainer.encode(baz)
                try batContainer.encode(bat)

                let bazSuperEncoder = bazContainer.superEncoder()

                var fooContainer = bazSuperEncoder.unkeyedContainer()
                var barContainer = bazSuperEncoder.unkeyedContainer()

                try fooContainer.encode(foo)
                try barContainer.encode(bar)
            }
        }

        assertEncoderSucceeds(encoding: EncodableStruct())
    }

    func testThatEncoderSucceedsWhenEncodingSubclass() {
        class EncodableClass: Encodable {
            let foo = "qwe"
            let bar = "asd"
        }

        class EncodableSubclass: EncodableClass {
            enum CodingKeys: String, CodingKey {
                case baz
                case bat
            }

            let baz = 123
            let bat = 456

            override func encode(to encoder: Encoder) throws {
                try super.encode(to: encoder)

                var container = encoder.container(keyedBy: CodingKeys.self)

                try container.encode(baz, forKey: .baz)
                try container.encode(bat, forKey: .bat)
            }
        }

        assertEncoderSucceeds(encoding: EncodableSubclass())
    }

    // MARK: -

    func testThatEncoderFailsWhenEncodingArray() {
        let value = [1, 2, 3]

        assertEncoderFails(encoding: value) { error in
            switch error {
            case let EncodingError.invalidValue(invalidValue as [Int], _):
                return invalidValue == value

            default:
                return false
            }
        }
    }

    func testThatEncoderFailsWhenEncodingSingleValue() {
        let value = 123

        assertEncoderFails(encoding: value) { error in
            switch error {
            case let EncodingError.invalidValue(invalidValue as Int, _):
                return invalidValue == value

            default:
                return false
            }
        }
    }

    func testThatEncoderFailsWhenEncodingMultipleSingleValuesForKey() {
        struct EncodableStruct: Encodable {
            let foo = 123
            let bar = 456

            func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()

                try container.encode(foo)
                try container.encode(bar)
            }
        }

        let value = EncodableStruct()

        assertEncoderFails(encoding: value) { error in
            switch error {
            case let EncodingError.invalidValue(invalidValue as Int, _):
                return invalidValue == value.bar

            default:
                return false
            }
        }
    }

    func testThatEncoderFailsWhenEncodingWithMultipleSingleValueContainers() {
        struct EncodableStruct: Encodable {
            let foo = 123
            let bar = 456

            func encode(to encoder: Encoder) throws {
                var fooContainer = encoder.singleValueContainer()
                var barContainer = encoder.singleValueContainer()

                try fooContainer.encode(foo)
                try barContainer.encode(bar)
            }
        }

        let value = EncodableStruct()

        assertEncoderFails(encoding: value) { error in
            switch error {
            case let EncodingError.invalidValue(invalidValue as Int, _):
                return invalidValue == value.bar

            default:
                return false
            }
        }
    }

    // MARK: - XCTestCase

    override func setUp() {
        super.setUp()

        encoder = DictionaryEncoder()
    }
}
