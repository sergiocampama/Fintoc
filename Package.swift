// swift-tools-version:5.4

import PackageDescription

#if swift(>=5.5)
let additionalTargets = [
    Target.executableTarget(
        name: "ft",
        dependencies: [
            "APIBuilder",
            "Fintoc",
            .product("KeychainAccess", "KeychainAccess", .when(platforms: [.macOS])),
            .product("swift-argument-parser", "ArgumentParser"),
        ]
    ),
]
let additionalProducts = [Product.executable(name: "ft", targets: ["ft"])]
let additionalDependencies: [Package.Dependency] = [
    .package(url: "https://github.com/apple/swift-argument-parser", .branch("async")),
    .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", from: "4.2.2"),
]
#else
let additionalTargets = [Target]()
let additionalProducts = [Product]()
let additionalDependencies = [Package.Dependency]()
#endif


let package = Package(
    name: "Fintoc",
    platforms: [.macOS("11.0")],
    products: [
        .library(name: "APIBuilder", targets: ["APIBuilder"]),
        .library(name: "Fintoc", targets: ["Fintoc"]),
    ] + additionalProducts,
    dependencies: [
        .package(url: "https://github.com/sergiocampama/WebLinking", .branch("main")),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.30.0"),
    ] + additionalDependencies,
    targets: [
        .target(name: "Fintoc", dependencies: ["APIBuilder"]),
        .target(
            name: "APIBuilder",
            dependencies: [
                .product("WebLinking", "WebLinking"),
                .product("swift-nio", "NIO"),
            ]
        ),

        .target(name: "TestHelpers", dependencies: ["APIBuilder"]),
        .testTarget(name: "APIBuilderTests", dependencies: ["APIBuilder", "TestHelpers"]),
        .testTarget(name: "FintocTests", dependencies: ["Fintoc", "TestHelpers"]),
    ] + additionalTargets
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
