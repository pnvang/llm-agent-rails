# frozen_string_literal: true

require "rails/generators"
require "rails/generators/active_record"

module LlmAgentRails
  module Generators
    class MigrationsGenerator < ::Rails::Generators::Base
      include ::Rails::Generators::Migration

      source_root File.expand_path("templates", __dir__)

      def self.next_migration_number(_dirname)
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      end

      def copy_migration
        migration_template "create_llm_agent_rails_tables.rb", "db/migrate/create_llm_agent_rails_tables.rb"
      end
    end
  end
end
