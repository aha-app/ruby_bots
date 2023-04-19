module RubyBots
  # Class to provide a router to different tools.
  # This bot connects to the OpenAI API and uses gpt-4 by default to choose a proper tool to route the user's input.
  # The bot will only select and use one tool by default.
  class RouterBot < OpenAIBot
    DEFAULT_DESCRIPTION = <<~DESCRIPTION.strip_heredoc
      This bot will route the user's input to the appropriate tool. It will only select and use one tool."
    DESCRIPTION

    def initialize(tools:, name: 'Router bot', description: DEFAULT_DESCRIPTION)
      super(tools:, name:, description:)
    end

    def system_instructions
      <<~PROMPT
        You are an assistant helping to route a user's input to the correct tool.
        You can use the following tools (name - description):
        #{tools.map { |t| "#{t.name} - #{t.description}" }.join('\n')}

        Return only the name of the tool that best fits the user's request.
      PROMPT
    end

    private

    def run(input)
      params = initial_params(input)

      response = client.chat(parameters: params)

      response_text = response.dig('choices', 0, 'message', 'content')

      selected_tool = tools.find { |t| t.name == response_text }

      raise RubyBots::InvalidOutputError, 'invalid tool name' unless selected_tool

      selected_tool.response(input)
    end

    def initial_params(input)
      {
        messages: [
          { role: :system, content: system_instructions },
          { role: :user, content: input }
        ]
      }.merge(default_params)
    end
  end
end
