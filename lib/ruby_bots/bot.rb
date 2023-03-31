module RubyBots
  class Bot < Tool
    attr_accessor :tools

    def initialize(tools:, **kwargs)
      @tools = tools
      super(**kwargs)
    end

    def operate(inputs)
      raise NotImplementedError
    end
  end
end