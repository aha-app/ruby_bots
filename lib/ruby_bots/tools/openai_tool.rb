require 'openai'

module RubyBots
  class OpenAITool < Tool
    validate_inputs :input_is_json

    DEFAULT_DESCRIPTION = "This tool will use open ai to determine the output."
  
    def initialize(name: "OpenAI Tool", description: DEFAULT_DESCRIPTION)
      super(name: name, description: description)
    end
  
    def client
      @client ||= OpenAI::Client.new(access_token: RubyBots.config.openai_api_key)
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

    def input_is_json(input)
      JSON.parse(input)
    rescue JSON::ParserError
      errors.add(:input, "must be valid JSON")
    end
  end
end