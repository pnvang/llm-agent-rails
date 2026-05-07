# llm-agent-rails

AI intake forms for Rails.

`llm-agent-rails` is a Rails-native layer on top of `llm-fillin` for slot-filling workflows: collect missing fields through conversation, validate before execution, confirm before submit, and run safe Rails backend actions exactly once.

It is built for booking leads, quote requests, onboarding forms, support tickets, and internal admin workflows. It is not a broad agent framework.

## Installation

```ruby
gem "llm-agent-rails"
```

Then:

```bash
bundle install
bin/rails generate llm_agent_rails:install
bin/rails db:migrate
```

The install generator creates:

- `config/initializers/llm_agent_rails.rb`
- `app/llm_intakes/.keep`
- database migrations for intake threads, messages, slot values, and executions
- a route mount example

Mount the engine at `/llm`:

```ruby
mount Llm::Agent::Rails::Engine => "/llm"
```

## Create An Intake

```ruby
# app/llm_intakes/booking_lead_intake.rb
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
    BookingLead.create!(values)
  end
end
```

Or generate one:

```bash
bin/rails generate llm_agent_rails:intake BookingLead name:string email:string event_date:date location:string
```

## Intake Endpoint

`POST /llm/intakes/:id/step`

Input:

```json
{
  "thread_id": "booking-123",
  "message": "name: Mina Park email: mina@example.com",
  "context": { "tenant_id": "acct_1", "actor_id": "user_1" }
}
```

Example response when fields are missing:

```json
{
  "status": "needs_clarification",
  "assistant_message": "What is the event date?",
  "slots": {
    "name": "Mina Park",
    "email": "mina@example.com"
  },
  "missing_slots": ["event_date", "start_time", "end_time", "location"],
  "invalid_slots": {},
  "ready_to_confirm": false,
  "ready_to_execute": false,
  "executed": false,
  "execution_result": null,
  "idempotency_key": "intake-...",
  "thread_id": "booking-123"
}
```

## Confirmation Flow

When all required slots are valid and `confirm_before_submit true` is set, the engine asks for confirmation:

```json
{
  "status": "needs_confirmation",
  "assistant_message": "Please confirm: name: Mina Park, email: mina@example.com, event date: 2026-06-20. Should I submit this?",
  "ready_to_confirm": true,
  "executed": false
}
```

Confirm with the same `thread_id`:

```bash
curl -X POST http://localhost:3000/llm/intakes/booking_lead/step \
  -H "Content-Type: application/json" \
  -d '{"thread_id":"booking-123","message":"yes"}'
```

The response includes the Rails return value:

```json
{
  "status": "executed",
  "assistant_message": "Submitted.",
  "executed": true,
  "execution_result": {
    "id": 42,
    "name": "Mina Park"
  },
  "thread_id": "booking-123"
}
```

## Idempotency

Each submit has a stable idempotency key derived by `llm-fillin`. The engine stores execution records in ActiveRecord and replays completed results when a browser retries the same confirmed thread. Required slots must be valid and confirmation must pass before Rails application code runs.

The generated migrations create:

- `LlmAgentRails::Thread`
- `LlmAgentRails::Message`
- `LlmAgentRails::SlotValue`
- `LlmAgentRails::Execution`

## Provider Configuration

API keys are server-side only and are never exposed to the browser.

The default generated initializer uses the fake adapter:

```ruby
LlmAgentRails.configure do |config|
  config.provider = :fake
  config.adapter = LlmAgentRails::Adapters::Fake.new
end
```

For OpenAI, add `gem "openai"` to your Rails app and configure through `llm-fillin`:

```ruby
LlmAgentRails.configure do |config|
  config.provider = :openai
  config.model = "gpt-4.1-mini"
  config.temperature = 0
  config.adapter = ->(c) {
    LlmFillin::Adapters::OpenAI.new(
      api_key: ENV.fetch("OPENAI_API_KEY"),
      model: c.model,
      temperature: c.temperature
    )
  }
end
```

Any object that implements `#extract(workflow:, message:, slots:, context:)` can be used as an adapter.

## Testing With Fake Adapter

Tests should not make real API calls:

```ruby
LlmAgentRails.configure do |config|
  config.adapter = LlmAgentRails::Adapters::Fake.new
end
```

The fake adapter understands simple `field: value` messages, which makes request specs deterministic.

## Compatibility

The gem name remains `llm-agent-rails`. The old `Llm::Agent::Rails` namespace and `POST /step` endpoint are still present where reasonable for 0.1 compatibility, but the preferred API is intake-oriented:

```ruby
LlmAgentRails::Intake
POST /llm/intakes/:id/step
```

## How This Relates To llm-fillin

`llm-fillin` is the framework-light Ruby core: workflow definitions, slot validation, confirmation, result objects, provider adapters, and idempotent handler execution.

`llm-agent-rails` adds the Rails-native layer: autoloaded intake classes, ActiveRecord persistence, JSON endpoints, Rails generators, and dummy/test patterns.

## Commands

```bash
bundle install
bundle exec rake test
```

Dummy app boot smoke test:

```bash
bundle exec ruby -e 'require_relative "test/dummy/config/environment"; puts Rails.application.class.name'
```

## License

MIT
