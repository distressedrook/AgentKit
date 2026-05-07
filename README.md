# AgentKit

**Native Swift SDK for building stateful, tool-using, agentic applications on Apple platforms.**

AgentKit is a powerful orchestration runtime designed for the modern AI-native era. Inspired by Apple's `FoundationModels` design philosophy, it provides a clean, declarative API for building autonomous agents that can use tools, maintain state, and interact with multiple model providers (OpenAI, Anthropic) seamlessly on macOS and iOS.

---

## Key Features

- **Stateful Transcripts**: A thread-safe, `Codable` conversation log that tracks prompts, reasoning, tool calls, and responses.
- **Multi-Provider Support**: Unified interface for OpenAI and Anthropic, including support for streaming and "thinking" (reasoning) models.
- **Swift Macros**: Reduce boilerplate with `@SessionSchema`, `@Tool`, and `@StructuredOutput` macros that handle type-safe extraction and synthesis.
- **MCP Integration**: Built-in support for the **Model Context Protocol**, allowing agents to discover and use any MCP-compliant tools or data sources.
- **Structured Output**: Enforce strict JSON schemas and receive decoded Swift types directly from the model.
- **Simulated Sessions**: Deterministic testing with `SimulatedSession`, allowing you to script agent turns without API costs.
- **Observability**: Built-in HTTP recording and playback for creating robust test fixtures.

---

## Installation

Add AgentKit to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/avismara/AgentKit", from: "0.8.0-beta")
]
```

---

## Quick Start

### 1. Define your Session Schema

Use macros to define the capabilities of your agent:

```swift
@SessionSchema
struct MyAgentSchema {
    @Tool var weatherTool = WeatherTool()
    @Grounding(Date.self) var currentDate
}
```

### 2. Initialize a Session

```swift
let session = OpenAISession(
    schema: MyAgentSchema(),
    instructions: "You are a helpful weather assistant.",
    apiKey: "sk-..."
)
```

### 3. Respond to User Input

```swift
let response = try await session.respond(to: "What's the weather in San Francisco?")
print(response.content)
```

---

## Advanced Usage

### Streaming with Structured Output

AgentKit supports real-time streaming of both text and structured data:

```swift
let stream = try session.streamResponse(
    to: "Summarize the weather in SF",
    generating: \.weatherReport
)

for try await snapshot in stream {
    if let report = snapshot.content {
        print("Temperature: \(report.temperature)")
    }
}
```

### Defining Tools

Tools are strongly typed and easy to define:

```swift
struct WeatherTool: Tool {
    let name = "get_weather"
    let description = "Get current weather for a location"

    @Generable
    struct Arguments {
        let city: String
    }

    func call(arguments: Arguments) async throws -> WeatherReport {
        // Implementation logic
    }
}
```

---

## Architectural Overview

AgentKit is built on a high-performance, actor-based architecture:

- **`Transcript`**: The central source of truth for the conversation state.
- **`Adapter`**: Pluggable providers that map AgentKit's internal state to model-specific APIs.
- **`MCPManager`**: Orchestrates local and remote tool discovery via the Model Context Protocol.
- **`SessionSchema`**: A macro-synthesized registry that provides type-safe access to tools and grounding data.

---

## Development

- **Build**: `swift build`
- **Test**: `swift test`
- **Recording Fixtures**: Use the `AgentRecorder` CLI to capture real model interactions for unit tests.

---

## License

AgentKit is released under the MIT License. See [LICENSE](LICENSE) for details.

*Created by Avismara Hugoppalu*
