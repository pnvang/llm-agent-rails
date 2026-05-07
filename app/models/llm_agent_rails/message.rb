# frozen_string_literal: true

module LlmAgentRails
  class Message < ActiveRecord::Base
    self.table_name = "llm_agent_rails_messages"

    belongs_to :llm_agent_rails_thread,
               class_name: "LlmAgentRails::Thread",
               inverse_of: :messages

    validates :role, :content, presence: true
  end
end
