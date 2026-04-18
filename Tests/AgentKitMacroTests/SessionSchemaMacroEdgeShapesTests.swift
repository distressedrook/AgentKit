// By Avismara Hugoppalu

import MacroTesting
import AgentKitMacros
import SwiftSyntaxMacros
import Testing

@Suite("@SessionSchema expansion - Edge Shapes")
struct SessionSchemaMacroEdgeShapesTests {
  @Test("Schema with no tools and no structured outputs")
  func expandSchemaWithNoToolsAndNoStructuredOutputs() {
    assertMacro(["SessionSchema": SessionSchemaMacro.self], indentationWidth: .spaces(2)) {
      """
      @SessionSchema
      struct SessionSchema {
      }
      """
    } expansion: {
      """
      struct SessionSchema {

        internal nonisolated let tools: [any DecodableTool<DecodedToolRun>]

        internal struct StructuredOutputs: @unchecked Sendable {
        }

        internal static func structuredOutputs() -> [any (AgentKit.DecodableStructuredOutput<DecodedStructuredOutput>).Type] {
          []
        }

        internal init() {
          tools = []
        }

        internal struct DecodedGrounding: AgentKit.DecodedGrounding, @unchecked Sendable {
        }

        internal enum DecodedToolRun: AgentKit.DecodedToolRun, @unchecked Sendable {
          case unknown(toolCall: AgentKit.Transcript.ToolCall)
          internal static func makeUnknown(toolCall: AgentKit.Transcript.ToolCall) -> Self {
            .unknown(toolCall: toolCall)
          }
          internal var id: String {
            switch self {
            case let .unknown(toolCall):
              toolCall.id
            }
          }
        }

        internal enum DecodedStructuredOutput: AgentKit.DecodedStructuredOutput, @unchecked Sendable {
          case unknown(AgentKit.Transcript.StructuredSegment)

          internal static func makeUnknown(segment: AgentKit.Transcript.StructuredSegment) -> Self {
            .unknown(segment)
          }
        }

        @propertyWrapper
        struct Tool<ToolType: FoundationModels.Tool>
        where ToolType.Arguments: Generable, ToolType.Output: Generable {
          var wrappedValue: ToolType
          init(wrappedValue: ToolType) {
            self.wrappedValue = wrappedValue
          }
        }

        @propertyWrapper
        struct StructuredOutput<Output: AgentKit.StructuredOutput> {
          var wrappedValue: Output.Type
          init(_ wrappedValue: Output.Type) {
            self.wrappedValue = wrappedValue
          }
        }

        @propertyWrapper
        struct Grounding<Source: Codable & Sendable & Equatable> {
          var wrappedValue: Source.Type
          init(_ wrappedValue: Source.Type) {
            self.wrappedValue = wrappedValue
          }
        }
      }

      extension SessionSchema: LanguageModelSessionSchema {
      }
      """
    }
  }

  @Test("Schema with structured outputs only")
  func expandSchemaWithStructuredOutputsOnly() {
    assertMacro(["SessionSchema": SessionSchemaMacro.self], indentationWidth: .spaces(2)) {
      """
      @SessionSchema
      struct SessionSchema {
        @StructuredOutput(WeatherReport.self) var weatherReport
      }
      """
    } expansion: {
      """
      struct SessionSchema {
        @StructuredOutput(WeatherReport.self) var weatherReport

        internal nonisolated let tools: [any DecodableTool<DecodedToolRun>]

        internal struct StructuredOutputs: @unchecked Sendable {
          let weatherReport = WeatherReport.self
        }

        internal static func structuredOutputs() -> [any (AgentKit.DecodableStructuredOutput<DecodedStructuredOutput>).Type] {
          [
              DecodableWeatherReport.self
          ]
        }

        internal init() {
          tools = []
        }

        internal struct DecodedGrounding: AgentKit.DecodedGrounding, @unchecked Sendable {
        }

        internal enum DecodedToolRun: AgentKit.DecodedToolRun, @unchecked Sendable {
          case unknown(toolCall: AgentKit.Transcript.ToolCall)
          internal static func makeUnknown(toolCall: AgentKit.Transcript.ToolCall) -> Self {
            .unknown(toolCall: toolCall)
          }
          internal var id: String {
            switch self {
            case let .unknown(toolCall):
              toolCall.id
            }
          }
        }

        internal enum DecodedStructuredOutput: AgentKit.DecodedStructuredOutput, @unchecked Sendable {
          case weatherReport(AgentKit.StructuredOutputSnapshot<WeatherReport>)
          case unknown(AgentKit.Transcript.StructuredSegment)

          internal static func makeUnknown(segment: AgentKit.Transcript.StructuredSegment) -> Self {
            .unknown(segment)
          }
        }

        private struct DecodableWeatherReport: AgentKit.DecodableStructuredOutput, @unchecked Sendable {
          typealias Base = WeatherReport

          static func decode(
            _ structuredOutput: AgentKit.StructuredOutputSnapshot<WeatherReport>
          ) -> DecodedStructuredOutput {
            .weatherReport(structuredOutput)
          }
        }

        @propertyWrapper
        struct Tool<ToolType: FoundationModels.Tool>
        where ToolType.Arguments: Generable, ToolType.Output: Generable {
          var wrappedValue: ToolType
          init(wrappedValue: ToolType) {
            self.wrappedValue = wrappedValue
          }
        }

        @propertyWrapper
        struct StructuredOutput<Output: AgentKit.StructuredOutput> {
          var wrappedValue: Output.Type
          init(_ wrappedValue: Output.Type) {
            self.wrappedValue = wrappedValue
          }
        }

        @propertyWrapper
        struct Grounding<Source: Codable & Sendable & Equatable> {
          var wrappedValue: Source.Type
          init(_ wrappedValue: Source.Type) {
            self.wrappedValue = wrappedValue
          }
        }
      }

      extension SessionSchema: LanguageModelSessionSchema {
      }
      """
    }
  }

  @Test("Multiple structured outputs preserve declaration order")
  func expandSchemaWithMultipleStructuredOutputsPreservingOrder() {
    assertMacro(["SessionSchema": SessionSchemaMacro.self], indentationWidth: .spaces(2)) {
      """
      @SessionSchema
      struct SessionSchema {
        @StructuredOutput(First.self) var first
        @StructuredOutput(Second.self) var second
      }
      """
    } expansion: {
      """
      struct SessionSchema {
        @StructuredOutput(First.self) var first
        @StructuredOutput(Second.self) var second

        internal nonisolated let tools: [any DecodableTool<DecodedToolRun>]

        internal struct StructuredOutputs: @unchecked Sendable {
          let first = First.self
          let second = Second.self
        }

        internal static func structuredOutputs() -> [any (AgentKit.DecodableStructuredOutput<DecodedStructuredOutput>).Type] {
          [
              DecodableFirst.self,
              DecodableSecond.self
          ]
        }

        internal init() {
          tools = []
        }

        internal struct DecodedGrounding: AgentKit.DecodedGrounding, @unchecked Sendable {
        }

        internal enum DecodedToolRun: AgentKit.DecodedToolRun, @unchecked Sendable {
          case unknown(toolCall: AgentKit.Transcript.ToolCall)
          internal static func makeUnknown(toolCall: AgentKit.Transcript.ToolCall) -> Self {
            .unknown(toolCall: toolCall)
          }
          internal var id: String {
            switch self {
            case let .unknown(toolCall):
              toolCall.id
            }
          }
        }

        internal enum DecodedStructuredOutput: AgentKit.DecodedStructuredOutput, @unchecked Sendable {
          case first(AgentKit.StructuredOutputSnapshot<First>)
          case second(AgentKit.StructuredOutputSnapshot<Second>)
          case unknown(AgentKit.Transcript.StructuredSegment)

          internal static func makeUnknown(segment: AgentKit.Transcript.StructuredSegment) -> Self {
            .unknown(segment)
          }
        }

        private struct DecodableFirst: AgentKit.DecodableStructuredOutput, @unchecked Sendable {
          typealias Base = First

          static func decode(
            _ structuredOutput: AgentKit.StructuredOutputSnapshot<First>
          ) -> DecodedStructuredOutput {
            .first(structuredOutput)
          }
        }

        private struct DecodableSecond: AgentKit.DecodableStructuredOutput, @unchecked Sendable {
          typealias Base = Second

          static func decode(
            _ structuredOutput: AgentKit.StructuredOutputSnapshot<Second>
          ) -> DecodedStructuredOutput {
            .second(structuredOutput)
          }
        }

        @propertyWrapper
        struct Tool<ToolType: FoundationModels.Tool>
        where ToolType.Arguments: Generable, ToolType.Output: Generable {
          var wrappedValue: ToolType
          init(wrappedValue: ToolType) {
            self.wrappedValue = wrappedValue
          }
        }

        @propertyWrapper
        struct StructuredOutput<Output: AgentKit.StructuredOutput> {
          var wrappedValue: Output.Type
          init(_ wrappedValue: Output.Type) {
            self.wrappedValue = wrappedValue
          }
        }

        @propertyWrapper
        struct Grounding<Source: Codable & Sendable & Equatable> {
          var wrappedValue: Source.Type
          init(_ wrappedValue: Source.Type) {
            self.wrappedValue = wrappedValue
          }
        }
      }

      extension SessionSchema: LanguageModelSessionSchema {
      }
      """
    }
  }
}
