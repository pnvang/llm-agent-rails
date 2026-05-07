# frozen_string_literal: true
Llm::Agent::Rails::Engine.routes.draw do
  post "intakes/:id/step", to: "intakes#step", as: :intake_step

  # Backwards-compatible 0.1 chat/tool endpoint.
  post "step", to: "chat#step"
end
