# frozen_string_literal: true

module LlmAgentRails
  class ActiveRecordIdempotencyStore
    def initialize(thread:, intake_id:)
      @thread = thread
      @intake_id = intake_id
    end

    def fetch(key)
      record = Execution.find_by(idempotency_key: key)
      return unless record&.completed?

      LlmFillin::Execution.completed(idempotency_key: key, result: record.result)
    end

    def store(key, execution)
      record = Execution.find_or_initialize_by(idempotency_key: key)
      record.llm_agent_rails_thread = @thread
      record.intake_id = @intake_id
      record.status = execution.status.to_s
      record.result = Json.clean(execution.result)
      record.error_message = execution.error&.message
      record.save!
      record
    end
  end
end
