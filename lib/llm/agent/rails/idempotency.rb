# frozen_string_literal: true

module Llm
  module Agent
    module Rails
      module Idempotency
        def self.generate(thread_id:)
          LlmFillin::Idempotency.generate(thread_id: thread_id)
        end
      end
    end
  end
end
