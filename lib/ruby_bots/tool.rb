module RubyBots
  class Tool
    attr_accessor :name, :description
    
    def initialize(name:, description:)
      @name = name
      @description = description
    end

    def validate_inputs(inputs)
      raise NotImplementedError
    end

    def run(inputs)
      raise NotImplementedError
    end

    def response(inputs)
      validate_inputs(inputs)
      run(inputs)
    end
  end
end