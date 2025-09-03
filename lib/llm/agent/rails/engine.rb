# frozen_string_literal: true
module LLM
  module Agent
    module Rails
      class Engine < ::Rails::Engine
        isolate_namespace ::Llm::Agent
      end
    end
  end
end
