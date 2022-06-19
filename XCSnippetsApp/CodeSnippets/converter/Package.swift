// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "converter",
    dependencies: [
        .package(url: "https://github.com/MarcoEidinger/XCSnippets", from: "1.1.0"),
    ],
    targets: [
        .executableTarget(
            name: "converter",
            dependencies: ["XCSnippets"]
        ),
    ]
)
