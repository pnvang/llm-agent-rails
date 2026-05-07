# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require "rails/generators/test_case"
require "generators/llm_agent_rails/install/install_generator"

class InstallGeneratorTest < Rails::Generators::TestCase
  tests LlmAgentRails::Generators::InstallGenerator
  destination File.expand_path("llm_agent_rails_install_generator", Dir.tmpdir)

  setup do
    prepare_destination
    FileUtils.mkdir_p(File.join(destination_root, "config"))
    File.write(File.join(destination_root, "config/routes.rb"), "Rails.application.routes.draw do\nend\n")
  end

  test "creates initializer intakes directory migrations and mount route" do
    run_generator

    assert_file "config/initializers/llm_agent_rails.rb"
    assert_file "app/llm_intakes/.keep"
    assert_migration "db/migrate/create_llm_agent_rails_tables.rb"

    routes = File.read(File.join(destination_root, "config/routes.rb"))
    assert_includes routes, 'mount Llm::Agent::Rails::Engine => "/llm"'
  end
end
