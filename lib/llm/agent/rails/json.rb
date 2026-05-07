# frozen_string_literal: true

module LlmAgentRails
  module Json
    module_function

    def clean(value)
      JSON.parse(::ActiveSupport::JSON.encode(value))
    rescue JSON::ParserError, TypeError
      value.as_json
    end
  end
end
