module RubyBots
  # Class to provide a pipeline of tools to solve a problem.
  # This bot will call the tools provided in order until each tool has responded.
  # The bot will respond with the last tool's response.
  class PipelineBot < Bot
    DEFAULT_DESCRIPTION = <<~DESCRIPTION.strip_heredoc
      This bot will utilize all of its tools in a syncronouse pipeline based on the order the tools are provided."
    DESCRIPTION

    def initialize(tools:, name: 'Pipeline bot', description: DEFAULT_DESCRIPTION)
      super(tools:, name:, description:)
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
