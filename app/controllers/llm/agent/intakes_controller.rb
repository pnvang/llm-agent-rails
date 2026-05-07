# frozen_string_literal: true

module Llm
  module Agent
    class IntakesController < ActionController::Base
      protect_from_forgery with: :null_session

      def step
        intake_class = LlmAgentRails.registry.fetch(params.require(:id))
        thread_id = params[:thread_id].presence || "http-#{request.request_id}"
        message = params[:message].to_s
        context = intake_context(thread_id)

        api_result = LlmAgentRails::IntakeRunner.new(intake_class: intake_class).step(
          thread_id: thread_id,
          message: message,
          context: context,
          confirm: params[:confirm]
        )

        render json: api_result.to_h
      rescue KeyError
        render json: {
          error: "NotFound",
          message: "Unknown intake #{params[:id].inspect}",
          available_intakes: LlmAgentRails.registry.ids
        }, status: :not_found
      rescue ActionController::ParameterMissing => e
        render json: { error: "BadRequest", message: e.message }, status: :bad_request
      rescue StandardError => e
        render json: { error: e.class.name, message: e.message }, status: :internal_server_error
      end

      private

      def intake_context(thread_id)
        raw_context = params[:context] || {}
        raw_context = JSON.parse(raw_context) if raw_context.is_a?(String)
        raw_context = raw_context.to_unsafe_h if raw_context.respond_to?(:to_unsafe_h)
        raw_context = raw_context.to_h if raw_context.respond_to?(:to_h)
        symbolized_context = raw_context.symbolize_keys

        symbolized_context.merge(
          tenant_id: params[:tenant_id] || symbolized_context[:tenant_id],
          actor_id: params[:actor_id] || symbolized_context[:actor_id],
          thread_id: thread_id
        ).compact
      rescue JSON::ParserError
        { thread_id: thread_id }
      end
    end
  end
end
