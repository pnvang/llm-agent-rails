# frozen_string_literal: true

module LlmAgentRails
  class Execution < ActiveRecord::Base
    self.table_name = "llm_agent_rails_executions"

    belongs_to :llm_agent_rails_thread,
               class_name: "LlmAgentRails::Thread",
               inverse_of: :executions

    validates :intake_id, :idempotency_key, :status, presence: true
    validates :idempotency_key, uniqueness: true

    def completed?
      status == "completed" || status == "duplicate"
    end
  end
end
