# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require_relative "dummy/config/environment"
require "rails/test_help"

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

ActiveRecord::Schema.define do
  create_table :llm_agent_rails_threads, force: true do |t|
    t.string :external_id, null: false
    t.string :intake_id, null: false
    t.string :status
    t.json :state
    t.json :context
    t.timestamps
  end

  add_index :llm_agent_rails_threads, [:external_id, :intake_id], unique: true

  create_table :llm_agent_rails_messages, force: true do |t|
    t.references :llm_agent_rails_thread, null: false
    t.string :role, null: false
    t.text :content, null: false
    t.json :payload
    t.timestamps
  end

  create_table :llm_agent_rails_slot_values, force: true do |t|
    t.references :llm_agent_rails_thread, null: false
    t.string :name, null: false
    t.string :status, null: false
    t.json :value
    t.json :error_messages
    t.timestamps
  end

  add_index :llm_agent_rails_slot_values, [:llm_agent_rails_thread_id, :name], unique: true

  create_table :llm_agent_rails_executions, force: true do |t|
    t.references :llm_agent_rails_thread, null: false
    t.string :intake_id, null: false
    t.string :idempotency_key, null: false
    t.string :status, null: false
    t.json :result
    t.text :error_message
    t.timestamps
  end

  add_index :llm_agent_rails_executions, :idempotency_key, unique: true

  create_table :booking_leads, force: true do |t|
    t.string :name
    t.string :email
    t.date :event_date
    t.string :start_time
    t.string :end_time
    t.string :location
    t.integer :guest_count
    t.string :package
    t.string :idempotency_key
    t.timestamps
  end
end

LlmAgentRails.configure do |config|
  config.provider = :fake
  config.adapter = LlmAgentRails::Adapters::Fake.new
  config.registry.clear
  config.intakes_path = Rails.root.join("app/llm_intakes")
end

LlmAgentRails.load_intakes!

class ActiveSupport::TestCase
  parallelize(workers: 1)

  def reset_llm_agent_rails_records
    BookingLead.delete_all
    LlmAgentRails::Execution.delete_all
    LlmAgentRails::SlotValue.delete_all
    LlmAgentRails::Message.delete_all
    LlmAgentRails::Thread.delete_all
  end
end
