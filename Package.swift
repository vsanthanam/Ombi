// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Ombi",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .tvOS(.v14),
        .watchOS(.v7)
    ],
    products: [
        .library(
            name: "Ombi",
            targets: ["Ombi"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/mattgallagher/CwlPreconditionTesting.git", from: Version("2.0.0"))
    ],
    targets: [
        .target(
            name: "Ombi",
            dependencies: []
        ),
        .testTarget(
            name: "OmbiTests",
            dependencies: ["Ombi", "CwlPreconditionTesting"]
        ),
    ]
)
