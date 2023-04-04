module RubyBots
  class OpenAIBot < OpenAITool
    attr_accessor :tools

    DEFAULT_DESCRIPTION = "This bot will use OpenAI to determine the appropriate tool."
    
    def initialize(name: "OpenAI bot", description: DEFAULT_DESCRIPTION, tools:)
      @tools = tools
      super(name: name, description: description)
    end

    def system_instructions
      <<~PROMPT
      You are an assistant designed to select a tool for a user to use. You are provided with the user's input.
      Select from the following tools (name - description):
      #{tools.map{|t| t.name + " - " + t.description}.join("\n")}

      Return only the name of the tool that best fits the user's request.
      If no tools match the user's request respond with "no tool" and nothing more.
      PROMPT
    end

    private
    
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