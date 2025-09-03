# frozen_string_literal: true
module Llm
  module Agent
    module Rails
      class Engine < ::Rails::Engine
        isolate_namespace ::Llm::Agent
      end
    end
  end
end
