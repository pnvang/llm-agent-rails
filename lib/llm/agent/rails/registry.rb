# frozen_string_literal: true

module LlmAgentRails
  class Registry
    def initialize
      @intakes = {}
      @legacy_tools = LlmFillin::Registry.new
    end

    def register(intake_class)
      @intakes[intake_class.intake_id] = intake_class
      intake_class
    end
    alias register_intake register

    def fetch(id)
      @intakes.fetch(normalize_id(id))
    end
    alias intake fetch

    def [](id)
      @intakes[normalize_id(id)]
    end

    def intakes
      @intakes.values
    end

    def ids
      @intakes.keys
    end

    def clear
      @intakes.clear
    end

    # Backwards-compatible 0.1 tool registration.
    def register!(name:, version:, schema:, description:, handler:)
      @legacy_tools.register!(name: name, version: version, schema: schema, description: description, handler: handler)
    end

    def tool(name, version: "v1")
      @legacy_tools.tool(name, version: version)
    end

    def tools_for_llm
      @legacy_tools.tools_for_llm
    end

    private

    def normalize_id(id)
      id.to_s.delete_prefix("/").underscore
    end
  end
end

module Llm
  module Agent
    module Rails
      Registry = ::LlmAgentRails::Registry unless const_defined?(:Registry)
    end
  end
end
