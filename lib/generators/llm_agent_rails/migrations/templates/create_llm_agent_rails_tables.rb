# frozen_string_literal: true

class CreateLlmAgentRailsTables < ActiveRecord::Migration[7.0]
  def change
    create_table :llm_agent_rails_threads do |t|
      t.string :external_id, null: false
      t.string :intake_id, null: false
      t.string :status
      t.json :state
      t.json :context
      t.timestamps
    end

    add_index :llm_agent_rails_threads, [:external_id, :intake_id], unique: true, name: "idx_llm_agent_rails_threads_on_external_and_intake"

    create_table :llm_agent_rails_messages do |t|
      t.references :llm_agent_rails_thread, null: false, foreign_key: { to_table: :llm_agent_rails_threads }, index: { name: "idx_llm_agent_rails_messages_on_thread" }
      t.string :role, null: false
      t.text :content, null: false
      t.json :payload
      t.timestamps
    end

    create_table :llm_agent_rails_slot_values do |t|
      t.references :llm_agent_rails_thread, null: false, foreign_key: { to_table: :llm_agent_rails_threads }, index: { name: "idx_llm_agent_rails_slot_values_on_thread" }
      t.string :name, null: false
      t.string :status, null: false
      t.json :value
      t.json :error_messages
      t.timestamps
    end

    add_index :llm_agent_rails_slot_values, [:llm_agent_rails_thread_id, :name], unique: true, name: "idx_llm_agent_rails_slot_values_on_thread_and_name"

    create_table :llm_agent_rails_executions do |t|
      t.references :llm_agent_rails_thread, null: false, foreign_key: { to_table: :llm_agent_rails_threads }, index: { name: "idx_llm_agent_rails_executions_on_thread" }
      t.string :intake_id, null: false
      t.string :idempotency_key, null: false
      t.string :status, null: false
      t.json :result
      t.text :error_message
      t.timestamps
    end

    add_index :llm_agent_rails_executions, :idempotency_key, unique: true
  end
end
