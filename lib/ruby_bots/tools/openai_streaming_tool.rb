module RubyBots
  class OpenAIStreamingTool < OpenAIChatTool
    def run(input, &block)
      @messages = [
        { role: :system, content: system_instructions },
        { role: :user, content: input }
      ]

      client.chat(
        parameters: {
          messages: @messages,
          model: 'gpt-4',
          temperature: 0.7,
          stream: stream_proc
        }
      )
    end

    def stream_proc
      proc do |chunk, _bytesize|
        print chunk.dig('choices', 0, 'delta', 'content')
      end
    end
  end
end
