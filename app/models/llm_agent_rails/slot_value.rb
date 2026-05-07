# frozen_string_literal: true

module LlmAgentRails
  class SlotValue < ActiveRecord::Base
    self.table_name = "llm_agent_rails_slot_values"

    belongs_to :llm_agent_rails_thread,
               class_name: "LlmAgentRails::Thread",
               inverse_of: :slot_values

    validates :name, :status, presence: true
    validates :name, uniqueness: { scope: :llm_agent_rails_thread_id }
  end
end
