require "rails"
require "json"
require "json_schemer"
require "openai"

require_relative "rails/version"
require_relative "rails/engine"

module Llm
  module Agent
    module Rails
      class << self
        def config
          @config ||= {
            model: "gpt-4o-mini",
            temperature: 0
          }
        end

        def configure
          yield config
        end
      end
    end
  end
end
