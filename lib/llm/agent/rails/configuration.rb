# frozen_string_literal: true

module LlmAgentRails
  class Configuration
    attr_accessor :model, :temperature, :provider, :adapter, :registry,
                  :idempotency_store, :intakes_path, :persist_messages

    def initialize
      @model = "gpt-4.1-mini"
      @temperature = 0
      @provider = :fake
      @adapter = nil
      @registry = Registry.new
      @idempotency_store = nil
      @intakes_path = nil
      @persist_messages = true
    end

    def [](key)
      public_send(key)
    end

    def []=(key, value)
      public_send("#{key}=", value)
    end

    def adapter_instance
      configured = adapter
      return default_adapter unless configured
      return configured.call(self) if configured.respond_to?(:call) && callable_arity(configured) != 0
      return configured.call if configured.respond_to?(:call)

      configured
    end

    def resolved_intakes_path
      intakes_path || (::Rails.root.join("app/llm_intakes") if defined?(::Rails) && ::Rails.respond_to?(:root) && ::Rails.root)
    end

    private

    def default_adapter
      case provider&.to_sym
      when :openai
        LlmFillin::Adapters::OpenAI.new(
          api_key: ENV.fetch("OPENAI_API_KEY"),
          model: model,
          temperature: temperature
        )
      when :ruby_llm
        LlmFillin::Adapters::RubyLLM.new(model: model)
      else
        Adapters::Fake.new
      end
    end

    def callable_arity(callable)
      return callable.arity if callable.respond_to?(:arity)

      callable.method(:call).arity
    end
  end
end
