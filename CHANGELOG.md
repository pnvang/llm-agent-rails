# Changelog

## 0.2.0

- Repositioned the engine around Rails-native AI intake forms and slot-filling workflows.
- Added `LlmAgentRails::Intake` for Rails app intake classes backed by `llm-fillin` workflows.
- Added `POST /intakes/:id/step` for JSON intake conversations.
- Added ActiveRecord persistence for intake threads, messages, slot values, and executions.
- Added idempotent submit execution backed by persisted execution records.
- Added fake-adapter request flow for tests and dummy app behavior with no API keys.
- Added `llm_agent_rails:install`, `llm_agent_rails:intake`, and `llm_agent_rails:migrations` generators.
- Kept the old `Llm::Agent::Rails` namespace and legacy `/step` endpoint where practical.
- Moved provider access behind `llm-fillin` adapters; OpenAI is no longer a direct runtime dependency.

## 0.1.2

- Original Rails engine for LLM agent/tool-call orchestration.
