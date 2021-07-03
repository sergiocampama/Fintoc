// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FintocSwift",
    products: [
        .executable(name: "ft", targets: ["ft"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.1"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", from: "4.2.2"),
    ],
    targets: [
        .target(
            name: "ft",
            dependencies: [
                "APIBuilder",
                "Fintoc",
                "KeychainAccess",
                .product("swift-argument-parser", "ArgumentParser"),
            ]
        ),
        .target(name: "Fintoc", dependencies: ["APIBuilder"]),
        .target(name: "APIBuilder"),

        .target(name: "TestHelpers"),
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
