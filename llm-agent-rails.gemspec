# frozen_string_literal: true
require_relative "lib/llm/agent/rails/version"

Gem::Specification.new do |s|
  s.name        = "llm-agent-rails"
  s.version     = LLM::Agent::Rails::VERSION
  s.summary     = "Rails engine for LLM-powered slot filling and tool orchestration."
  s.description = "Drop-in Rails engine to register JSON-schema tools, let an LLM fill missing fields, validate input, and execute handlers safely."
  s.authors     = ["Phia Vang"]
  s.email       = ["pnvang@gmail.com"]
  s.homepage    = "https://github.com/pnvang/llm-agent-rails"
  s.license     = "MIT"

  s.files = Dir["{app,lib,config}/**/*", "README.md", "LICENSE", "Rakefile"]
  s.required_ruby_version = ">= 3.1"

  s.add_dependency "rails", ">= 7.0"
  s.add_dependency "json_schemer", "~> 2.3"
  s.add_dependency "openai", "~> 0.21"

  s.metadata = {
    "allowed_push_host" => "https://rubygems.org",
    "source_code_uri" => "https://github.com/yourname/llm-agent-rails"
  }
end
