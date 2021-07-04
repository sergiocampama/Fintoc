// swift-tools-version:5.4

import PackageDescription

let package = Package(
    name: "Fintoc",
    products: [
        .executable(name: "ft", targets: ["ft"]),
        .library(name: "Fintoc", targets: ["Fintoc"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.1"),
        .package(url: "https://github.com/kishikawakatsumi/KeychainAccess", from: "4.2.2"),
    ],
    targets: [
        .executableTarget(
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
