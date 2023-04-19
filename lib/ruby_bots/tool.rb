module RubyBots
  # Base class for all RubyBots tools and bots
  class Tool
    attr_accessor :name, :description, :errors

    def initialize(name:, description:)
      @name = name
      @description = description
      @errors = []
    end

    class << self
      attr_accessor :input_validators, :output_validators
    end

    def self.validate_input(method)
      @input_validators ||= []
      @input_validators << method
    end

    def self.validate_output(method)
      @output_validators ||= []
      @output_validators << method
    end

    def response(input)
      run_input_validations(input)

      raise RubyBots::InvalidInputError, { errors: @errors } if @errors.any?

      output = run(input)

      run_output_validations(output)

      raise RubyBots::InvalidOutputError, { errors: @errors } if @errors.any?

      output
    end

    private

    def run(input)
      raise NotImplementedError
    end

    def run_input_validations(input)
      self.class.input_validators ||= []
      self.class.input_validators.each do |validator|
        send(validator, input)
      end
    end

    def run_output_validations(output)
      self.class.output_validators ||= []
      self.class.output_validators.each do |validator|
        send(validator, output)
      end
    end

    def json?(param)
      JSON.parse(param)
    rescue JSON::ParserError
      errors << 'invalid JSON'
    rescue TypeError
      errors << 'value is not a String'
    end
  end
end
