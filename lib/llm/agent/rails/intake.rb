# frozen_string_literal: true

module LlmAgentRails
  class Intake
    @descendants = []

    class << self
      attr_accessor :intake_description, :slot_definitions, :confirmation_required

      def inherited(subclass)
        super
        descendants << subclass
        subclass.slot_definitions = []
        subclass.confirmation_required = false
      end

      def descendants
        @descendants ||= []
      end

      def description(text = nil)
        self.intake_description = text if text
        intake_description
      end

      def slot(name, **options)
        self.slot_definitions += [[name.to_sym, options]]
        @workflow = nil
      end

      def confirm_before_submit(value = nil)
        self.confirmation_required = value unless value.nil?
        @workflow = nil
        confirmation_required
      end

      def confirm_before_submit?
        !!confirmation_required
      end

      def intake_id
        name.demodulize.sub(/Intake\z/, "").underscore
      end

      def workflow
        @workflow ||= build_workflow
      end

      def register!
        LlmAgentRails.registry.register(self)
      end

      private

      def build_workflow
        intake_class = self

        LlmFillin::Workflow.define(intake_id) do
          description intake_class.description if intake_class.description

          intake_class.slot_definitions.each do |slot_name, options|
            slot slot_name, **options
          end

          confirm_before_submit intake_class.confirm_before_submit?

          handler do |values, context|
            output = intake_class.new.submit(values, context: context)
            Json.clean(output)
          end
        end
      end
    end

    def submit(_values, context:)
      raise NotImplementedError, "#{self.class.name} must implement #submit(values, context:)"
    end
  end
end

module Llm
  module Agent
    module Rails
      Intake = ::LlmAgentRails::Intake unless const_defined?(:Intake)
    end
  end
end
