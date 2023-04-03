module RubyBots
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

    def self.validate_inputs(method)
      @@input_validators ||= []
      @@input_validators << method
    end

    def self.validate_outputs(method)
      @@output_validators ||= []
      @@output_validators << method
    end

    def response(input)
      @@input_validators ||= []
      @@input_validators.each do |validator|
        send(validator, input)
      end
      
      if @errors.empty?
        output = run(input)
      else
        raise RubyBots::Errors::InvalidInputError.new(errors: @errors)
      end
      
      @@output_validators ||= []
      @@output_validators.each do |validator|
        send(validator, output)
      end

      if @errors.any?
        raise RubyBots::Errors::InvalidOutputError.new(errors: @errors)
      end

      output
    end
    
    private 

    def run(inputs)
      raise NotImplementedError
    end

    def is_json(param)
      JSON.parse(param)
    rescue JSON::ParserError
      errors << "invalid JSON"
    end
  end
end