# frozen_string_literal: true

module LlmAgentRails
  class IntakeRunner
    attr_reader :intake_class, :adapter

    def initialize(intake_class:, adapter: nil, idempotency_store: nil)
      @intake_class = intake_class
      @adapter = adapter || LlmAgentRails.config.adapter_instance
      @configured_idempotency_store = idempotency_store
    end

    def step(thread_id:, message:, context: {}, confirm: nil)
      thread = find_or_create_thread(thread_id)
      context = normalize_context(context).merge(thread_id: thread.external_id)
      persist_message(thread, "user", message) if message.present?

      result = orchestrator(thread).step(
        message,
        state: thread.state || {},
        context: context,
        confirm: cast_confirm(confirm)
      )

      persist_result(thread, result)
      ApiResult.new(result: result, thread: thread)
    end

    private

    def orchestrator(thread)
      LlmFillin::Orchestrator.new(
        workflow: intake_class.workflow,
        adapter: adapter,
        idempotency: idempotency_store(thread)
      )
    end

    def idempotency_store(thread)
      return @configured_idempotency_store if @configured_idempotency_store
      return LlmAgentRails.config.idempotency_store if LlmAgentRails.config.idempotency_store

      ActiveRecordIdempotencyStore.new(thread: thread, intake_id: intake_class.intake_id)
    end

    def find_or_create_thread(thread_id)
      Thread.find_or_create_by!(external_id: thread_id, intake_id: intake_class.intake_id)
    end

    def persist_result(thread, result)
      thread.update!(
        state: Json.clean(result.state),
        status: result.status.to_s
      )

      persist_slots(thread, result)
      persist_message(thread, "assistant", result.message) if LlmAgentRails.config.persist_messages && result.message.present?
      persist_execution(thread, result) if result.execution
    end

    def persist_slots(thread, result)
      known_names = result.slots.keys.map(&:to_s) | result.missing_slots.map(&:to_s) | result.invalid_slots.keys.map(&:to_s)

      known_names.each do |name|
        slot = SlotValue.find_or_initialize_by(llm_agent_rails_thread: thread, name: name)
        slot.value = Json.clean(slot_value(result.slots, name))
        slot.status = slot_status(name, result)
        slot.error_messages = Json.clean(slot_value(result.invalid_slots, name) || [])
        slot.save!
      end
    end

    def slot_value(values, name)
      return values[name.to_sym] if values.key?(name.to_sym)
      return values[name] if values.key?(name)

      nil
    end

    def persist_message(thread, role, content)
      return unless LlmAgentRails.config.persist_messages

      Message.create!(
        llm_agent_rails_thread: thread,
        role: role,
        content: content.to_s
      )
    end

    def persist_execution(thread, result)
      record = Execution.find_or_initialize_by(idempotency_key: result.idempotency_key)
      record.llm_agent_rails_thread = thread
      record.intake_id = intake_class.intake_id
      record.status = result.execution.status.to_s
      record.result = Json.clean(result.execution_result)
      record.error_message = result.execution.error&.message
      record.save!
    end

    def slot_status(name, result)
      return "invalid" if result.invalid_slots.key?(name.to_sym) || result.invalid_slots.key?(name)
      return "missing" if result.missing_slots.map(&:to_s).include?(name.to_s)

      "filled"
    end

    def normalize_context(context)
      raw = context || {}
      raw = raw.to_unsafe_h if raw.respond_to?(:to_unsafe_h)
      raw.deep_symbolize_keys
    end

    def cast_confirm(value)
      return nil if value.nil?
      return value if value == true || value == false

      ActiveModel::Type::Boolean.new.cast(value)
    end
  end

  class ApiResult
    attr_reader :result, :thread

    def initialize(result:, thread:)
      @result = result
      @thread = thread
    end

    def to_h
      {
        status: result.status,
        assistant_message: result.message,
        slots: Json.clean(result.slots),
        missing_slots: result.missing_slots,
        invalid_slots: Json.clean(result.invalid_slots),
        ready_to_confirm: result.ready_to_confirm?,
        ready_to_execute: result.ready_to_execute?,
        executed: result.executed?,
        execution_result: Json.clean(result.execution_result),
        idempotency_key: result.idempotency_key,
        thread_id: thread.external_id
      }
    end
  end
end
