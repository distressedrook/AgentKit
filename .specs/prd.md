AgentKit is a Swift-native open-source SDK for building stateful, tool-using, agentic applications on Apple platforms.

It provides the orchestration runtime required for modern AI-native applications: context assembly, memory management, workflow execution, skill loading, tool orchestration, MCP integration, and multi-model coordination.

Unlike simple LLM wrappers or chatbot SDKs, AgentKit treats AI systems as long-running, stateful workflows rather than single inference calls. The SDK enables developers to build agents that can dynamically retrieve context, load capabilities, execute deterministic tools, maintain execution state, and coordinate multi-step tasks across local and remote systems.

AgentKit is designed specifically for native Apple development using Swift and Swift Concurrency. It prioritizes strongly typed APIs, modular architecture, low-latency execution, and deep operating system integration. The framework aims to provide foundational infrastructure for AI-native iOS and macOS applications, similar to how networking, persistence, and UI frameworks support modern app development today.

Core architectural areas include:

* Agent runtime and execution loops
* Dynamic context construction and token budgeting
* Skill-based capability injection
* Deterministic tool execution
* MCP (Model Context Protocol) integration
* Memory and retrieval systems
* Workflow orchestration and planning
* Multi-model provider abstraction
* Native OS integrations
* Observability and debugging infrastructure

AgentKit is infrastructure-focused rather than assistant-focused. Its purpose is not to provide a single AI product, but to provide reusable primitives and runtime systems that developers can use to build reliable, scalable, AI-native software on Apple platforms.

# AgentKit — Feature List

## 1. Core Agent Runtime

* Agent execution loop
* Multi-step reasoning orchestration
* Tool call handling
* Nested/sub-agent support
* Parallel execution
* Streaming responses
* Retry handling
* Cancellation support
* Timeout management
* Event-driven execution
* Background task execution
* Agent lifecycle hooks

---

## 2. Context Engine

* Dynamic context assembly
* Token budgeting
* Context prioritization
* Automatic summarization
* Sliding-window history management
* Context compression
* Retrieval injection
* Skill injection
* System prompt layering
* Structured context blocks
* Prompt templating
* Context observability/debugging

---

## 3. Skill System

* Dynamic skill loading
* Lazy skill injection
* Skill discovery
* Skill dependencies
* Skill versioning
* Skill manifests
* Skill metadata
* Scoped skills
* Skill composition
* Local skill registry
* Remote skill registry
* Skill enable/disable controls

---

## 4. Tool System

* Typed tools
* Async tool execution
* Streaming tools
* Tool validation
* Function-calling integration
* Permissioned tools
* Tool sandboxing
* Tool retries
* Tool timeout policies
* Tool execution logging
* Parallel tool execution
* Human approval hooks
* Tool result caching

---

## 5. MCP Integration

* MCP client runtime
* MCP server runtime
* Tool discovery
* Capability negotiation
* Authentication handling
* Local MCP server support
* Remote MCP server support
* Streaming MCP transport
* Connection pooling
* Permission mediation
* Typed MCP wrappers
* MCP debugging tools

---

## 6. Memory System

* Conversation memory
* Semantic memory
* Episodic memory
* Workflow state memory
* Vector memory support
* Memory retrieval
* Memory ranking
* Memory expiration policies
* Memory summarization
* Memory pruning
* Shared memory
* Cross-agent memory
* Persistent storage adapters
* Memory snapshots

---

## 7. Retrieval / RAG

* Embedding provider abstraction
* Local embedding support
* Vector DB integration
* Hybrid search
* Semantic ranking
* Metadata filtering
* Chunking pipelines
* Incremental indexing
* Retrieval compression
* Query rewriting
* Multi-source retrieval
* Retrieval observability
* Citation support

---

## 8. Workflow Engine

* Multi-step workflows
* DAG-based execution
* Branching logic
* Conditional execution
* Retry policies
* Human approval checkpoints
* Workflow checkpoints
* Pause/resume workflows
* Long-running task support
* Scheduled workflows
* Event-driven workflows
* Rollback support
* Workflow persistence
* Workflow visualization

---

## 9. Routing & Planning

* Intent classification
* Skill routing
* Tool routing
* Model routing
* Hierarchical planning
* Multi-agent delegation
* Planner models
* Deterministic routing rules
* Hybrid routing systems
* Cost-aware routing
* Latency-aware routing

---

## 10. Model Layer

* OpenAI adapter
* Anthropic adapter
* Gemini adapter
* Ollama/local model support
* Apple foundation model support
* Streaming inference
* Function calling support
* JSON mode
* Structured output support
* Multi-model orchestration
* Fallback provider support
* Model capability registry

---

## 11. Native OS Integration

* App Intents integration
* Siri integration
* Spotlight indexing
* Keyboard shortcuts
* Voice activation
* Clipboard access
* Filesystem tools
* Notification integration
* Background execution
* Menu bar agent support
* Accessibility automation
* Calendar integration
* Contacts integration

---

## 12. State Management

* Agent state machine
* Persistent execution state
* Interrupt/resume support
* Multi-session state management
* State snapshots
* Shared state
* State diffing
* State recovery

---

## 13. Security & Permissions

* Tool permission scopes
* Human approval gates
* Secret management
* Encrypted memory
* Local-only execution mode
* Sandboxed tools
* Audit logs
* Access policies
* Capability restrictions

---

## 14. Observability & Devtools

* Prompt inspector
* Token tracing
* Tool execution logs
* Context visualizer
* Workflow debugger
* Memory inspection
* MCP traffic viewer
* Latency tracing
* Cost tracking
* Agent replay
* Deterministic test mode

---

## 15. UI Helpers

* Streaming text UI
* Agent state views
* Workflow progress views
* Tool execution UI
* Confirmation dialogs
* Chat surfaces
* SwiftUI components
* UIKit bindings

---

## 16. Multi-Agent Systems

* Agent-to-agent messaging
* Shared memory graphs
* Delegation support
* Supervisor agents
* Specialized worker agents
* Collaborative workflows
* Agent marketplaces

---

## 17. Enterprise Features

* Team-shared skills
* Enterprise policy engine
* SSO/auth integrations
* RBAC support
* Distributed execution
* Remote orchestration
* Cloud synchronization
* Shared vector stores

---

## 18. Developer Experience

* Swift macros
* Declarative APIs
* Workflow DSLs
* Code generation
* Xcode integration
* Skill scaffolding CLI
* Workflow builder
* Simulator tools
* Local testing harness

* ---

# Roadmap & V1 Priorities

For the initial release (V1), the focus will be on establishing the core architecture and enabling the most critical agentic capabilities.

## Phase 1: Core Foundation (V1)
*   **Core Agent Runtime**: Basic execution loop with multi-step reasoning.
*   **Model Layer**: Multi-model provider abstraction (Gemini, OpenAI, Anthropic).
*   **Tool System**: Basic typed tool execution and function calling.
*   **MCP Integration**: MCP client runtime, tool discovery, and local/remote server support.
*   **Memory System**: Simple conversation memory and persistence.
*   **Native Integration**: Initial App Intents support for macOS/iOS.

## Phase 2: Enhanced Capabilities (V2)
*   **Workflow Engine**: DAG-based execution and complex planning.
*   **Skill System**: Dynamic loading and skill manifests.
*   **Advanced Memory**: Semantic memory and vector store integration.
*   **Observability**: Full tracing and debugging tools.

## Phase 3: Ecosystem & Enterprise
*   **Multi-Agent Systems**: Delegation and collaborative workflows.
*   **UI Helpers**: SwiftUI components for agent state and chat.
*   **Enterprise Features**: SSO, RBAC, and distributed execution.

# PRD Hardening Additions
The following sections specify mandatory, testable requirements to make the PRD implementation-ready for a Swift-native agent SDK.

## 1. Concurrency & Isolation
- Actor map: The agent execution loop, tool executor, memory store, and MCP client each run in separate actors (e.g., AgentRuntimeActor, ToolExecutorActor, MemoryStoreActor, MCPClientActor). UI-facing APIs use MainActor.
- Reentrancy policy: Within a single agent session, the AgentRuntimeActor is non-reentrant — only one step mutates session state at a time. Cross-session concurrency is allowed.
- Cancellation: Cancellation propagates from the top-level task to all child tasks; tools must observe cancellation and stop within 500 ms of cancellation.
- Backpressure: Max concurrent tool executions per agent = 4 (configurable). Excess work is queued FIFO.

Acceptance Criteria:
- A concurrency diagram documents actor boundaries. Tests verify that two steps in the same session do not interleave state mutations.
- Cancellation tests assert tools observe Task.isCancelled and complete within 500 ms after cancellation.
- Stress test launching >4 tools ensures queueing and no data races.

## 2. Error Taxonomy & Failure Policy
- Define error domains: ModelError, ToolError, TransportError, MemoryError, PlanningError, DecodingError, PermissionError, TimeoutError, Cancellation.
- Retry/backoff: Transient errors (e.g., TransportError.network, TimeoutError) are retried up to 2 times with exponential backoff (base 200 ms, jitter 30%).
- Circuit breaker: For repeated ToolError on the same tool (>3 in 1 minute), open the breaker for 2 minutes.
- Idempotency: Side-effectful tools must support idempotency keys.

Acceptance Criteria:
- Public error types are documented. Unit tests assert retry/backoff behavior and that the circuit breaker opens/closes correctly.
- Side-effectful tool endpoints deduplicate requests with the same idempotency key.

## 3. Data Contracts & Versioning
- All external I/O Codable messages include schemaVersion.
- Decoding policy: Reject unknown required fields by default; tolerate additional optional fields only if allowUnknownFields is enabled for that contract.
- Migration: Provide migration hooks for persisted memory entries across schema versions.

Acceptance Criteria:
- Decoding fails by default when unknown required fields are present. Migration tests transform v1 data to v2.

## 4. Security & Permissions
- Treat LLM/MCP outputs as untrusted; validate against schema before use.
- Tool permission scopes are required and deny-by-default.
- Secrets are stored in Keychain; no secrets in logs.
- Audit log captures tool invocations with redacted arguments.

Acceptance Criteria:
- Attempting a tool without permission fails with a PermissionError. Logs redact secrets. Schema validation rejects malformed outputs.

## 5. Tool System Semantics
- Typed I/O for tools. Default timeout is 30 s (configurable per tool).
- Retries: Up to 2 for transient errors; none for validation/permission errors.
- Human approval gates: Blocking checkpoint for tools marked requiresApproval.
- Idempotency: Side-effectful tools require an idempotencyKey.

Acceptance Criteria:
- Timeout is enforced and observable. Retry policy verified via fault injection. Approval gate blocks until callback. Duplicate idempotencyKey prevents duplicate side effects.

## 6. MCP Integration
- Transport: WebSocket with heartbeat every 15 s; reconnect with exponential backoff up to 60 s.
- Capability negotiation occurs on connect; reject incompatible versions.
- Streaming backpressure: Buffer cap 64 KB; drop oldest with warning when exceeded.

Acceptance Criteria:
- Simulated disconnect triggers reconnect and restores session. Incompatible server is rejected. Buffer cap is enforced in tests.

## 7. Observability & Privacy
- Log levels: debug, info, warn, error. Correlation IDs per agent session.
- Redaction rules for PII and secrets; prompts and tool logs redact sensitive fields by default.
- Deterministic replay mode to reproduce a run with stubs.

Acceptance Criteria:
- Logs contain correlation IDs. Redacted fields never appear. Replay reproduces outputs with stubs.

## 8. Testing & Verification
- Spec-driven tests with deterministic harness (network/model stubs, fixed seeds).
- Concurrency stress tests and fault injection (timeouts, cancellations, retries).
- Golden outputs for critical planners/routers.

Acceptance Criteria:
- Tests cover happy, edge, adversarial, and concurrency scenarios. Build and tests pass deterministically across runs.

## 9. Performance & Resource Constraints
- Targets: p50 prompt→tool→response ≤ 800 ms; p95 ≤ 2.5 s on a reference development machine.
- Memory cap for an agent process: 200 MB steady-state (configurable).
- Caching: Prompt and tool result cache with LRU eviction.

Acceptance Criteria:
- Benchmark suite validates latency targets. Cache hit/miss metrics are exposed. No unbounded memory growth under load.

## 10. On-Device vs Cloud Models
- Capability matrix selects on-device when available; fallback to cloud when required.
- Offline mode queues requests and degrades gracefully.
- Asset management: Models stored outside the app bundle with size-aware policies.

Acceptance Criteria:
- Offline test queues and resumes work. Fallback engages when on-device capability is missing. Asset policies are enforced.

## 11. Multi-Agent & Shared State
- Messaging: At-least-once delivery with ordering per conversation.
- Shared memory consistency via CRDT or actor-serialized access.
- Supervisor/worker lifecycle with failure containment.

Acceptance Criteria:
- Reordered message test preserves logical order. Concurrent writes resolve deterministically. Worker failure does not crash supervisor.

## 12. Persistence & Migration
- Storage backend with versioned schema (SwiftData/Core Data/SQLite). 
- Crash-safe checkpoints; recovery resumes workflows.

Acceptance Criteria:
- Simulated crash persists a checkpoint and recovers. Migration path validated by tests.

## 13. Networking & Background Execution
- NWPath monitoring; offline queue with retry/backoff.
- Background tasks via BGTaskScheduler for long-running operations where allowed.

Acceptance Criteria:
- Background task continues within allowed time budget. Offline queue drains on connectivity restoration.

## 14. Compliance & Governance
- Data retention default: 30 days; user-initiated deletion and export supported.
- Content safety moderation hook (configurable).

Acceptance Criteria:
- Delete/export flows tested. Moderation is invoked when enabled and blocks disallowed content.

## 15. Developer Experience
- Availability annotations and async/await-first APIs.
- Configuration layering: defaults, environment, per-agent overrides.
- Result builders/macros scope is documented.

Acceptance Criteria:
- Public API is annotated and examples compile. Configuration precedence is deterministic and tested.

## Minimal V1 Acceptance Checklist
- Agent loop with actor boundaries, cancellation, and non-reentrancy within a session.
- Tool system with typed I/O, timeouts, retries, idempotency, and approval gates.
- Model layer with at least two providers and a deterministic test harness.
- MCP client with reconnect and capability negotiation; basic backpressure.
- Memory with versioned schema and persistence plus migration plan.
- Observability with redaction and deterministic replay.
- Security baseline: entitlements, Keychain secrets, audit logs, input validation.
- Performance targets met by benchmark suite.
- Spec-driven tests covering happy, edge, adversarial, and concurrency cases.

