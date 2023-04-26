module RubyBots
  class OpenAIChatTool < OpenAITool
    include RubyBots::Chattable

    DEFAULT_DESCRIPTION = 'This tool will use OpenAI to set up a chat interface with the user. It will chat responses to the user to clarify their request.'.freeze

    def initialize(name: 'OpenAI chat tool', description: DEFAULT_DESCRIPTION)
      super(name:, description:)
    end

    def system_instructions
      <<~PROMPT
        You are a helpful assistant that is chatting with a user. You can ask the user to provide more information
        if it helps you determine the correct response.
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

        input = yield(bot_output)

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
