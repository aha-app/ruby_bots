# Ruby Bots

[![CircleCI](https://dl.circleci.com/status-badge/img/gh/aha-app/ruby_bots/tree/main.svg?style=svg)](https://dl.circleci.com/status-badge/redirect/gh/aha-app/ruby_bots/tree/main)

# Introduction

Welcome to the RubyBots gem documentation! RubyBots is a powerful and versatile gem designed to create, integrate, and manage various bot and tool implementations. The primary purpose of this gem is to simplify the process of building and deploying bots that can leverage different APIs and tools, such as OpenAI, to provide intelligent and context-aware assistance to users.

With RubyBots, you can easily create custom bots and tools that fit your specific needs, or utilize the pre-built bots and tools provided by the gem. The gem offers a range of features, including input validation, output validation, error handling, and seamless integration with OpenAI.

Whether you're building a bot to answer questions, perform calculations, or route user requests to the appropriate tool, RubyBots provides a flexible and modular foundation to quickly develop and deploy your solution.

# Installation

Before you can start using the RubyBots gem, you'll need to ensure that you have the necessary prerequisites and follow the installation steps.

## Prerequisites

- Ruby version 3.1 or higher
- An OpenAI API key (optional, required for using OpenAITool)

## Installation Steps

1. Add the RubyBots gem to your project's `Gemfile`:

```ruby
gem 'ruby_bots'
```

2. Install the gem using Bundler:

```bash
bundle install
```

Alternatively, you can install the gem directly from the command line:

```bash
gem install ruby_bots
```

3. Set up your API key (if you plan to use OpenAITool). Add the key to your environment variables:

```bash
export OPENAI_ACCESS_TOKEN="your_openai_api_key"
```

Make sure to replace "your_openai_api_key" with your actual API keys.

4. If you're using a Rails application, you can also add the API keys to your `config/application.yml` file (if you are using the `figaro` gem) or `config/credentials.yml.enc` (if you are using Rails' built-in encrypted credentials):

For `config/application.yml`:

```yaml
OPENAI_ACCESS_TOKEN: your_openai_api_key
```

5. Require the RubyBots gem in your Ruby or Rails application:

For a Ruby script:

```ruby
require 'ruby_bots'
```

For a Rails application, add the following line to your `config/application.rb` file:

```ruby
config.autoload_paths += %W(#{config.root}/lib)
```

Now you're ready to start using the RubyBots gem in your project!

# Configuration

The RubyBots gem allows you to configure various settings to customize its behavior according to your needs. In this section, we'll cover how to set up API keys and customize default settings.

## Setting up API keys

As we mentioned in the installation section, you'll need to set up your API key for OpenAI if you plan to use that tool. Make sure you have added your API key to your environment variables or Rails credentials as explained in the installation steps.

### Custom settings example

You can customize various settings in the RubyBots gem. For example, you might want to change the default model used by the OpenAITool. To do this, simply override the `default_params` method in a custom class:

```ruby
class CustomOpenAITool < RubyBots::OpenAITool
  def default_params
    {
      model: 'custom_model',
      temperature: 0.5
    }
  end
end
```

By following these configuration steps, you can tailor the RubyBots gem to better suit your specific requirements.

# Basic Usage

In this section, we'll cover the basics of using the RubyBots gem, including how to create a bot, create a tool, and use them together to perform tasks.

## Creating a bot

To create a bot, you can either use one of the pre-built bots provided by the gem or create a custom bot by subclassing `RubyBots::Bot`. Let's create a simple bot using the built-in `RubyBots::PipelineBot`:

```ruby
require 'ruby_bots'

# Define the tools you want to use with the bot
tools = [RubyBots::OpenAITool.new]

# Create a new PipelineBot with the defined tools
pipeline_bot = RubyBots::PipelineBot.new(tools: tools)
```

## Creating a tool

Similar to creating a bot, you can either use one of the pre-built tools provided by the gem or create a custom tool by subclassing `RubyBots::Tool`. Let's create a custom tool that reverses the input text:

```ruby
require 'ruby_bots'

class ReverseTool < RubyBots::Tool
  def initialize
    super(name: 'Reverse tool', description: 'This tool reverses the input text.')
  end

  private

  def run(input)
    input.reverse
  end
end

reverse_tool = ReverseTool.new
```

## Using a bot with a tool

Now that you've created a bot and a tool, you can use them together to perform tasks. In this example, we'll use the `pipeline_bot` with the `reverse_tool` to reverse the input text:

```ruby
input = "Hello, RubyBots!"

# Add the reverse_tool to the pipeline_bot's tools
pipeline_bot.tools << reverse_tool

# Get the response from the pipeline_bot
response = pipeline_bot.response(input)

puts response # Output: "!stoBybuR ,olleH"
```

By following these basic usage steps, you can create and use bots and tools to perform various tasks with the RubyBots gem. You can further customize and extend the functionality by creating your own custom bots and tools, as explained in the next sections.

# Tools

Tools are the building blocks of the RubyBots gem, providing specific functionality that can be utilized by bots. In this section, we'll cover the pre-built tools available in the gem and explain how to use them.

## OpenAITool

The `OpenAITool` connects to the OpenAI API and uses the provided model (default is `gpt-3.5-turbo`) to generate a response based on the user's input.

### Usage

To create an instance of the `OpenAITool`, simply initialize it:

```ruby
openai_tool = RubyBots::OpenAITool.new
```

You can then use this tool with any bot that accepts tools, such as the `PipelineBot` or `RouterBot`.

## OpenAIStreamingTool

The `OpenAIStreamingTool` connects to the OpenAI API and uses the provided model to generate a response based on the user's input. This tool also provides a way to inject messages into the prompt and stream the output using a proc.

### Usage

The best way to use the `OpeanAIStreamingTool` is to subclass it and provide a proc for handling the response chunks. Here is an example of a bot that could be used inside of a rails app using server side events (`SSE.new`) and `ActionController::Live`

```ruby
class ChatBot < RubyBots::OpenAIStreamingBot
  def initialize(sse:, messages: [])
    @sse = sse
    super(name: 'ChatBot', description: 'A streaming assistant', messages:)
  end

  def stream_proc
    proc do |chunk, _bytesize|
      message = chunk.dig('choices', 0, 'delta', 'content')
      @sse.write({ data: message }, event: 'text')
    end
  end
end
```
```ruby
class ChatController < ApplicationController
  include ActionController::Live

  def chat
    @messages = JSON.parse(params['messages'])

    response.headers['Content-Type'] = 'text/event-stream'
    @sse = SSE.new(response.stream)

    chat_bot = ChatBot.new(sse: @sse, messages: @messages)

    begin
      chat_bot.response
    ensure
      @sse.write({}, event: 'done')
      @sse.close
    end
  end
end
```

This code assumes you have set up a rails controller called `ChatController` and have created a `chat` endpoint that will take a `messages` parameter. The messages should be an array of messages formatted for OpenAI like so:

    {role:, content:}

Here `role` is either `"user"` or `"assistant"` and `content` is a string providing the message from that role.

The endpoint will need to be a `GET` endpoint and the parameters will need to be passed as query parameters using an `EventStream` on the frontend. The frontend will also need to handle the `text` and `done` events that are created in the controller and bot.

Note: If you have problems with the StreamEvent messages batching up in your rails response, try disabling the ETag middleware:

    config.middleware.delete Rack::ETag

An example app with the above setup can be found here: [RubyBots Example Chat Rails Application](https://github.com/aha-app/chat_app).


## Custom Tools

You can create custom tools by subclassing the `RubyBots::Tool` class and implementing the `run` method. Here's an example of a custom tool that converts the input text to uppercase:

```ruby
class UppercaseTool < RubyBots::Tool
  def initialize
    super(name: 'Uppercase tool', description: 'This tool converts the input text to uppercase.')
  end

  private

  def run(input)
    input.upcase
  end
end

uppercase_tool = UppercaseTool.new
```

You can then use the custom `UppercaseTool` with any bot that accepts tools.

By utilizing the pre-built tools or creating custom tools, you can easily extend the functionality of your bots and tailor them to your specific requirements.

# Bots

Bots in the RubyBots gem are responsible for orchestrating the use of tools to perform tasks based on user input. In this section, we'll cover the pre-built bots available in the gem and explain how to use them.

## Bot

`RubyBots::Bot` is the base class for all bots in the RubyBots gem. You can create a custom bot by subclassing `RubyBots::Bot` and implementing the `run` method. The `run` method should accept an input and return the output after processing it.

### Usage

To create a custom bot that simply returns the user's input without any modifications, you can subclass `RubyBots::Bot` like this:

```ruby
class EchoBot < RubyBots::Bot
  def initialize
    super(name: 'Echo bot', description: 'This bot echoes the user input.')
  end

  private

  def run(input)
    input
  end
end

echo_bot = EchoBot.new
```

## OpenAIBot

The `OpenAIBot` is a pre-built bot that uses the OpenAI API to determine the appropriate tool to use for the response based on the user's input.

### Usage

To create an instance of the `OpenAIBot`, initialize it with an array of tools:

```ruby
tools = [RubyBots::OpenAITool.new]
openai_bot = RubyBots::OpenAIBot.new(tools: tools)
```

## PipelineBot

The `PipelineBot` is a pre-built bot that utilizes all of its tools in a synchronous pipeline based on the order the tools are provided. The bot will call the tools in order until each tool has responded, and the final response will be the output of the last tool.

### Usage

To create an instance of the `PipelineBot`, initialize it with an array of tools:

```ruby
tools = [RubyBots::OpenAITool.new]
pipeline_bot = RubyBots::PipelineBot.new(tools: tools)
```

## RouterBot

The `RouterBot` is a pre-built bot that connects to the OpenAI API and uses the provided model to choose the proper tool to route the user's input. The bot will only select and use one tool.

### Usage

To create an instance of the `RouterBot`, initialize it with an array of tools:

```ruby
tools = [RubyBots::OpenAITool.new]
router_bot = RubyBots::RouterBot.new(tools: tools)
```

## OpenAIReactBot

The `OpenAIReactBot` is a pre-built bot that uses the ReAct framework to select the appropriate tool for the provided input and respond to the user. The input from the tools is fed back into the messages as observations.

### Usage

To create an instance of the `OpenAIReactBot`, initialize it with an array of tools:

```ruby
tools = [RubyBots::OpenAITool.new]
openai_react_bot = RubyBots::OpenAIReactBot.new(tools: tools)
```

By using the pre-built bots or creating your own custom bots, you can effectively combine and utilize tools to perform various tasks based on user input.

# Customizing and Extending Bots and Tools

The RubyBots gem provides a flexible framework for creating custom bots and tools that suit your specific needs. In this section, we'll guide you through the process of customizing and extending both bots and tools.

## Creating Custom Bots

To create a custom bot, you'll need to subclass `RubyBots::Bot` and implement the `run` method. The `run` method is responsible for processing the user input and returning the appropriate output.

Here's an example of a custom bot that uses a custom tool to count the number of words in the input:

```ruby
require 'ruby_bots'

class WordCountBot < RubyBots::Bot
  def initialize
    word_count_tool = WordCountTool.new
    super(tools: [word_count_tool], name: 'Word Count Bot', description: 'This bot counts the number of words in the input.')
  end

  private

  def run(input)
    word_count_tool = tools.first
    word_count = word_count_tool.run(input)
    "There are #{word_count} words in the input."
  end
end
```

## Creating Custom Tools

To create a custom tool, you'll need to subclass `RubyBots::Tool` and implement the `run` method. The `run` method is responsible for processing the input and returning the appropriate output.

Here's an example of a custom tool that counts the number of words in the input:

```ruby
require 'ruby_bots'

class WordCountTool < RubyBots::Tool
  def initialize
    super(name: 'Word Count Tool', description: 'This tool counts the number of words in the input.')
  end

  private

  def run(input)
    input.split(' ').count
  end
end
```

## Validation and Error Handling

RubyBots allows you to add input and output validations to your custom bots and tools. Input validations ensure that the input provided to the tool or bot is valid, while output validations ensure that the tool or bot produces valid output.

To add input or output validation, use the `validate_input` and `validate_output` class methods in your custom bot or tool:

```ruby
require 'ruby_bots'

class CustomTool < RubyBots::Tool
  validate_input :input_valid?
  validate_output :output_valid?

  def initialize
    super(name: 'Custom Tool', description: 'This is a custom tool with input and output validation.')
  end

  private

  def run(input)
    # Process the input and return the output
  end

  def input_valid?(input)
    # Check if the input is valid, e.g., not empty
    errors << 'Input cannot be empty' if input.strip.empty?
  end

  def output_valid?(output)
    # Check if the output is valid, e.g., not empty
    errors << 'Output cannot be empty' if output.strip.empty?
  end
end
```

If any validation fails, the `RubyBots::InvalidInputError` or `RubyBots::InvalidOutputError` will be raised, providing details about the error.

## Available Built-in Validations

There are some validations avialable in the API. They are added the same way as custom validations.

```
:json? - checks if the value is a valid JSON string
```

By following these steps, you can customize and extend the functionality of RubyBots by creating your own custom bots and tools, adapting them to your specific requirements and ensuring a robust and reliable implementation.

## Streamable Mixin

The `Streamable` mixin is a module that can be included in any Tool or Bot class to override the default response method. It allows for streaming output from the `run` method instead of validating the output before returning.

### Usage

To use the `Streamable` module, simply include it in your Tool or Bot class:

```ruby
class MyTool < RubyBots::Tool
  include RubyBots::Streamable

  # ... your custom methods and validations
end
```

### Why use Streamable?

You may want to use the `Streamable` module if your Tool or Bot needs to respond from a system like OpenAI where the response is streamed one token at a time rather than waiting for the entire call to complete. This can improve the user experience when working with OpenAI and other large language models.

# Chattable Mixin

The `Chattable` mixin is a module that can be included in any Tool or Bot class to override the default response method. It's designed for use cases where a Tool or Bot needs to interact with the user in a more conversational manner, allowing for a block to be passed in which can be used to handle the processing of the responses.

## Usage

To use the `Chattable` mixin, simply include it in your Tool or Bot class:

```ruby
class MyChattableTool < RubyBots::Tool
  include RubyBots::Chattable

  # ... your custom methods and validations
end
```

After including the `Chattable` mixin, you should implement the `run` method in your Tool or Bot class. The `run` method should accept an input and a block, and return the appropriate output after processing it.

Here's an example of a custom bot using the `Chattable` mixin:

```ruby
require 'ruby_bots'

class MyChattableTool < RubyBots::Tool
  include RubyBots::Chattable

  def initialize
    super(name: 'My chattable tool', description: 'This tool can engage in conversations.')
  end

  private

  def run(input, &block)
    # Process the input and pass it to the block
    # keep processing new input until 'exit' is passed as input
    output = ''

    unless input == 'exit'
      output = process_input(input)
      input = yield output
    end

    output
  end

  def process_input(input)
    "Bot received: #{input}"
  end
end

# Create a MyChattableTool
chattable_tool = MyChattableTool.new

# User's input
user_input = "What's up?"

# Get the response from the MyChattableBot and process it using a block
chattable_tool.response(user_input) do |response|
  puts response # Output: "Bot received: What's up?"
  gets          # return more input from the command line and repeat, 'exit' to end.
end
```

## Why use Chattable?

The `Chattable` mixin provides a way to handle more complex and interactive communication between the user and the bot. By allowing a block to be passed in, it enables the bots to ask the users for more information and interact in more natural and dynamic ways.

The `OpenAIChatTool` and `OpenAIChatBot` both utilize the Chattable mixin.

# Examples

In this section, we'll provide some sample use cases and example code snippets to demonstrate how you can use the RubyBots gem to create and utilize bots and tools for various tasks.

## Example 1: Using the OpenAIReactBot

In this example, we'll use the built-in `RubyBots::OpenAIReactBot` to answer a user's question by interacting with the OpenAI API.

```ruby
require 'ruby_bots'

# Create an OpenAIReactBot
openai_react_bot = RubyBots::OpenAIReactBot.new

# User's input
user_input = "What is the capital of France?"

# Get the response from the OpenAIReactBot
response = openai_react_bot.response(user_input)

puts response # Output: "Paris"
```

## Example 2: Creating a custom bot to solve math problems

In this example, we'll create a custom bot to solve math problems using a combination of the `RubyBots::OpenAITool` and `RubyBots::WolframTool`.

```ruby
require 'ruby_bots'

class MathBot < RubyBots::Bot
  def initialize
    tools = [RubyBots::OpenAITool.new, RubyBots::WolframTool.new]
    super(tools: tools, name: 'Math bot', description: 'This bot solves math problems.')
  end

  private

  def run(input)
    # Use the OpenAITool to determine if the input is a math problem
    is_math_problem = tools[0].response("Is '#{input}' a math problem?")

    # If the input is a math problem, use the WolframTool to solve it
    if is_math_problem.downcase == 'yes'
      tools[1].response(input)
    else
      "This is not a math problem."
    end
  end
end

# Create a MathBot
math_bot = MathBot.new

# User's input
user_input = "2 + 2"

# Get the response from the MathBot
response = math_bot.response(user_input)

puts response # Output: "4"
```

## Example 3: Creating a custom tool to count words

In this example, we'll create a custom tool that counts the number of words in the input text and use it with a `RubyBots::PipelineBot`.

```ruby
require 'ruby_bots'

class WordCountTool < RubyBots::Tool
  def initialize
    super(name: 'Word count tool', description: 'This tool counts the number of words in the input text.')
  end

  private

  def run(input)
    input.split.size
  end
end

# Create a WordCountTool
word_count_tool = WordCountTool.new

# Create a PipelineBot with the WordCountTool
pipeline_bot = RubyBots::PipelineBot.new(tools: [word_count_tool])

# User's input
user_input = "How many words are in this sentence?"

# Get the response from the PipelineBot
response = pipeline_bot.response(user_input)

puts response # Output: "7"
```

## Example 4: Using the OpenAIChatTool

In this example, we'll use the built-in `RubyBots::OpenAIChatTool` to answer a user's question by interacting with the OpenAI API and asking the user follow-up questions.

```ruby
require 'ruby_bots'

# Create an OpenAIChatTool
openai_react_bot = RubyBots::OpenAIChatTool.new

# User's input
user_input = "What is the lowest recorded temperature here?"

# Get the response from the OpenAIChatTool, displays it to the user and waits for more input
# This loop will continue until the the user types one of the exit string [ 'exit', 'quit', 'q', 'stop', 'bye' ]
# Given the user_input above, the bot may respond with "To provide you with the lowest recorded temperature, I need to know the specific location you are referring to. Please provide the name of the city, region, or country."
# The user can then provide a clarifying answer and chat back and forth until they are ready to exit
response = openai_react_bot.response(user_input) do |bot_output|
  puts bot_output
  gets
end
```

These examples demonstrate just a few of the possibilities when using the RubyBots gem. You can create custom bots and tools to handle a wide range of tasks or use the built-in bots and tools to quickly get started with tasks like question-answering, routing, and more.

# Troubleshooting

In this section, we'll provide some common issues and solutions you may face while working with the RubyBots gem, as well as some debugging tips to help you identify and resolve problems.

## Common Issues and Solutions

1. **Issue: API key not found or invalid**

   Solution: Ensure that you have set the correct API key for the respective service (OpenAI, Wolfram Alpha) in your environment variables. Double-check the spelling and format of your keys.

2. **Issue: Invalid input or output errors**

   Solution: Verify that your input and output data formats are correct and adhere to the requirements specified by the bot or tool. Check for any custom input or output validations in your code to ensure they are working as expected.

3. **Issue: API request limit exceeded or rate limiting**

   Solution: Some APIs may have request limits or rate limiting. Make sure you are not exceeding these limits. If necessary, consider upgrading your API plan or implementing caching to reduce the number of requests made.

4. **Issue: Unhandled exceptions or errors in a custom bot or tool**

   Solution: Review your custom bot or tool code for any syntax or logical errors. Ensure that you are properly handling exceptions and errors, and check for any missing or incorrect method implementations.

## Debugging Tips

1. **Use `puts` and `p` statements**: Add `puts` or `p` statements throughout your code to print variables or the state of your bot/tool at various points during execution. This can help you identify the point where an issue is occurring.

2. **Check the logs**: If you're using an API, check the logs or error messages provided by the respective service to gain more insight into any issues.

3. **Test with different inputs**: Try using a variety of inputs to see if the issue persists across different cases or if it's specific to certain inputs.

4. **Isolate the problem**: Break down your code into smaller parts and test each part individually to help pinpoint the source of the issue.

5. **Consult the documentation**: Review the documentation for the RubyBots gem and the APIs you're using to ensure you're implementing everything correctly and not missing any required steps.

By following these troubleshooting steps and debugging tips, you can identify and resolve issues when working with the RubyBots gem. If you're still experiencing problems, consider reaching out to the community or submitting a bug report for further assistance.

# Contributing

We greatly appreciate contributions to the RubyBots gem! If you're interested in contributing, whether it's by reporting a bug, suggesting improvements, or submitting code, please follow the guidelines below.

## Reporting Bugs

1. Check the [Issues](https://github.com/aha-app/ruby_bots/issues) page on GitHub to see if the issue has already been reported.
2. If the issue hasn't been reported, create a new issue and provide a clear and concise description of the bug, including steps to reproduce, expected behavior, and actual behavior.
3. Attach any relevant screenshots, logs, or code snippets to help us understand the issue better.
4. Don't forget to add appropriate labels to the issue, such as "bug" or "enhancement".

## Suggesting Improvements

1. Check the [Issues](https://github.com/aha-app/ruby_bots/issues) page on GitHub to see if a similar suggestion has already been posted.
2. If not, create a new issue describing the improvement, including the motivation behind it, the benefits it would bring, and any potential challenges or drawbacks.
3. Add appropriate labels to the issue, such as "enhancement" or "documentation".

## Contributing Code

1. Fork the [RubyBots repository](https://github.com/aha-app/ruby_bots) on GitHub.
2. Clone the forked repository to your local machine.
3. Create a new branch with a descriptive name for your changes, e.g., `git checkout -b my-feature-branch`.
4. Make your changes, ensuring that they follow the project's coding style and guidelines.
5. Write tests for your changes, if applicable.
6. Run the existing tests to make sure they still pass (`bundle exec rspec`).
7. Commit your changes (`git commit -am 'Add some feature'`).
8. Push the branch to your fork on GitHub (`git push origin my-feature-branch`).
9. Create a new pull request, describing the changes you made and their purpose.

Thank you for your interest in contributing to the RubyBots gem! Your effort and support help make this project better for everyone.

# Changelog

All notable changes to the RubyBots gem will be documented in this file. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html). See the `CHANGELOG.md` file for a list of changes for each new version.


# License

The RubyBots gem is released under the [MIT License](https://opensource.org/licenses/MIT). This permissive open-source software license grants you the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the software, as long as you meet the conditions specified in the license.

The full text for the license is available in the `LICENSE.txt` file.
