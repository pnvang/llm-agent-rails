# frozen_string_literal: true

require "rails"
require "active_record/railtie"
require "action_controller/railtie"
require "active_support/logger"

require_relative "../../../lib/llm/agent/rails"

module Dummy
  class Application < Rails::Application
    config.root = File.expand_path("..", __dir__)
    config.eager_load = false
    config.secret_key_base = "test-secret-key-base"
    config.hosts.clear
    config.logger = ActiveSupport::Logger.new(File::NULL)
    config.log_level = :fatal
    config.active_support.to_time_preserves_timezone = :zone

    routes.append do
      mount Llm::Agent::Rails::Engine => "/llm"
    end
  end
end
