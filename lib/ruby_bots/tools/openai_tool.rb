require 'openai'

module RubyBots
  class OpenAITool < Tool
    attr_accessor :name, :description

    DEFAULT_DESCRIPTION = "This tool will use open ai to determine the output."
  
    def initialize(name: "OpenAI Tool", description: DEFAULT_DESCRIPTION)
      @name = name
      @description = description
    end
  
    def client
      @client ||= OpenAI::Client.new(access_token: ENV["OPENAI_ACCESS_TOKEN"])
    end
  
    def default_params
      {
        model: 'gpt-4',
        temperature: 0
      }
    end
  
    def system_instructions
      "You are a helpful assistant."
    end
    
    def operate(inputs)
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