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
      @@input_validators.each do |validator|
        validator.call(input)
      end
      
      output = run(input)
      
      @@output_validators.each do |validator|
        validator.call(output)
      end
    end
    
    private 

    def run(inputs)
      raise NotImplementedError
    end
  end
end