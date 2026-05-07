# frozen_string_literal: true

require "rails/generators"

module LlmAgentRails
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      def create_initializer
        template "llm_agent_rails.rb", "config/initializers/llm_agent_rails.rb"
      end

      def create_intakes_directory
        create_file "app/llm_intakes/.keep", ""
      end

      def copy_migrations
        invoke "llm_agent_rails:migrations"
      end

      def mount_engine
        route %(mount Llm::Agent::Rails::Engine => "/llm")
      end
    end
  end
end
