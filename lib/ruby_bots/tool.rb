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

    def self.validate_input(method)
      @input_validators ||= []
      @input_validators << method
    end

    def self.validate_output(method)
      @output_validators ||= []
      @output_validators << method
    end

    def response(input)
      self.class.input_validators ||= []
      self.class.input_validators.each do |validator|
        send(validator, input)
      end
      
      if @errors.empty?
        output = run(input)
      else
        raise RubyBots::InvalidInputError.new(errors: @errors)
      end
      
      self.class.output_validators ||= []
      self.class.output_validators.each do |validator|
        send(validator, output)
      end

      if @errors.any?
        raise RubyBots::InvalidOutputError.new(errors: @errors)
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