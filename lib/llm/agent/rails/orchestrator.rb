# frozen_string_literal: true

module Llm
  module Agent
    module Rails
      # Backwards-compatible wrapper around llm-fillin's 0.1 tool-call path.
      class Orchestrator < LlmFillin::Orchestrator
      end
    end
  end
end
