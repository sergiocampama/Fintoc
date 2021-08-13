// swift-tools-version:5.4

import PackageDescription

#if swift(>=5.5)
let minMacOS = "12.0"
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
let minMacOS = "11.0"
let additionalTargets = [Target]()
let additionalProducts = [Product]()
let additionalDependencies = [Package.Dependency]()
#endif

let package = Package(
    name: "Fintoc",
    platforms: [.macOS(minMacOS)],
    products: [
        .library(name: "Fintoc", targets: ["Fintoc"]),
    ] + additionalProducts,
    dependencies: [
        .package(url: "https://github.com/sergiocampama/APIBuilder", .branch("main")),
    ] + additionalDependencies,
    targets: [
        .target(name: "Fintoc", dependencies: [.product("APIBuilder", "APIBuilder")]),
        .testTarget(
            name: "FintocTests",
            dependencies: [
                "Fintoc",
                .product("APIBuilder", "APIBuilder"),
                .product("APIBuilder", "APIBuilderTestHelpers")
            ]
        ),
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
