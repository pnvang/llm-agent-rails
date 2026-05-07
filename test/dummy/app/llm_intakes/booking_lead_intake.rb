# frozen_string_literal: true

class BookingLeadIntake < LlmAgentRails::Intake
  description "Collect event details for a booking lead"

  slot :name, type: :string, required: true
  slot :email, type: :string, required: true, format: :email
  slot :event_date, type: :date, required: true
  slot :start_time, type: :string, required: true
  slot :end_time, type: :string, required: true
  slot :location, type: :string, required: true
  slot :guest_count, type: :integer, required: false
  slot :package, type: :string, enum: ["Gold", "Platinum", "Emerald"], required: false

  confirm_before_submit true

  def submit(values, context:)
    BookingLead.create!(values.merge(idempotency_key: context.fetch(:idempotency_key)))
  end
end
