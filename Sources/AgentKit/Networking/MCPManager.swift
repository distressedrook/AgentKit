// By Avismara Hugoppalu

import Foundation
import System
import MCP
import Logging

actor MCPManager {
  static let shared = MCPManager()

  private var client: Client?
  private var process: Process?

  private init() {}

  func connectToLocalMCP() async throws {
    // Note: In a production app, the binary would be bundled as a resource.
    // For this development environment, we use the path in the Sources directory.
    let binaryPath = "/Users/avismara/Development/AgentKit/Sources/AgentKit/mcp-lms-server"

    guard FileManager.default.fileExists(atPath: binaryPath) else {
      throw NSError(
        domain: "AgentKit",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "MCP server binary not found at \(binaryPath)"]
      )
    }

    let process = Process()
    process.executableURL = URL(fileURLWithPath: binaryPath)

    let inputPipe = Pipe()
    let outputPipe = Pipe()

    process.standardInput = inputPipe
    process.standardOutput = outputPipe

    try process.run()
    self.process = process

    let transport = StdioTransport(
      input: FileDescriptor(rawValue: outputPipe.fileHandleForReading.fileDescriptor),
      output: FileDescriptor(rawValue: inputPipe.fileHandleForWriting.fileDescriptor)
    )

    let client = Client(name: "AgentKit-SDK", version: "1.0.0")
    let result = try await client.connect(transport: transport)
    self.client = client
    Logger(label: "System").log(
      level: .info,
      "Successfully connected to MCP server: \(result.serverInfo.name) (\(result.serverInfo.version))"
    )
  }

  func listTools() async throws -> [Tool] {
    guard let client = client else {
      throw NSError(
        domain: "AgentKit",
        code: 2,
        userInfo: [NSLocalizedDescriptionKey: "Client not connected"]
      )
    }
    let (tools, _) = try await client.listTools()
    return tools
  }

  func callTool(name: String, arguments: [String: Value]? = nil) async throws -> (
    content: [Tool.Content], isError: Bool?
  ) {
    guard let client = client else {
      throw NSError(
        domain: "AgentKit",
        code: 2,
        userInfo: [NSLocalizedDescriptionKey: "Client not connected"]
      )
    }
    return try await client.callTool(name: name, arguments: arguments)
  }

  func getClient() -> Client? {
    return client
  }

  func disconnect() async {
    client = nil
    if let process = process, process.isRunning {
      process.terminate()
    }
    process = nil
  }
}
