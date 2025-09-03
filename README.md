# llm-agent-rails

Rails engine for **Llm-powered slot filling and tool orchestration**.  
Mount an endpoint, register tools (JSON Schema + handler), and let an Llm collect missing fields and call your Ruby code safely.

## Install

Add to your Gemfile:
```ruby
gem "llm-agent-rails", "~> 0.1"
```

Bundle:
```bash
bundle install
```

Run the installer:
```bash
rails g llm:agent:install
```
This will:
- Create `config/initializers/llm_agent.rb`
- Mount the engine at `/llm/agent`

## Quick test (cURL)

```bash
curl -X POST http://localhost:3000/llm/agent/step   -H "Content-Type: application/json"   -d '{
    "thread_id":"demo-thread",
    "messages":[{"role":"user","content":"Open a ticket: Apple Pay checkout keeps failing on mobile."}]
  }'
```

## Register a tool (example)

Create `app/llm_tools/tickets.rb`:
```ruby
module LlmTools
  CREATE_TICKET_V1 = {
    type: "object", additionalProperties: false,
    properties: {
      title:       { type: "string" },
      description: { type: "string" },
      priority:    { type: "string", enum: %w[low medium high] },
      assignee_id: { type: "string" }
    },
    required: %w[title description priority]
  }

  def self.register!(registry)
    registry.register!(
      name: "create_ticket", version: "v1",
      schema: CREATE_TICKET_V1,
      description: "Create a support ticket.",
      handler: ->(args, ctx) {
        key = Llm::Agent::Rails::Idempotency.generate(thread_id: ctx[:thread_id])
        ticket = Ticket.create!(
          org_id: ctx[:tenant_id],
          user_id: ctx[:actor_id],
          idempotency_key: key,
          title: args["title"],
          description: args["description"],
          priority: args["priority"],
          assignee_id: args["assignee_id"]
        )
        { id: ticket.id, title: ticket.title, priority: ticket.priority, key: key }
      }
    )
  end
end
```

Register it in `config/initializers/llm_agent.rb`:
```ruby
# After Llm::Agent::Rails.configure block
require Rails.root.join("app/llm_tools/tickets")
LlmTools.register!(Llm::Agent::Rails.config[:registry])
```

## How it works

- **Registry**: Define tools (name/version/schema/description/handler).
- **Validators**: JSON Schema validation (`json_schemer`) before calling handlers.
- **Idempotency**: Generate a per-thread key to prevent duplicate creates.
- **Orchestrator**: Coordinates conversation, asks for missing fields, executes tools.
- **Adapter**: OpenAI adapter (supports `openai ~> 0.21`, `chat.completions.create`).
- **Store**: Memory store for tool-result messages (swap for Redis in prod).

## Routes

The engine exposes:
```
POST /llm/agent/step
```
(If you change the mount point, this path changes accordingly.)

## Config

Edit `config/initializers/llm_agent.rb`:
```ruby
Llm::Agent::Rails.configure do |c|
  c[:model]       = "gpt-4o-mini"
  c[:temperature] = 0
  c[:store]       = Llm::Agent::Rails::Store::Memory.new
  c[:registry]    = Llm::Agent::Rails::Registry.new
end
```

## License
MIT
