// By Avismara Hugoppalu

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct AgentKitMacroPlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    SessionSchemaMacro.self,
  ]
}
