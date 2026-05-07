# frozen_string_literal: true
module Llm
  module Agent
    module Rails
      class Engine < ::Rails::Engine
        isolate_namespace ::Llm::Agent

        initializer "llm_agent_rails.autoload_intakes", before: :set_autoload_paths do |app|
          app.config.paths.add "app/llm_intakes", eager_load: true
        end

        config.to_prepare do
          LlmAgentRails.load_intakes!
        end
      end
    end
  end
end
