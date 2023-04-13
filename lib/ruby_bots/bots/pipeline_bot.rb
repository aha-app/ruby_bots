module RubyBots
  class PipelineBot < Bot
    DEFAULT_DESCRIPTION = "This bot will utilize all of its tools in a syncronouse pipeline based on the order the tools are provided."
    
    def initialize(name: "Pipeline bot", description: DEFAULT_DESCRIPTION, tools:)
      super(name: name, description: description, tools: tools)
    end

    private
      
    def run(input)
      tools.each do |tool|
        input = tool.run(input)
      end

      input
    end
  end
end