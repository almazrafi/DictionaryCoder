// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "DictionaryCoder",
    products: [
        .library(
            name: "DictionaryCoder",
            targets: ["DictionaryCoder"]
        )
    ],
    targets: [
        .target(
            name: "DictionaryCoder",
            path: "Sources"
        ),
        .testTarget(
            name: "DictionaryCoderTests",
            dependencies: ["DictionaryCoder"],
            path: "Tests"
        )
    ],
    swiftLanguageVersions: [.v5]
)
