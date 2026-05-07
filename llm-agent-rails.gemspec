# frozen_string_literal: true
require_relative "lib/llm/agent/rails/version"

Gem::Specification.new do |s|
  s.name        = "llm-agent-rails"
  s.version     = Llm::Agent::Rails::VERSION
  s.summary     = "Rails-native AI intake forms and slot-filling workflows."
  s.description = "A Rails engine for AI-assisted intake forms that collect missing fields, validate values, confirm with users, and execute safe Rails backend actions."
  s.authors     = ["Phia Vang"]
  s.email       = ["pnvang@gmail.com"]
  s.homepage    = "https://github.com/pnvang/llm-agent-rails"
  s.license     = "MIT"

  s.files = Dir["{app,lib,config}/**/*", "README.md", "CHANGELOG.md", "LICENSE", "Rakefile"]
  s.required_ruby_version = ">= 3.1"

  s.add_dependency "rails", ">= 7.0"
  s.add_dependency "llm-fillin", "~> 0.2"

  s.add_development_dependency "minitest", "~> 5.25"
  s.add_development_dependency "rack-test", "~> 2.2"
  s.add_development_dependency "sqlite3", "~> 2.0"

  s.metadata = {
    "allowed_push_host" => "https://rubygems.org",
    "source_code_uri" => "https://github.com/pnvang/llm-agent-rails"
  }
end
