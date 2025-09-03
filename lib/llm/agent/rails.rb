# frozen_string_literal: true
require "rails"
require "json"
require "json_schemer"
require "openai"

require_relative "rails/version"
require_relative "rails/engine"

require_relative "rails/registry"
require_relative "rails/validators"
require_relative "rails/idempotency"
require_relative "rails/orchestrator"
require_relative "rails/adapters/openai_adapter"
require_relative "rails/store/memory"

module LLM
  module Agent
    module Rails
      class << self
        def config
          @config ||= {
            model: "gpt-4o-mini",
            temperature: 0,
            store: LLM::Agent::Rails::Store::Memory.new,
            registry: LLM::Agent::Rails::Registry.new
          }
        end

        def configure
          yield config
        end
      end
    end
  end
end
