# frozen_string_literal: true
module Llm
  module Agent
    module Rails
      module Adapters
        class OpenAIAdapter
          def initialize(api_key:, model:, temperature: 0)
            @client = ::OpenAI::Client.new(api_key: api_key)
            @model = model
            @temperature = temperature
          end

          def step(system_prompt:, messages:, tools:, tool_results: [])
            response = @client.chat.completions.create(
              model: @model,
              temperature: @temperature,
              messages: [{ role: "system", content: system_prompt }] + messages + tool_results,
              tools: tools,
              tool_choice: "auto"
            )

            choice = response.choices.first
            msg    = choice.message

            tool_calls    = msg.respond_to?(:tool_calls)    ? msg.tool_calls    : nil
            function_call = msg.respond_to?(:function_call) ? msg.function_call : nil
            content       = msg.respond_to?(:content)       ? msg.content       : nil

            { tool_calls: tool_calls, function_call: function_call, content: content }
          end

          def tool_result_message(tool_call_id:, name:, content:)
            { role: "tool", tool_call_id: tool_call_id, name: name, content: content.to_json }
          end
        end
      end
    end
  end
end
