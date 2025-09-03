# frozen_string_literal: true
# Configure the LLM agent runtime.
LLM::Agent::Rails.configure do |c|
  c[:model]       = "gpt-4o-mini"
  c[:temperature] = 0
  c[:store]       = LLM::Agent::Rails::Store::Memory.new
  c[:registry]    = LLM::Agent::Rails::Registry.new
end

# Example: register tools here or in separate files.
# require Rails.root.join("app/llm_tools/tickets")
# LlmTools.register!(LLM::Agent::Rails.config[:registry])
