module RubyBots
  class OpenAIBot < OpenAITool
    attr_accessor :tools

    DEFAULT_DESCRIPTION = "This bot will use OpenAI to determine the appropriate tool."
    
    def initialize(name: "OpenAI bot", description: DEFAULT_DESCRIPTION, tools:)
      @tools = tools
      super(name: name, description: description)
    end
    
    def run(inputs)
      params = {
        messages: [
          { role: :system, content: system_instructions },
          { role: :user, content: inputs }
        ]
      }.merge(default_params) 

      response = client.chat(parameters: params)

      response.dig("choices", 0, "message", "content")
    end
  end
end