# frozen_string_literal: true
module Llm
  module Agent
    module Rails
      class Validators
        def self.validate!(schema, args)
          schemer = JSONSchemer.schema(schema)
          errors = schemer.validate(args).to_a
          raise ArgumentError, "Schema validation failed: #{errors}" if errors.any?
        end
      end
    end
  end
end
