require 'openai'

module RubyBots
  # Tool for connecting to Open AI. Use this tool to connect to Open AI and get a response.
  # the default model is gpt-4, it can be altered by overriding the default_params method.
  class OpenAITool < Tool
    DEFAULT_DESCRIPTION = 'This tool will use open ai to determine the output.'.freeze

    def initialize(name: 'OpenAI Tool', description: DEFAULT_DESCRIPTION)
      super(name:, description:)
    end

    def client
      @client ||= OpenAI::Client.new(access_token: RubyBots.config.openai_api_key)
    end

    def default_params
      {
        model: 'gpt-3.5-turbo',
        temperature: 0
      }
    end

    def system_instructions
      'You are a helpful assistant.'
    end

    private

    def run(input)
      params = {
        messages: [
          { role: :system, content: system_instructions },
          { role: :user, content: input }
        ]
      }.merge(default_params)

      response = client.chat(parameters: params)

      response.dig('choices', 0, 'message', 'content')
    end
  end
end
