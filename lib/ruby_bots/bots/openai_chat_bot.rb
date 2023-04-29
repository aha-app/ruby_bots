module RubyBots
  class OpenAIChatBot < OpenAIBot
    include RubyBots::Chattable

    DEFAULT_DESCRIPTION = 'This bot will use OpenAI to determine the appropriate tool and use it. It will also chat responses to the user to clarify their request.'.freeze

    def initialize(tools:, name: 'OpenAI chat bot', description: DEFAULT_DESCRIPTION)
      super(tools:, name:, description:)
    end

    def system_instructions
      <<~PROMPT
        You are an assistant that is chatting with a user and also using tools.
        You can use the following tools (name - description):
        #{tools.map { |t| "#{t.name} - #{t.description}" }.join('\n')}

        Select from the following tools (name - description):
        #{tools.map { |t| "#{t.name} - #{t.description}" }.join('\n')}

        If it is clear that a tool best fits the user's request, return only the tool name and nothing more.
        If no tool clearly matches the user's request respond with questions to help you clarify the user's response.
      PROMPT
    end

    private

    def run(input, &block)
      @messages = [
        { role: :system, content: system_instructions },
        { role: :user, content: input }
      ]

      bot_output = ''

      until ['exit', 'quit', 'q', 'stop', 'bye'].include?(input.chomp.downcase)
        response = client.chat(parameters: params)

        bot_output = response.dig('choices', 0, 'message', 'content')

        @messages << { role: :assistant, content: bot_output }

        if tools.map(&:name).include?(bot_output)
          return tools.find { |t| t.name == bot_output }.response(input)
        end

        input = yield bot_output

        @messages << { role: :user, content: input }
      end

      bot_output
    end

    def params
      {
        messages: @messages
      }.merge(default_params)
    end
  end
end
