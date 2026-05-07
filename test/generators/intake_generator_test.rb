# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require "rails/generators/test_case"
require "generators/llm_agent_rails/intake/intake_generator"

class IntakeGeneratorTest < Rails::Generators::TestCase
  tests LlmAgentRails::Generators::IntakeGenerator
  destination File.expand_path("llm_agent_rails_intake_generator", Dir.tmpdir)

  setup :prepare_destination

  test "creates a usable intake class" do
    run_generator %w[BookingLead name:string email:string event_date:date location:string]

    assert_file "app/llm_intakes/booking_lead_intake.rb" do |content|
      assert_match "class BookingLeadIntake < LlmAgentRails::Intake", content
      assert_match "slot :name, type: :string, required: true", content
      assert_match "slot :email, type: :string, required: true, format: :email", content
      assert_match "slot :event_date, type: :date, required: true", content
      assert_match "confirm_before_submit true", content
    end
  end
end
