// swift-tools-version: 6.2

import CompilerPluginSupport
import PackageDescription

let package = Package(
  name: "AgentKit",
  platforms: [
    .iOS(.v26),
    .macOS(.v26),
  ],
  products: [
    .library(name: "OpenAISession", targets: ["OpenAISession", "SimulatedSession", "AgentKit"]),
    .library(name: "AnthropicSession", targets: ["AnthropicSession", "SimulatedSession", "AgentKit"]),
    .library(name: "ExampleCode", targets: ["ExampleCode"]),
  ],
  dependencies: [
    .package(url: "https://github.com/swiftlang/swift-syntax.git", "600.0.0"..<"603.0.0"),
    .package(url: "https://github.com/MacPaw/OpenAI.git", branch: "main"),
    .package(url: "https://github.com/jamesrochabrun/SwiftAnthropic.git", from: "2.2.0"),
    .package(url: "https://github.com/mattt/EventSource", from: "1.2.0"),
    .package(url: "https://github.com/modelcontextprotocol/swift-sdk.git", from: "0.12.1"),
    .package(url: "https://github.com/pointfreeco/swift-macro-testing", from: "0.6.4"),
  ],
  targets: [
    .macro(
      name: "AgentKitMacros",
      dependencies: [
        .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
        .product(name: "SwiftDiagnostics", package: "swift-syntax"),
        .product(name: "SwiftSyntax", package: "swift-syntax"),
        .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
        .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
      ],
    ),
    .target(
      name: "AgentKit",
      dependencies: [
        "AgentKitMacros",
        "EventSource",
        .product(name: "MCP", package: "swift-sdk"),
      ],
      exclude: ["mcp-lms-server"],
    ),
    .target(
      name: "OpenAISession",
      dependencies: [
        "AgentKit",
        "OpenAI",
        "AgentKitMacros",
        "EventSource",
      ],
    ),
    .target(
      name: "AnthropicSession",
      dependencies: [
        "AgentKit",
        "SwiftAnthropic",
        "AgentKitMacros",
        "EventSource",
      ],
    ),
    .target(
      name: "SimulatedSession",
      dependencies: [
        "AgentKit",
        "OpenAI",
      ],
    ),
    .target(
      name: "ExampleCode",
      dependencies: [
        "AgentKit",
        "AnthropicSession",
        "OpenAISession",
        "SimulatedSession",
        .product(name: "SwiftAnthropic", package: "SwiftAnthropic"),
      ],
    ),
    .testTarget(
      name: "AgentKitTests",
      dependencies: [
        "AnthropicSession",
        "OpenAISession",
        "AgentKit",
        "SimulatedSession",
        .product(name: "SwiftAnthropic", package: "SwiftAnthropic"),
      ],
    ),
    .testTarget(
      name: "AgentKitMacroTests",
      dependencies: [
        "AgentKitMacros",
        .product(name: "MacroTesting", package: "swift-macro-testing"),
        .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
      ],
    ),
  ],
  swiftLanguageModes: [.v6],
)
