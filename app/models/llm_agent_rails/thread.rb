# frozen_string_literal: true

module LlmAgentRails
  class Thread < ActiveRecord::Base
    self.table_name = "llm_agent_rails_threads"

    has_many :messages,
             class_name: "LlmAgentRails::Message",
             foreign_key: :llm_agent_rails_thread_id,
             dependent: :destroy,
             inverse_of: :llm_agent_rails_thread

    has_many :slot_values,
             class_name: "LlmAgentRails::SlotValue",
             foreign_key: :llm_agent_rails_thread_id,
             dependent: :destroy,
             inverse_of: :llm_agent_rails_thread

    has_many :executions,
             class_name: "LlmAgentRails::Execution",
             foreign_key: :llm_agent_rails_thread_id,
             dependent: :destroy,
             inverse_of: :llm_agent_rails_thread

    validates :external_id, :intake_id, presence: true
    validates :external_id, uniqueness: { scope: :intake_id }
  end
end
