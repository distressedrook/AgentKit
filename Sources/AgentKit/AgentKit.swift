// By Avismara Hugoppalu

import Foundation

public struct AgentKitSDK {
  public static let version = "0.8.0"
  static let mcp = MCPManager.shared

  public static func initialize() async throws {
    try await mcp.connectToLocalMCP()
  }

  public static func shutdown() async {
    await mcp.disconnect()
  }
}
