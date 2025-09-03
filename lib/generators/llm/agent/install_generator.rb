require "rails/generators"

module Llm
  module Agent
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      def create_initializer
        template "llm_agent.rb", "config/initializers/llm_agent.rb"
      end

      def mount_routes
        route %(mount Llm::Agent::Rails::Engine => "/llm/agent")
      end
    end
  end
end
