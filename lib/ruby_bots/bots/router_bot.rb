module RubyBots
  class RouterBot < OpenAIBot
    DEFAULT_DESCRIPTION = "This bot will route the user's input to the appropriate tool. It will only select and use one tool."
    
    def initialize(name: "Router bot", description: DEFAULT_DESCRIPTION, tools:)
      super(name: name, description: description, tools: tools)
    end

    def system_instructions
      <<~PROMPT
      You are an assistant helping to route a user's input to the correct tool.
      You can use the following tools (name - description):
      #{tools.map{|t| t.name + " - " + t.description}.join("\n")}

      Return only the name of the tool that best fits the user's request.
      If no tools match the user's request respond with "I'm sorry, I am still learning." and nothing more.
      PROMPT
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
        
      response_text = response.dig("choices", 0, "message", "content")
      selected_tool = tools.find{|t| t.name == response_text}
      if selected_tool
        selected_tool.response(input)
      else
        response_text
      end
    end
  end
end