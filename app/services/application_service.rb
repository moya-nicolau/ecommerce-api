# frozen_string_literal: true

class ApplicationService
  attr_reader :errors, :record, :success, :errors_by_attributes

  class_attribute :model_name

  def self.service_for(model_name)
    self.model_name = model_name.to_s.classify
  end

  def initialize(parameters = {})
    @parameters = parameters

    @success = false
    @errors = []
  end

  def create
    record = model.new(@parameters)

    save_record(record)
  end

  def update(id)
    record = model.find(id)

    record.assign_attributes(@parameters)

    save_record(record)
  end

  def destroy(id)
    record = model.find(id)

    return discard(record) if record.respond_to?(:discard!)

    if record.destroy
      @success = true
    else
      @success = false
      @errors = record.errors.full_messages
    end
  end

  def discard(record)
    if record.discard!
      @success = true
    else
      @success = false
      @errors = record.errors.full_messages
    end
  end

  def success?
    @success
  end

  private

  def model
    self.class.model_name.constantize
  end

  def save_record(record)
    if record.save
      @success = true
      @record = record.reload
    else
      @success = false
      @errors = record.errors.full_messages.uniq
      @errors_by_attributes = record.errors.messages.dup.transform_values! { |v| v.uniq }
    end
  end
end
