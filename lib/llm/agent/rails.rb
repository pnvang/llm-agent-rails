# frozen_string_literal: true

require "rails"
require "active_model"
require "active_record"
require "json"
require "llm/fillin"

require_relative "rails/version"

module LlmAgentRails
  class << self
    def config
      @config ||= Configuration.new
    end

    def configure
      yield config
    end

    def registry
      config.registry
    end

    def load_intakes!
      path = config.resolved_intakes_path
      Dir["#{path}/**/*.rb"].sort.each { |file| require_dependency file } if path && Dir.exist?(path)
      Intake.descendants.each { |klass| registry.register(klass) if klass.name.present? }
      registry.intakes
    end
  end
end

module Llm
  module Agent
    module Rails
      class << self
        def config = ::LlmAgentRails.config
        def configure(&block) = ::LlmAgentRails.configure(&block)
        def registry = ::LlmAgentRails.registry
        def load_intakes! = ::LlmAgentRails.load_intakes!
      end
    end
  end
end

require_relative "rails/json"
require_relative "rails/registry"
require_relative "rails/configuration"
require_relative "rails/intake"
require_relative "rails/adapters/fake"
require_relative "rails/active_record_idempotency_store"
require_relative "rails/intake_runner"
require_relative "rails/validators"
require_relative "rails/idempotency"
require_relative "rails/orchestrator"
require_relative "rails/adapters/openai_adapter"
require_relative "rails/store/memory"
require_relative "rails/engine"
