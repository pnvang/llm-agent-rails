# frozen_string_literal: true

require "rails/generators"

module LlmAgentRails
  module Generators
    class IntakeGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      argument :slots, type: :array, default: [], banner: "name:string email:string"

      def create_intake
        template "intake.rb.tt", "app/llm_intakes/#{file_name}_intake.rb"
      end

      private

      def class_name
        "#{super.sub(/Intake\z/, '')}Intake"
      end

      def slot_lines
        slots.map do |definition|
          name, type = definition.split(":", 2)
          type ||= "string"
          options = ["type: :#{type}", "required: true"]
          options << "format: :email" if name == "email"
          "  slot :#{name}, #{options.join(', ')}"
        end.join("\n")
      end
    end
  end
end
