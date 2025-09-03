# frozen_string_literal: true
Llm::Agent::Rails::Engine.routes.draw do
  post "step", to: "chat#step"
end
