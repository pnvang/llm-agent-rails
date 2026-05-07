# frozen_string_literal: true

require "test_helper"

class IntakesControllerTest < ActionDispatch::IntegrationTest
  setup do
    reset_llm_agent_rails_records
  end

  test "runs a fake intake conversation through confirmation and executes once" do
    post "/llm/intakes/booking_lead/step",
         params: {
           thread_id: "booking-thread-1",
           message: "name: Mina Park"
         },
         as: :json

    assert_response :success
    first = response.parsed_body
    assert_equal "needs_clarification", first.fetch("status")
    assert_equal "What is the email?", first.fetch("assistant_message")
    assert_equal ["email", "event_date", "start_time", "end_time", "location"], first.fetch("missing_slots")
    assert_equal "booking-thread-1", first.fetch("thread_id")

    post "/llm/intakes/booking_lead/step",
         params: {
           thread_id: "booking-thread-1",
           message: "email: mina@example.com event_date: 2026-06-20 start_time: 6 PM end_time: 10 PM location: Community Hall guest_count: 75 package: Gold"
         },
         as: :json

    assert_response :success
    second = response.parsed_body
    assert_equal "needs_confirmation", second.fetch("status")
    assert_equal true, second.fetch("ready_to_confirm")
    assert_equal false, second.fetch("executed")
    assert_match(/Please confirm:/, second.fetch("assistant_message"))
    assert_equal 0, BookingLead.count

    post "/llm/intakes/booking_lead/step",
         params: {
           thread_id: "booking-thread-1",
           message: "yes"
         },
         as: :json

    assert_response :success
    third = response.parsed_body
    assert_equal "executed", third.fetch("status")
    assert_equal true, third.fetch("executed")
    assert_equal 1, BookingLead.count
    assert_equal third.fetch("idempotency_key"), BookingLead.first.idempotency_key

    post "/llm/intakes/booking_lead/step",
         params: {
           thread_id: "booking-thread-1",
           message: "yes"
         },
         as: :json

    assert_response :success
    retry_response = response.parsed_body
    assert_equal "executed", retry_response.fetch("status")
    assert_equal true, retry_response.fetch("executed")
    assert_equal 1, BookingLead.count
    assert_equal third.fetch("idempotency_key"), retry_response.fetch("idempotency_key")
  end

  test "does not execute invalid values" do
    post "/llm/intakes/booking_lead/step",
         params: {
           thread_id: "booking-thread-invalid",
           message: "name: Mina email: invalid event_date: 2026-06-20 start_time: 6 PM end_time: 10 PM location: Hall"
         },
         as: :json

    assert_response :success
    body = response.parsed_body
    assert_equal "invalid", body.fetch("status")
    assert_equal({ "email" => ["must be a valid email"] }, body.fetch("invalid_slots"))
    assert_equal 0, BookingLead.count
  end
end
