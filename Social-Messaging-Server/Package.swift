// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "Social-Messaging-Server",
    platforms: [
       .macOS(.v10_15)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/jwt-kit.git", from: "4.0.0-rc.1"),
        .package(url: "https://github.com/vapor/fluent-mongo-driver.git", from: "1.0.0"),
//        .package(name: "Markdown", url: "https://github.com/vudat81299/Markdown.git", from: "0.5.0"), // .md
//        .package(name: "SwiftMarkdown", url: "https://github.com/vapor-community/markdown.git", from: "0.6.1"),
//        .package(name: "LeafMarkdown", url: "https://github.com/vapor-community/leaf-markdown.git", .upToNextMajor(from: "3.0.0")),
        .package(url: "https://github.com/autimatisering/VaporSMTPKit.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "Leaf", package: "leaf"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "JWTKit", package: "jwt-kit"),
                .product(name: "FluentMongoDriver", package: "fluent-mongo-driver"),
//                .product(name: "Markdown", package: "Markdown"),
//                .product(name: "SwiftMarkdown", package: "SwiftMarkdown"),
//                .product(name: "LeafMarkdown", package: "LeafMarkdown"),
                .product(name: "VaporSMTPKit", package: "VaporSMTPKit"),
            ],
            swiftSettings: [
                // Enable better optimizations when building in Release configuration. Despite the use of
                // the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
                // builds. See <https://github.com/swift-server/guides#building-for-production> for details.
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]
        ),
        .target(name: "Run", dependencies: [.target(name: "App")]),
        .target(name: "TestSwiftPM", dependencies: []),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
