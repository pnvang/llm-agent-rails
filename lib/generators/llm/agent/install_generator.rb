# frozen_string_literal: true
require "rails/generators"
require "generators/llm_agent_rails/install/install_generator"

module Llm
  module Agent
    class InstallGenerator < ::LlmAgentRails::Generators::InstallGenerator
    end
  end
end
