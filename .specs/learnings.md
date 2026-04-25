# Architectural Blueprint: AgentKit v1
*Derived from an exhaustive deep dive into the VoltAgent framework*

A deep architectural analysis of the VoltAgent monorepo reveals a mature, production-ready system. It is not just an LLM wrapper; it is an **Event-Driven, Protocol-Oriented, Observable State Machine**. 

To build **AgentKit v1** as the premier native Swift agentic framework, we must adopt these core paradigms and translate them into native Apple ecosystem constructs.

---

## 1. The Core Philosophy
VoltAgent treats LLM inference as just one step in a much larger, deterministic state machine.
- **Protocol-Oriented Infrastructure**: Everything (Servers, Memory, Tools, Observability) is an injectable interface. The core `Agent` runtime knows nothing about the outside world.
- **Fail-Safe by Design**: Every execution step is wrapped in guardrails, and any failure or intentional suspension cleanly halts the state machine without crashing the host application.

---

## 2. The Execution Pipeline
The most critical learning is the `Agent` execution loop. It does not blindly call an LLM. It processes requests through a rigorous pipeline:

1. **Input Middlewares**: Pre-processes context (e.g., fetching RAG documents, normalizing user input).
2. **Input Guardrails**: Evaluates if the prompt is safe or meets business logic before hitting the expensive LLM.
3. **Inference (LLM)**: The core reasoning step via a Model Provider.
4. **Tool Execution**: If the LLM requests a tool, it validates the arguments against strict schemas (Zod in TS, `Codable` in Swift) and executes.
5. **Output Guardrails**: Validates the output of the LLM or Tool to ensure it doesn't leak data or hallucinate formats.
6. **Output Middlewares**: Formats the final payload for the client.

**Swift Translation**: We must define robust `Middleware` and `Guardrail` protocols. The execution loop should be an `async throws` pipeline that processes these sequentially.

---

## 3. Memory & State Hydration
True agentic behavior requires "Suspend and Resume" capabilities (Human-in-the-Loop). VoltAgent achieves this through explicit state check-pointing.

- **Working Memory**: Dynamic context injected into the prompt.
- **WorkflowStateEntry**: When a workflow hits a wall (e.g., waiting for human approval), it throws a `WORKFLOW_SUSPENDED` error. The orchestrator catches this, dumps the entire state (`usage`, `stepIndex`, `context`) into a `StorageAdapter`, and kills the process. When the human approves, the state is hydrated, and the loop resumes from the exact `stepIndex`.

**Swift Translation**: Swift's `Codable` makes serializing state trivial. We need a `StorageAdapter` protocol with implementations for `UserDefaults` (simple) and `SwiftData`/`CoreData` (complex) to handle the persistence of a `WorkflowState`.

---

## 4. Reactive Workflows (The DSL)
VoltAgent builds workflows using a chained operator pattern (e.g., `andThen`, `andAgent`, `andLoop`). 
- **`andAgent` Step**: This step binds an Agent to a strict output schema. It forces the LLM to output structured data, mapping the text response directly into the workflow's shared memory payload.

**Swift Translation**: Swift's **`@resultBuilder`** is uniquely suited for this. We can create a Domain Specific Language (DSL) that allows developers to write workflows like SwiftUI:

```swift
let expenseWorkflow = Workflow {
    AgentStep(agent: reviewAgent, schema: ExpenseApproval.self)
    Condition { state in state.amount > 500 }
    SuspendStep(reason: "Waiting for Manager")
    FinalizeStep()
}
```

---

## 5. Tooling & MCP Integration
- **Strict Typing**: Tools are defined with rigid schemas. If the LLM hallucinates an argument, the validation layer catches it before execution.
- **Model Context Protocol (MCP)**: MCP is treated as a first-class citizen. `MCPServerRegistry` abstracts away the transport layer (`stdio`, `http`, `sse`), allowing the agent to dynamically discover and execute tools from external servers.

**Swift Translation**: Tools should be generic over `Codable` input types. MCP integration will require building an asynchronous transport client (likely using Swift `URLSession` for SSE/HTTP and `Process` for stdio on macOS).

---

## 6. Deep Observability
VoltAgent does not rely on simple `console.log`. It is deeply instrumented with **OpenTelemetry**.
- Every single LLM call, Tool execution, and Middleware evaluation opens a `Span`.
- Attributes (like token usage, bail reasons, and latency) are attached to these spans and flushed asynchronously to a dashboard.

**Swift Translation**: We should integrate deeply with Apple's `os_log` and **`OSSignposter`** out of the box, allowing developers to use Xcode Instruments to visually profile Agent reasoning loops and tool execution latencies natively.

---

## 7. PlanAgent & Ephemeral SubAgents (Task Isolation)
VoltAgent implements a `PlanAgent` that strictly manages complex multi-step objectives using two core mechanisms:
- **`write_todos`**: A tool that forces the agent to explicitly maintain an internal plan state before executing actions.
- **Ephemeral SubAgents (`task` tool)**: Instead of the orchestrator doing all the work, it spawns short-lived, parallel sub-agents (e.g., a `research-analyst` or `content-reviewer`). These sub-agents have isolated context windows. They execute, return a synthesized result, and die. This prevents the main thread from suffering context bloat and massive token costs.

**Swift Translation**: AgentKit should provide a `SupervisorAgent` protocol that natively understands a `TaskTool`. This tool should leverage Swift Concurrency (`TaskGroup`) to spawn multiple isolated `Agent` instances in parallel, merging their structured outputs back into the main actor's memory.

---

## 8. OS-Level Sandboxing (Code Execution)
To allow agents to safely execute code or interact with the file system, the `Workspace` module does not rely on simple application logic. It drops down to the OS level:
- On macOS, it dynamically generates seatbelt profiles and uses `sandbox-exec`.
- On Linux, it uses `bwrap` (Bubblewrap) to create unprivileged containers.

**Swift Translation**: This is a massive advantage for a native Swift framework. macOS provides native sandboxing APIs. AgentKit can provide an `AgentSandbox` protocol that executes LLM-generated scripts inside an `NSXPCConnection` to a sandboxed helper app, or by spawning a `Process` with a dynamically generated seatbelt profile, guaranteeing the host machine is completely protected from rogue agent behavior.

---

## 10. Machine Learning & Intent Classification
- **Dataset Generation**: High-quality training data for CoreML can be bootstrapped using template-based permutation. This ensures high coverage of common utterances while maintaining class balance and diversity.
- **Intents for AgentKit**: Five primary intents have been identified for the initial orchestration layer: `execute_workflow`, `access_memory`, `mcp_interaction`, `summarize_content`, and `smalltalk`.
- **CoreML Compatibility**: The JSON format used (`{"text": "...", "label": "..."}`) is directly compatible with Create ML for training text classifiers. The volume of ~2000 samples provides a strong baseline for production effectiveness.
