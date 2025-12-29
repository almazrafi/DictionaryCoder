// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "DictionaryCoder",
    platforms: [
        .macOS(.v12),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "DictionaryCoder",
            targets: ["DictionaryCoder"]
        ),
        .library(
            name: "DictionaryCoderDynamic",
            type: .dynamic,
            targets: ["DictionaryCoder"]
        )
    ],
    targets: [
        .target(
            name: "DictionaryCoder",
            path: "Sources",
            exclude: ["Info.plist"]
        ),
        .testTarget(
            name: "DictionaryCoderTests",
            dependencies: ["DictionaryCoder"],
            path: "Tests",
            exclude: ["Info.plist"]
        )
    ],
    swiftLanguageVersions: [.v5]
)
