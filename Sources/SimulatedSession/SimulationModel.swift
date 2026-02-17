// By Avismara Hugoppalu

import Foundation
import FoundationModels
import OpenAI
import OSLog
import AgentKit

/// The model to use for generating a response.
public enum SimulationModel: Equatable, Hashable, Sendable, AdapterModel {
  case simulated
  public static let `default`: SimulationModel = .simulated
}
