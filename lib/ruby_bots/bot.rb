module RubyBots
  # Base class for all RubyBots bots
  class Bot < Tool
    attr_accessor :tools

    def initialize(tools:, name: 'RubyBots Bot', description: 'This is a RubyBots bot')
      @tools = tools
      super(name:, description:)
    end

    private

    def run(input)
      raise NotImplementedError
    end

    def tool_name?(param)
      errors << 'invalid tool name' unless @tools.map(&:name).include?(param)
    end
  end
end
