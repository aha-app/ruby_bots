module RubyBots
  class Bot < Tool
    attr_accessor :tools

    def initialize(name:, description:, tools:)
      @tools = tools
      super(name: name, description: description)
    end

    private

    def run(inputs)
      raise NotImplementedError
    end
  end
end