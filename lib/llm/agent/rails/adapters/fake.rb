# frozen_string_literal: true

module LlmAgentRails
  module Adapters
    class Fake < LlmFillin::Adapters::Base
      FIELD_SEPARATOR = /[,;\n]/
      EMAIL = /\b[^@\s,;]+@[^@\s,;]+\.[^@\s,;]+\b/
      ISO_DATE = /\b\d{4}-\d{2}-\d{2}\b/

      def initialize(responses: nil, extractor: nil)
        @responses = responses&.dup
        @extractor = extractor
      end

      def extract(workflow:, message:, slots:, context:)
        return @extractor.call(workflow: workflow, message: message, slots: slots, context: context) if @extractor
        return @responses.shift if @responses&.any?

        extract_from_message(workflow, message.to_s)
      end

      private

      def extract_from_message(workflow, message)
        extracted = key_value_slots(workflow, message)
        fill_email_slots(workflow, message, extracted)
        fill_date_slots(workflow, message, extracted)
        fill_guest_count(workflow, message, extracted)
        extracted
      end

      def key_value_slots(workflow, message)
        labels = slot_labels(workflow)
        return {} if labels.empty?

        pattern = /
          (?<label>#{labels.keys.map { |label| Regexp.escape(label) }.join("|")})
          \s*(?::|=|\bis\b)\s*
          (?<value>.*?)
          (?=\s+(?:#{labels.keys.map { |label| Regexp.escape(label) }.join("|")})\s*(?::|=|\bis\b)|\z)
        /ix

        message.scan(pattern).each_with_object({}) do |(label, value), out|
          slot_name = labels[label.downcase]
          out[slot_name] = clean_value(value)
        end
      end

      def fill_email_slots(workflow, message, extracted)
        return unless (email = message[EMAIL])

        workflow.slots.each do |slot|
          next unless slot.format == :email || slot.name == :email

          extracted[slot.name] ||= email
        end
      end

      def fill_date_slots(workflow, message, extracted)
        return unless (date = message[ISO_DATE])

        workflow.slots.each do |slot|
          next unless slot.type == :date

          extracted[slot.name] ||= date
        end
      end

      def fill_guest_count(workflow, message, extracted)
        return unless workflow.slots[:guest_count]
        return unless (match = message.match(/\b(\d+)\s+guests?\b/i))

        extracted[:guest_count] ||= match[1]
      end

      def slot_labels(workflow)
        workflow.slots.each_with_object({}) do |slot, labels|
          labels[slot.name.to_s.downcase] = slot.name
          labels[slot.name.to_s.tr("_", " ").downcase] = slot.name
        end
      end

      def clean_value(value)
        value.to_s.strip.sub(/\A["']/, "").sub(/["']\z/, "").split(FIELD_SEPARATOR).first.to_s.strip
      end
    end
  end
end

module Llm
  module Agent
    module Rails
      module Adapters
        Fake = ::LlmAgentRails::Adapters::Fake unless const_defined?(:Fake)
      end
    end
  end
end
