// swift-tools-version: 6.4
import CompilerPluginSupport
import PackageDescription

// SiteKit is copied from https://github.com/sindresorhus/sindresorhus.github.com (MIT, see Sources/SiteKit/LICENSE-SiteKit), so it keeps its settings.
let swiftSettings: [SwiftSetting] = [
	.treatAllWarnings(as: .error),
	.enableUpcomingFeature("ExistentialAny"),
	.enableUpcomingFeature("MemberImportVisibility"),
	.enableUpcomingFeature("NonisolatedNonsendingByDefault"),
	.enableUpcomingFeature("InferIsolatedConformances"),
]

let package = Package(
	name: "Portfolio",
	platforms: [
		.macOS(.v26),
	],
	dependencies: [
		.package(url: "https://github.com/elementary-swift/elementary.git", exact: "0.8.2"),
		.package(url: "https://github.com/sindresorhus/swift-markdown.git", branch: "sindre-improvements"),
		.package(url: "https://github.com/soml-lang/SOMLSwift.git", revision: "23fe09312afc845b8a369c46bf9beaf5b46908f2"),
		.package(url: "https://github.com/swiftlang/swift-syntax.git", "600.0.0"..<"605.0.0"),
	],
	targets: [
		.macro(
			name: "SiteKitMacros",
			dependencies: [
				.product(name: "SwiftSyntax", package: "swift-syntax"),
				.product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
				.product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
				.product(name: "SwiftDiagnostics", package: "swift-syntax"),
				.product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
			],
			swiftSettings: swiftSettings
		),
		.target(
			name: "SiteKit",
			dependencies: [
				"SiteKitMacros",
				.product(name: "Elementary", package: "elementary"),
				.product(name: "Markdown", package: "swift-markdown"),
				.product(name: "SOML", package: "SOMLSwift"),
				.product(name: "SwiftParser", package: "swift-syntax"),
				.product(name: "SwiftIDEUtils", package: "swift-syntax"),
			],
			exclude: ["LICENSE-SiteKit"],
			swiftSettings: swiftSettings
		),
		.executableTarget(
			name: "Portfolio",
			dependencies: [
				"SiteKit",
				.product(name: "Elementary", package: "elementary"),
			],
			swiftSettings: swiftSettings
		),
	]
)
