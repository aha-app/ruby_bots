module RubyBots
  class OpenAIReactBot < OpenAIBot
    attr_accessor :tools

    DEFAULT_DESCRIPTION = "This bot will use the ReAct framework to determine the appropriate response. It is powered by OpenAI and the ReAct framework."
    
    DEFAULT_TOOLS = [
      RubyBots::Tool.new(name:"search", description:"Search the web for information. Input should be the string to search for."),
      RubyBots::Tool.new(name:"calculate", description:"Solve math problems. Input should be a mathematical expression with no additional details or context."),
    ]

    def initialize(name: "OpenAI ReAct bot", description: DEFAULT_DESCRIPTION, tools: DEFAULT_TOOLS)
      @tools = tools
      super(name: name, description: description)
    end

    def examples
      [ EXAMPLE_ONE, EXAMPLE_TWO, EXAMPLE_THREE ]
    end

    
    EXAMPLE_ONE = <<~EXAMPLE
    User: What is the current temperature in the city Julia Roberts was born in?
    Thought: I need to know where Julia Roberts was born.
    Action: search[Julia Roberts birthplace]
    Observation: Smyrna, Georgia
    Thought: I need to know the current temperature in Smyrna, Georgia.
    Action: search[current temperature Smyrna, Georgia]
    Observation: 72 degrees Fahrenheit
    Thought: I need to tell the user the current temperature in the city Julia Roberts was born in.
    Answer: 72 degrees Fahrenheit
    EXAMPLE
  
    EXAMPLE_TWO = <<~EXAMPLE
    User: What is the square of the age of Albert Einstein at his death?
    Thought: I need to know the age of Albert Einstein at his death.
    Action: search[Albert Einstein age at death]
    Observation: 76 years old
    Thought: I need to know the square of 76.
    Action: calculate[76^2]
    Observation: 5776
    Thought: I need to tell the user the square of the age of Albert Einstein at his death.
    Answer: 5776
    EXAMPLE
  
    EXAMPLE_THREE = <<~EXAMPLE
    User: What is half of the amount of years that have passed since the year the first airplane flew?
    Thought: I need to know the year the first airplane flew.
    Action: search[first airplane flight year]
    Observation: 1903
    Thought: I need to know the current year.
    Action: search[current year]
    Observation: 2023
    Thought: I need to know the amount of years that have passed since 1903.
    Action: calculate[2023 - 1903]
    Observation: 120
    Thought: I need to know half of 120.
    Action: calculate[120 / 2]
    Observation: 60
    Thought: I need to tell the user half of the amount of years that have passed since the year the first airplane flew.
    Answer: 60
    EXAMPLE

    def system_instructions
      <<~PROMPT
      You are an assistant designed to provide solutions for a user. You are provided with the user's input.
      You run in a loop of thought, action, observation, and reflection until you have a solution for the user.
      You can utilize the following actions to gather more information (name - description):
      #{ tools.map{ |t| t.name + " - " + t.description }.join("\n") }

      You should begin by providing a thought and an action with the necessary input for the action. The action will be
      executed externally, and then you will be called again with the observation returned from the action.
      
      You should then begin the loop again and provide a thought and action.

      If you have a solution for the user, return the solution instead of a new action.
      The final answer should only answer the question without additional information about reasoning or process.

      Examples:
      #{ examples.join("\n\n") }
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
      response = response.dig("choices", 0, "message", "content")

      while !is_answer?(response)
        params[:messages] << { role: :assistant, content: response }

        observation = get_observation_from_action(response)

        params[:messages] << { role: :assistant, content: "Observation: #{observation}" }

        response = client.chat(parameters: params)

        response = response.dig("choices", 0, "message", "content")
      end

      get_answer_from_response(response)
    end

    def is_answer?(input)
      input.match(/Answer: /)
    end

    def get_observation_from_action(response)
      t = response.match(/Action: ([\s\S]*)/)[1]
      tool_name = t.match(/([a-zA-Z\-\_]*)\[([\s\S]*)\]/)[1]
      tool_input = t.match(/([a-zA-Z\-\_]*)\[([\s\S]*)\]/)[2]

      notify_observers(:action, tool_name, tool_input)

      tool = tools.find{|t| t.name == tool_name}

      tool.response(tool_input)
    end

    def get_answer_from_response(response)
      response.match(/Answer: ([\s\S]*)/)[1]
    end
  end
end
