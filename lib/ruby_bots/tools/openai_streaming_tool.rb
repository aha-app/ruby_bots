module RubyBots
  class OpenAIStreamingTool < OpenAIChatTool
    def initialize(name: 'OpenAI Streaming Tool', description: DEFAULT_DESCRIPTION, messages: nil)
      @messages = messages || []
      super(name:, description:)
    end

    def response
      super('')
    end

    private

    def run(input)
      messages = [
        { role: :system, content: system_instructions }
      ] + @messages
      unless input.empty?
        messages += [
          { role: :user, content: input }
        ]
      end

      client.chat(
        parameters: {
          messages:,
          stream: stream_proc
        }.merge(default_params)
      )
    end

    def stream_proc
      proc do |chunk, _bytesize|
        print chunk.dig('choices', 0, 'delta', 'content')
      end
    end
  end
end
