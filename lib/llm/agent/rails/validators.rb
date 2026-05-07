# frozen_string_literal: true
module Llm
  module Agent
    module Rails
      class Validators
        def self.validate!(schema, args)
          LlmFillin::Validators.validate!(schema, args)
        end
      end
    end
  end
end
