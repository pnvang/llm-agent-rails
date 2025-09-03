module Llm
  module Agent
    class ChatController < ActionController::Base
      protect_from_forgery with: :null_session

      def step
        render json: { ok: true, echo: params[:messages] }
      end
    end
  end
end
