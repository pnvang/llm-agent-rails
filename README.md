# llm-agent-rails

**Rails engine for LLM‑powered agents — slot filling, tool orchestration, and safe backend execution.**  
Turn chat into validated function calls using JSON‑Schema, then run your Ruby handlers with idempotency.

---

## What this gem gives you

- A mountable endpoint: `POST /llm/agent/step` that talks to an LLM.
- **Slot filling**: the model asks for missing fields until a tool call is ready.
- **Tool registry**: register functions (name+version+schema+handler) the LLM can call.
- **Validation**: arguments are validated with `json_schemer` before your handler runs.
- **Idempotency**: unique per‑thread keys for safe “create” operations.
- **Adapter**: OpenAI adapter using the `openai ~> 0.21` Ruby SDK.
- **Memory store**: persists tool results per `thread_id` (swap for Redis in prod).
- **Generators**:
  - `rails g llm:agent:install` (initializer + mount routes)
  - `rails g llm:agent:tickets_demo` (optional demo tool + migration)

---

## Install

Add to your Gemfile:

```ruby
gem "llm-agent-rails", "~> 0.1"
```

Then:

```bash
bundle install
bin/rails g llm:agent:install
# mounts the engine at /llm/agent and creates config/initializers/llm_agent.rb
```

Optional demo (creates a Ticket model/tool so you can see tool-calling end‑to‑end):

```bash
bin/rails g llm:agent:tickets_demo
bin/rails db:migrate
```

Configure your API key:

```bash
export OPENAI_API_KEY=sk-...
```

Run the app:

```bash
bin/rails s
```

---

## API — talk to the agent

`POST /llm/agent/step`

**Body**
```json
{
  "thread_id": "demo-123",
  "messages": [
    { "role": "user", "content": "Open a ticket for checkout failing on Apple Pay" }
  ]
}
```

- `thread_id` keeps tool state & idempotency consistent across turns.
- `messages` is the chat transcript (array of `{role, content}`).

**Response**

One of:
```json
{ "type": "assistant", "text": "a clarifying question or confirmation..." }
```
or
```json
{ "type": "tool_ran", "tool_name": "create_ticket", "result": { "id": 42, "title": "..." } }
```

Errors look like:
```json
{ "error": "BadRequest", "message": "messages is required (array of {role, content})" }
```

---

## Example conversations

### A. Client-managed transcript (simple)

Send the **entire transcript each POST** with the same `thread_id`.

```bash
curl -X POST http://localhost:3000/llm/agent/step   -H "Content-Type: application/json"   -d '{
    "thread_id": "demo-123",
    "messages": [
      { "role": "user", "content": "Open a ticket for checkout failing on Apple Pay" },
      { "role": "assistant", "content": "I can help with that! What is the description?" },
      { "role": "user", "content": "Description: iOS 17 checkout fails with tokenization error. Priority high." },
      { "role": "assistant", "content": "Ill create a ticket with the following details:\n\n- **Title**: Checkout failing on Apple Pay\n- **Description**: iOS 17 checkout fails with tokenization error.\n- **Priority**: High\n\nIs there a specific category or team this ticket should be assigned to?"},
      { "role": "user", "content": "Assign to the mobile team." }
    ]
  }'
```

If you **haven’t registered a tool**, you’ll receive `{"type":"assistant","text":"..."}` — a helpful structured summary.

### B. With a tool registered (end‑to‑end create)

1) Use the demo generator:

```bash
bin/rails g llm:agent:tickets_demo
bin/rails db:migrate
```

This adds `app/llm_tools/tickets.rb` and registers a `create_ticket_v1` tool with JSON Schema validation and idempotency.

2) Try again. Once all required fields are collected, the response includes the tool result:

```json
{
  "type": "tool_ran",
  "tool_name": "create_ticket",
  "result": { "id": 123, "title": "Checkout failing on Apple Pay", "priority": "high", "key": "chat-demo-123-7a3c9e" }
}
```

---

## How it works

- **Orchestrator**: supplies tools to the model, loops until enough data is collected, then chooses exactly one tool to run.
- **Registry**: your functions (name+version+schema+handler).
- **Validators**: rejects bad inputs before your code runs.
- **Idempotency**: generates `chat-<thread>-<hex>`, pass to your creates.
- **Store**: remembers prior tool results by `thread_id` (swap to Redis).

---

## Environment

- `OPENAI_API_KEY` must be set.
- Ruby ≥ 3.1, Rails ≥ 7.0.

---

## License

MIT
