module RubyBots
  class Bot < Tool
    attr_accessor :tools

    def initialize(name:, description:, tools:)
      @tools = tools
      super(name: name, description: description)
    end

    def run(inputs)
      raise NotImplementedError
    end
  end
end