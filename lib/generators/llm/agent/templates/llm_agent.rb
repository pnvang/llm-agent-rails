# frozen_string_literal: true
# Configure the Llm agent runtime.
Llm::Agent::Rails.configure do |c|
  c[:model]       = "gpt-4o-mini"
  c[:temperature] = 0
  c[:store]       = Llm::Agent::Rails::Store::Memory.new
  c[:registry]    = Llm::Agent::Rails::Registry.new
end

# Example: register tools here or in separate files.
# require Rails.root.join("app/llm_tools/tickets")
# LlmTools.register!(Llm::Agent::Rails.config[:registry])
