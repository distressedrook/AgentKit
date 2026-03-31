// By Avismara Hugoppalu

import Foundation
import Testing
@testable import AgentKit

struct AgentKitTests {

  @Test func testFullPipeline() async throws {
    // 1. Initialize the kit (connects to local MCP server)
    try await AgentKitSDK.initialize()

    // 2. Create the agent
    let agent = DefaultAgent()

    // 3. Execute a prompt that triggers the 'prompt_model' tool
    let prompt = "Use prompt_model to say hello"
    let response = try await agent.execute(prompt: prompt)

    print("Pipeline Response: \(response)")

    #expect(response.contains("Tool Result:"))
  }

}
