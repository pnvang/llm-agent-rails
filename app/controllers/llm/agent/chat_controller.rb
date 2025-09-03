# frozen_string_literal: true
module Llm
  module Agent
    class ChatController < ActionController::Base
      protect_from_forgery with: :null_session

      def step
        messages  = params.require(:messages)
        thread_id = params[:thread_id] || "http-#{request.request_id}"

        ctx = {
          tenant_id: params[:tenant_id] || "demo-org",
          actor_id:  params[:actor_id]  || "demo-user",
          thread_id: thread_id
        }

        adapter = ::LLM::Agent::Rails::Adapters::OpenAIAdapter.new(
          api_key: ENV.fetch("OPENAI_API_KEY"),
          model:    ::LLM::Agent::Rails.config[:model],
          temperature: ::LLM::Agent::Rails.config[:temperature]
        )

        orch = ::LLM::Agent::Rails::Orchestrator.new(
          adapter:  adapter,
          registry: ::LLM::Agent::Rails.config[:registry],
          store:    ::LLM::Agent::Rails.config[:store]
        )

        outcome = orch.step(
          thread_id: ctx[:thread_id],
          tenant_id: ctx[:tenant_id],
          actor_id:  ctx[:actor_id],
          messages:  messages
        )

        render json: outcome
      rescue ActionController::ParameterMissing => e
        render json: { error: e.message }, status: :bad_request
      rescue => e
        render json: { error: e.class.name, message: e.message }, status: :internal_server_error
      end
    end
  end
end
