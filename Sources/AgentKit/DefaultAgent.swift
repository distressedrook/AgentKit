// By Avismara Hugoppalu

import Foundation
import MCP
import OSLog

public protocol Agent {
  func execute(prompt: String) async throws -> String
}

public struct DefaultAgent: Agent {
  public init() {}

  public func execute(prompt: String) async throws -> String {
    let cleanPrompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
    if cleanPrompt.isEmpty {
      throw NSError(domain: "AgentKit", code: 3, userInfo: [NSLocalizedDescriptionKey: "Empty prompt"])
    }

    // 1. Tool Discovery
    let tools = try await AgentKitSDK.mcp.listTools()

    // 2. Simple Routing Logic
    for tool in tools {
      if cleanPrompt.lowercased().contains(tool.name.lowercased()) {
        os_log(.info, "Routing to MCP tool: %{public}s", tool.name)

        // 3. Prepare Arguments
        let arguments: [String: Value] = ["prompt": .string(cleanPrompt)]

        // 4. Tool Execution
        let (content, isError) = try await AgentKitSDK.mcp.callTool(name: tool.name, arguments: arguments)

        // 5. Result Formatting
        var response = isError == true ? "Tool Error:\n" : "Tool Result:\n"
        for item in content {
          switch item {
          case let .text(text, _, _):
            response += text + "\n"
          case let .resource(resource, _, _):
            response += "[Resource: \(resource.uri)]\n"
          case let .image(data, mimeType, _, _):
            response += "[Image: \(mimeType) (\(data.count) bytes)]\n"
          case let .audio(data, mimeType, _, _):
            response += "[Audio: \(mimeType) (\(data.count) bytes)]\n"
          case let .resourceLink(uri, name, _, _, _, _):
            response += "[Link: \(name)]\n"
          @unknown default:
            response += "[Unknown content type]\n"
          }
        }
        return response
      }
    }

    return "I processed '\(cleanPrompt)' but no matching tool was found."
  }
}
