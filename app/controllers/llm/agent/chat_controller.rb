# frozen_string_literal: true
module Llm
  module Agent
    class ChatController < ActionController::Base
      protect_from_forgery with: :null_session

      def step
        raw = params[:messages]
        if raw.nil?
          return render json: { error: "BadRequest", message: "messages is required (array of {role, content})" }, status: :bad_request
        end

        # Coerce into an array of message hashes Rails/OpenAI will accept.
        messages =
          Array.wrap(raw).map do |m|
            # If the client sent a JSON string, parse it.
            m = JSON.parse(m) rescue m

            # If it's ActionController::Parameters, unfurl to a plain hash.
            m = m.to_unsafe_h if m.respond_to?(:to_unsafe_h)
            m = m.to_h        if m.respond_to?(:to_h) && !m.is_a?(Hash)

            # Keep only role/content, as OpenAI expects
            {
              "role"    => m["role"] || m[:role],
              "content" => m["content"] || m[:content]
            }
          end

        thread_id = params[:thread_id] || "http-#{request.request_id}"
        ctx = {
          tenant_id: params[:tenant_id] || "demo-org",
          actor_id:  params[:actor_id]  || "demo-user",
          thread_id: thread_id
        }

        adapter = ::Llm::Agent::Rails::Adapters::OpenAIAdapter.new(
          api_key: ENV.fetch("OPENAI_API_KEY"),
          model:    ::Llm::Agent::Rails.config[:model],
          temperature: ::Llm::Agent::Rails.config[:temperature]
        )

        orch = ::Llm::Agent::Rails::Orchestrator.new(
          adapter:  adapter,
          registry: ::Llm::Agent::Rails.config[:registry],
          store:    ::Llm::Agent::Rails.config[:store]
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
