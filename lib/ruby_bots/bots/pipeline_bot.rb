module RubyBots
  class PipelineBot < Bot
    DEFAULT_DESCRIPTION = "This bot will utilize all of its tools in a syncronouse pipeline based on the order the tools are provided."
    
    def initialize(name: "Pipeline bot", description: DEFAULT_DESCRIPTION, tools:)
      @name = name
      @description = description
      @tools = tools
    end
      
    def run(inputs)
      tools.each do |tool|
        inputs = tool.run(inputs)
      end

      inputs
    end
  end
end