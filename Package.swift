// swift-tools-version:5.4

import PackageDescription

#if os(Linux)
let weblinkingDependency = Target.Dependency.product("WebLinking", "WebLinking")
#else
let weblinkingDependency = Target.Dependency.product("WebLinking.swift", "WebLinking")
#endif

let package = Package(
    name: "Fintoc",
    platforms: [.macOS("12.0")],
    products: [
        .executable(name: "ft", targets: ["ft"]),
        .library(name: "Fintoc", targets: ["Fintoc"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", .branch("async")),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", from: "4.2.2"),
        .package(url: "https://github.com/andlister/WebLinking.swift", .branch("master")),
    ],
    targets: [
        .executableTarget(
            name: "ft",
            dependencies: [
                "APIBuilder",
                "Fintoc",
                .product("KeychainAccess", "KeychainAccess", .when(platforms: [.macOS])),
                .product("swift-argument-parser", "ArgumentParser"),
            ]
        ),
        .target(name: "Fintoc", dependencies: ["APIBuilder"]),
        .target(name: "APIBuilder", dependencies: [weblinkingDependency]),

        .target(name: "TestHelpers", dependencies: ["APIBuilder"]),
        .testTarget(name: "APIBuilderTests", dependencies: ["APIBuilder", "TestHelpers"]),
        .testTarget(name: "FintocTests", dependencies: ["Fintoc", "TestHelpers"]),
    ]
)


extension Target.Dependency {
    static func product(
        _ package: String,
        _ name: String,
        _ condition: TargetDependencyCondition? = nil
    ) -> Self {
        .product(name: name, package: package, condition: condition)
    }
}
