module RubyBots
  # This bot uses the ReAct framework to select from the provide tools and respond to the user.
  # The input from the tools that are called by the bot are fed back into the messages as observations.
  class OpenAIReactBot < OpenAIBot
    attr_accessor :tools

    DEFAULT_DESCRIPTION = <<~DESCRIPTION.strip_heredoc
      This bot will use the ReAct framework to determine the appropriate response. It is powered by OpenAI and the ReAct framework.
    DESCRIPTION

    DEFAULT_TOOLS = [
      RubyBots::Tool.new(
        name: 'search',
        description: 'Search the web for information. Input should be the string to search for.'
      ),
      RubyBots::Tool.new(
        name: 'calculate',
        description: <<~DESC.strip_heredoc
          Solve math problems. Input should be a mathematical expression with no additional details or context.
        DESC
      )
    ].freeze

    def initialize(tools: DEFAULT_TOOLS, name: 'OpenAI ReAct bot', description: DEFAULT_DESCRIPTION)
      super(tools:, name:, description:)
    end

    def examples
      [EXAMPLE_ONE, EXAMPLE_TWO]
    end

    EXAMPLE_ONE = <<~EXAMPLE.strip_heredoc
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

    EXAMPLE_TWO = <<~EXAMPLE.strip_heredoc
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

    def prefix
      <<~PROMPT.strip_heredoc
        You are an assistant designed to provide solutions for a user. You are provided with the user's input.
      PROMPT
    end

    def suffix
      ''
    end

    def system_instructions
      <<~PROMPT
        #{prefix}

        You run in a loop of thought, action, observation, and reflection until you have a solution for the user.
        You can utilize the following actions (name - description):
        #{tools.map { |t| "#{t.name} - #{t.description}" }.join("\n")}

        You should begin by providing a thought and an action with the necessary input for the action. The action will be executed externally, and then you will be called again with the observation returned from the action.

        You should then begin the loop again and provide a thought and action.

        If you have a solution for the user, return the solution instead of a new action.
        The final answer should only answer the question without additional information about reasoning or process.

        #{suffix}

        Examples:
        #{examples.join("\n\n")}
      PROMPT
    end

    private

    def run(input)
      params = initial_params(input)

      until answer?(response = client.chat(parameters: params).dig('choices', 0, 'message', 'content'))
        params[:messages] << { role: :assistant, content: response }
        params[:messages] << { role: :assistant, content: "Observation: #{get_observation_from_action(response)}" }
      end
      get_answer_from_response(response)
    end

    def initial_params(input)
      {
        messages: [
          { role: :system, content: system_instructions },
          { role: :user, content: input }
        ]
      }.merge(default_params)
    end

    def answer?(input)
      input.match(/Answer: /)
    end

    def get_observation_from_action(response)
      tool_string = response.match(/Action: ([\s\S]*)/)[1]
      tool_name = tool_string.match(/([a-zA-Z_\- ]*)\[([\s\S]*)\]/)[1]
      tool_input = tool_string.match(/([a-zA-Z_\- ]*)\[([\s\S]*)\]/)[2]

      tool = tools.find { |t| t.name == tool_name }

      tool.response(tool_input)
    end

    def get_answer_from_response(response)
      response.match(/Answer: ([\s\S]*)/)[1]
    end
  end
end
