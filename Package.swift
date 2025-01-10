// swift-tools-version:6.0
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
            path: "Sources",
            swiftSettings: [
                .enableUpcomingFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "DictionaryCoderTests",
            dependencies: ["DictionaryCoder"],
            path: "Tests"
        )
    ],
    swiftLanguageVersions: [.v6]
)
