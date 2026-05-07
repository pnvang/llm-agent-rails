# frozen_string_literal: true

LlmAgentRails.configure do |config|
  # Use the fake adapter in development/test, or provide your own adapter object
  # that implements #extract(workflow:, message:, slots:, context:).
  config.provider = :fake
  config.adapter = LlmAgentRails::Adapters::Fake.new

  # For OpenAI, add `gem "openai"` to your app and use:
  # config.provider = :openai
  # config.adapter = ->(c) {
  #   LlmFillin::Adapters::OpenAI.new(
  #     api_key: ENV.fetch("OPENAI_API_KEY"),
  #     model: c.model,
  #     temperature: c.temperature
  #   )
  # }

  config.model = "gpt-4.1-mini"
  config.temperature = 0
end
