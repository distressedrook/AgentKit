# AgentKit

[![Swift](https://img.shields.io/badge/Swift-6.2-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/platform-iOS%2026%20%7C%20macOS%2026-lightgrey.svg)](https://developer.apple.com)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Status](https://img.shields.io/badge/status-0.8.0--beta-yellow.svg)](CHANGELOG.md)

**Swift-native orchestration SDK for building stateful, multi-model AI agents on Apple platforms.**

AgentKit gives you a FoundationModels-style API for building AI agents in Swift. It wraps provider-specific model APIs behind a common session abstraction, keeps a structured transcript of every turn, supports tool calling, typed structured outputs, streaming snapshots, grounding data, token accounting, simulated sessions for tests, and provider adapters for OpenAI and Anthropic.

> Current status: **beta**. The repository currently exposes `v0.8.0-beta`-era APIs and targets Swift 6.2 with iOS 26 / macOS 26.

---

## Why AgentKit?

Most agent frameworks are either backend-first or Python-first. AgentKit is built around a different assumption:

**Native Apple apps should be able to own their agent runtime locally.**

That means:

- Swift-first APIs
- FoundationModels-compatible tool definitions
- Observable session state
- typed structured outputs
- inspectable transcripts
- provider-swappable adapters
- simulation without real API calls
- production-safe proxy authorization instead of shipping API keys in app binaries

AgentKit is useful when you want an iOS or macOS app to coordinate model calls, tools, local context, structured outputs, and UI-visible streaming state without turning your app into a thin shell around a backend agent.

---

## Features

### Provider sessions

AgentKit currently ships provider-specific session products:

- `OpenAISession`
- `AnthropicSession`
- `SimulatedSession`
- shared core target: `AgentKit`

Each real provider session conforms to the same `LanguageModelProvider` surface, so the high-level usage pattern remains consistent across providers.

### FoundationModels-style tools

AgentKit expects tools to be ordinary Swift types that conform to Apple’s `FoundationModels.Tool` protocol. The SDK wraps them internally so model adapters can serialize tool schemas, call tools, and record tool activity in the transcript.

### Session schemas

Use `@SessionSchema` to declare the tools, groundings, and structured outputs available to a session.

A schema can contain:

- `@Tool`
- `@Grounding`
- `@StructuredOutput`

The macro synthesizes the glue needed to register tools, resolve transcripts, and use typed key-path helpers such as `generating: \.weatherReport`.

### Structured outputs

AgentKit supports typed responses through a `StructuredOutput` protocol. Instead of asking the model for “some JSON” and decoding manually, you define the output contract once and ask the session to generate it.

### Streaming snapshots

Streaming APIs return `AsyncThrowingStream` snapshots. Each snapshot can include:

- partial text or structured content
- the current transcript
- token usage updates

The SDK throttles streaming snapshots by default to avoid overwhelming UI updates, while still preserving the freshest state.

### Transcript-first architecture

Every session maintains a structured transcript containing:

- prompts
- reasoning summaries, where available
- tool calls
- tool outputs
- model responses
- text segments
- structured segments
- status information

This makes the agent loop inspectable, debuggable, and UI-friendly.

### Grounding data

AgentKit can attach per-turn grounding data to prompts. Groundings are encoded into the transcript alongside the user input, which helps preserve the distinction between:

- what the user asked
- what the app supplied as context
- what prompt was finally sent to the model

### Token usage tracking

Sessions expose cumulative token usage. Individual responses and streaming snapshots can also surface token accounting when the provider reports it.

### Simulated sessions

The `SimulatedSession` module lets you test agent behavior without calling a real model provider. You can script model generations, tool calls, reasoning, text responses, structured responses, and token usage.

This is useful for:

- unit tests
- UI previews
- demos
- deterministic development workflows
- avoiding API costs while iterating

### Production-safe authorization

Direct API-key configuration exists for prototyping, but the SDK explicitly recommends proxy-based production usage.

The intended production pattern is:

1. Your app asks your backend for a short-lived token.
2. The app runs a single agent turn using `withAuthorization(token:)`.
3. The provider adapter sends requests through your proxy.
4. API keys stay on the backend, not in the app bundle.
5. Optional refresh logic can retry once after a `401 Unauthorized`.

---

## Package structure

```text
AgentKit
├── Sources
│   ├── AgentKit              # Core protocols, transcript, prompting, networking, shared models
│   ├── AgentKitMacros        # @SessionSchema macro implementation
│   ├── OpenAISession         # OpenAI Responses API adapter/session
│   ├── AnthropicSession      # Anthropic Messages API adapter/session
│   ├── SimulatedSession      # Deterministic test/development session
│   └── ExampleCode           # Example/demo code target
├── Tests
│   ├── AgentKitTests
│   └── AgentKitMacroTests
├── Package.swift
├── CHANGELOG.md
├── AGENTS.md
├── CLAUDE.md
├── GEMINI.md
└── LICENSE
```

---

## Requirements

AgentKit currently targets:

- Swift tools version: `6.2`
- Swift language mode: `v6`
- iOS: `26`
- macOS: `26`

Package dependencies include:

- `swift-syntax`
- `MacPaw/OpenAI`
- `SwiftAnthropic`
- `EventSource`
- `modelcontextprotocol/swift-sdk`
- `swift-macro-testing`

---

## Installation

Add AgentKit as a Swift Package dependency:

```swift
.package(url: "https://github.com/distressedrook/AgentKit.git", branch: "main")
```

Then add the product you need to your target.

For OpenAI:

```swift
.product(name: "OpenAISession", package: "AgentKit")
```

For Anthropic:

```swift
.product(name: "AnthropicSession", package: "AgentKit")
```

For simulation-only usage:

```swift
.product(name: "OpenAISession", package: "AgentKit")
```

`SimulatedSession` is currently included as a target inside the provider products.

---

## Quick start: OpenAI

```swift
import FoundationModels
import OpenAISession

struct WeatherTool: Tool {
    let name = "weather"
    let description = "Gets the current weather for a city."

    @Generable
    struct Arguments {
        let city: String
    }

    @Generable
    struct Output {
        let city: String
        let temperature: Double
        let condition: String
    }

    func call(arguments: Arguments) async throws -> Output {
        Output(
            city: arguments.city,
            temperature: 28,
            condition: "Sunny"
        )
    }
}

let session = OpenAISession(
    tools: WeatherTool(),
    instructions: "You are a concise assistant.",
    apiKey: "sk-..."
)

let response = try await session.respond(
    to: "What's the weather in Bengaluru?"
)

print(response.content)
```

For production apps, prefer proxy configuration instead of shipping an API key in the app binary.

---

## Quick start: Anthropic

```swift
import FoundationModels
import AnthropicSession

let session = AnthropicSession(
    tools: WeatherTool(),
    instructions: "You are a concise assistant.",
    apiKey: "sk-ant-..."
)

let response = try await session.respond(
    to: "What's the weather in Bengaluru?"
)

print(response.content)
```

---

## Structured outputs

Define a structured output type:

```swift
import FoundationModels
import AgentKit

struct WeatherReport: StructuredOutput {
    static let name = "weatherReport"

    @Generable
    struct Schema {
        let temperature: Double
        let condition: String
        let humidity: Int
    }
}
```

Generate that output:

```swift
let report = try await session.respond(
    to: "Summarize today's forecast for Lisbon.",
    generating: WeatherReport.self
).content

print(report.condition)
```

---

## Session schemas

Session schemas are the most AgentKit-ish part of the SDK.

They let you declare the full capability surface of a session in one place:

```swift
import FoundationModels
import AgentKit
import OpenAISession

@SessionSchema
struct AppSessionSchema {
    @Tool var weatherTool = WeatherTool()

    @Grounding(Date.self)
    var currentDate

    @StructuredOutput(WeatherReport.self)
    var weatherReport
}

let schema = AppSessionSchema()

let session = OpenAISession(
    schema: schema,
    instructions: "You are a helpful assistant.",
    apiKey: "sk-..."
)

let response = try await session.respond(
    to: "What should I wear today?",
    generating: \.weatherReport
)

print(response.content)
```

The schema gives AgentKit enough information to:

- register tools
- encode groundings
- validate structured outputs
- resolve transcripts into typed records
- expose key-path based structured generation helpers

---

## Prompt builder

AgentKit includes a small prompt composition layer.

You can pass a raw string:

```swift
let response = try await session.respond(
    to: "List three Swift 6 features."
)
```

Or build a structured prompt:

```swift
let prompt = Prompt {
    PromptSection("Instructions") {
        "Be concise."
        "Avoid marketing language."
    }

    PromptTag("user-request") {
        "Explain AgentKit in one paragraph."
    }
}

let response = try await session.respond(to: prompt)
```

The prompt builder is deliberately lightweight. It gives you readable sections and tags without requiring a heavyweight DSL.

---

## Grounding context

Groundings let you attach app-provided context to a turn without pretending it came from the user.

Example:

```swift
@SessionSchema
struct AppSessionSchema {
    @Grounding(Date.self)
    var currentDate

    @StructuredOutput(WeatherReport.self)
    var weatherReport
}

let response = try await session.respond(
    to: "What should I wear today?",
    generating: \.weatherReport,
    groundingWith: [.currentDate(Date())]
) { input, sources in
    PromptTag("context") {
        for source in sources {
            if case let .currentDate(date) = source {
                "Today is \(date)."
            }
        }
    }

    PromptTag("user-query") {
        input
    }
}
```

This keeps your transcript semantically cleaner:

- `input` remains the user’s original request
- `sources` holds app-provided grounding data
- `prompt` stores the final rendered prompt sent to the model

---

## Streaming responses

Text streaming:

```swift
let stream = try session.streamResponse(
    to: "Explain actor isolation in Swift."
)

for try await snapshot in stream {
    if let text = snapshot.content {
        print(text)
    }

    print(snapshot.transcript)
}
```

Structured streaming:

```swift
let stream = try session.streamResponse(
    to: "Extract the weather forecast.",
    generating: WeatherReport.self
)

for try await snapshot in stream {
    if let partial = snapshot.content {
        print(partial)
    }
}
```

Streaming snapshots are useful for UI because they carry the latest content and transcript state together.

---

## Transcript model

AgentKit’s transcript is an ordered collection of entries:

```swift
public enum Transcript.Entry {
    case prompt(Prompt)
    case reasoning(Reasoning)
    case toolCalls(ToolCalls)
    case toolOutput(ToolOutput)
    case response(Response)
}
```

This lets you build UI around the actual execution path of the agent, not just the final message.

A transcript can show:

- what prompt was sent
- which tool calls were requested
- what arguments the model supplied
- what outputs the tools returned
- what response segments were produced
- whether steps are in progress, completed, or incomplete

You can also clear the transcript:

```swift
await session.clearTranscript()
```

And reset token usage:

```swift
await session.resetTokenUsage()
```

---

## Tool rejections

Tools can reject a run in a recoverable way using `ToolRunRejection`.

This is useful when the tool can explain why it refused the call and give the model enough structure to recover instead of crashing the entire turn.

Example use cases:

- missing customer
- invalid ID
- permission denied
- ambiguous tool arguments
- unsupported operation

Conceptually:

```swift
throw ToolRunRejection(
    reason: "Customer not found",
    content: CustomerLookupRejectionDetails(
        issue: "customerNotFound",
        customerId: arguments.customerId,
        suggestions: [
            "Ask the user to confirm the customer identifier."
        ]
    )
)
```

---

## Token usage

Sessions track cumulative token usage:

```swift
print(session.tokenUsage.totalTokens ?? 0)
print(session.tokenUsage.inputTokens ?? 0)
print(session.tokenUsage.outputTokens ?? 0)
```

Responses can also carry per-response token usage:

```swift
let response = try await session.respond(to: "Summarize this.")

if let usage = response.tokenUsage {
    print(usage.totalTokens ?? 0)
}
```

This is especially useful in native apps where token cost should be visible, budgeted, or debugged.

---

## Production auth: proxy mode

Direct configuration is convenient:

```swift
let session = OpenAISession(
    instructions: "You are helpful.",
    apiKey: "sk-..."
)
```

But for production apps, do not ship API keys in the app bundle.

Use proxy configuration:

```swift
let configuration = OpenAIConfiguration.proxy(
    through: URL(string: "https://api.example.com/openai")!
)

let session = OpenAISession(
    schema: schema,
    instructions: "You are helpful.",
    configuration: configuration
)

let token = try await backend.issueTurnToken(for: userId)

let response = try await session.withAuthorization(token: token) {
    try await session.respond(to: "Draft a status update.")
}
```

You can also provide a refresh closure:

```swift
let response = try await session.withAuthorization(
    token: initialToken,
    refresh: {
        try await backend.refreshTurnToken(for: userId)
    }
) {
    try await session.respond(to: "Plan a weekend trip.")
}
```

The same pattern exists for Anthropic via `AnthropicConfiguration.proxy(through:)`.

---

## OpenAI generation options

`OpenAIGenerationOptions` exposes provider-specific controls such as:

- `include`
- `maxOutputTokens`
- `allowParallelToolCalls`
- `reasoning`
- `safetyIdentifier`
- `serviceTier`
- `temperature`
- `toolChoice`
- `topLogProbs`
- `topP`
- `truncation`
- `minimumStreamingSnapshotInterval`

Example:

```swift
import OpenAISession

let options = OpenAIGenerationOptions(
    maxOutputTokens: 1_000,
    temperature: 0.2,
    topP: 0.9
)

let response = try await session.respond(
    to: "Summarize this document.",
    options: options
)
```

Reasoning models automatically include encrypted reasoning content when required by the model configuration.

---

## Anthropic generation options

`AnthropicGenerationOptions` exposes Anthropic-specific controls such as:

- `maxOutputTokens`
- `stopSequences`
- `temperature`
- `topP`
- `topK`
- `toolChoice`
- `thinking`
- `minimumStreamingSnapshotInterval`

Example:

```swift
import AnthropicSession

let options = AnthropicGenerationOptions(
    maxOutputTokens: 1_024,
    temperature: 0.3
)

let response = try await session.respond(
    to: "Explain this code.",
    options: options
)
```

The Anthropic adapter validates common incompatible combinations, especially around extended thinking.

---

## Simulated sessions

Use `SimulatedSession` when you want deterministic agent behavior without calling a real provider.

```swift
import FoundationModels
import SimulatedSession

let configuration = SimulationConfiguration(
    defaultGenerations: [
        .response(text: "Hello from a simulated model.")
    ]
)

let session = SimulatedSession(
    tools: WeatherTool(),
    instructions: "You are a test assistant.",
    configuration: configuration
)

let response = try await session.respond(to: "Say hello.")
print(response.content)
```

Simulation is designed to mirror the normal session API, which means tests can exercise the same `respond` and `streamResponse` flows your production code uses.

---

## Testing

Run the test suite with Swift Package Manager:

```bash
swift test
```

The repository also documents Xcode-based commands.

Build tests:

```bash
xcodebuild -workspace AgentKit.xcworkspace \
  -scheme AgentKitTests \
  build \
  -quiet
```

Run tests:

```bash
xcodebuild -workspace AgentKit.xcworkspace \
  -scheme AgentKitTests \
  -testPlan AgentKitTests \
  test \
  -quiet
```

Macro tests live under `AgentKitMacroTests`.

---

## HTTP fixture recording

The changelog references an `HTTPReplayRecorder`, HTTP interceptors, and an `AgentRecorder` CLI for capturing request/response payloads and printing paste-ready Swift fixtures.

The documented secrets inputs are:

- `OPENAI_API_KEY`
- `ANTHROPIC_API_KEY`
- `AGENT_RECORDER_SECRETS_PLIST`

Example workflow:

```bash
xcodebuild -workspace AgentKit.xcworkspace \
  -scheme AgentRecorder \
  -destination "platform=macOS,arch=arm64" \
  -derivedDataPath .tmp/DerivedData \
  build \
  -quiet

./.tmp/DerivedData/Build/Products/Debug/AgentRecorder --list-scenarios
```

---

## Current API overview

### Core protocols and types

| Type                       | Purpose                                                                     |
| -------------------------- | --------------------------------------------------------------------------- |
| `LanguageModelProvider`    | Common session interface for provider-backed and simulated sessions         |
| `Adapter`                  | Provider adapter abstraction                                                |
| `AdapterGenerationOptions` | Provider-specific generation options contract                               |
| `Transcript`               | Structured record of prompts, reasoning, tool calls, outputs, and responses |
| `AgentResponse`            | Final response object returned by `respond`                                 |
| `AgentSnapshot`            | Incremental response object emitted by streaming                            |
| `TokenUsage`               | Token accounting model                                                      |
| `StructuredOutput`         | Typed output declaration                                                    |
| `ToolRunRejection`         | Recoverable tool failure mechanism                                          |
| `Prompt`                   | Lightweight prompt composition model                                        |
| `@SessionSchema`           | Macro for declaring session tools, groundings, and structured outputs       |

### Provider modules

| Module             | Purpose                                 |
| ------------------ | --------------------------------------- |
| `OpenAISession`    | OpenAI Responses API integration        |
| `AnthropicSession` | Anthropic Messages API integration      |
| `SimulatedSession` | Deterministic local simulation provider |

---

## Version notes

### 0.8.0

Highlights from the current changelog:

- tool schema JSON export
- generation error codes
- Anthropic adapter support
- Anthropic playground/example support
- HTTP fixture recorder
- AgentRecorder CLI
- `SessionSchema.decodableTools` renamed to `SessionSchema.tools`
- stable generated-content JSON
- normalized cancellation handling

### 0.7.0

Major changes:

- `OpenAISession` replaced the previous `ModelSession.openAI(...)` factory
- tools now conform directly to FoundationModels `Tool`
- guided generations require `StructuredOutput`
- `@SessionSchema` superseded earlier prompt context / tool resolver helpers
- simulation workflow moved to `SimulatedSession`

---

## Design philosophy

AgentKit’s design leans toward:

- **native-first orchestration** instead of backend-only agents
- **typed capability declarations** instead of stringly-typed tool registries
- **transcript visibility** instead of opaque “agent magic”
- **provider-specific options** instead of lowest-common-denominator config
- **simulation-first testing** instead of live-provider-only development
- **secure production deployment** through backend proxy tokens

The SDK is trying to make agentic workflows feel like normal Swift application architecture.

---

## What AgentKit is not

AgentKit is not currently:

- a full LangChain clone
- a no-code workflow builder
- a backend agent server
- a vector database
- a memory database
- a complete hosted agent platform
- a replacement for your backend security layer
- a stable 1.0 API

It is better understood as a Swift-native runtime layer for model sessions, tool orchestration, transcript management, structured generation, and provider integration.

---

## Security notes

Do not embed provider API keys in production iOS or macOS apps.

Use:

```swift
OpenAIConfiguration.proxy(through:)
```

or:

```swift
AnthropicConfiguration.proxy(through:)
```

with:

```swift
session.withAuthorization(token:) {
    try await session.respond(to: "...")
}
```

Direct API-key constructors are best treated as local development / prototype conveniences.

---

## License

AgentKit is released under the MIT License.

Copyright © 2025 Avismara Hugoppalu.
