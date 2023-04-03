# Ruby Bots

## Overview

RubyBots allows you to build composable tools to manipulate values.

The basic tools provide an OpenAI tool that can connect to OpenAI and provide feedback.

## Installation

```
gem install ruby_bots
```

## Usage

### RubyBots::Tool

Tools are the main building blocks ofr RubyBots. RubyBots Tools are used by calling the `response` method with a valid input. The `response` method has functionality built in to validate the inputs and outputs of the tool.
The Tool class should not be used directly, but instead subclassed to provide the `run` method.

### Validations

To validate input use the `validate_input` class method, and to validate output use the `validate_output` class method.

Example adding an input validation to a tool that adds one to a Numeric input:
```
class AddOneTool < RubyBots::Tool
  validate_input :input_is_number

  private

  def run(input)
    input + 1
  end

  def input_is_number(input)
    unless input.is_a?(Numeric)
      errors << "Input is not Numeric"
    end
  end
end
```

#### Available built in validations

There are a few validations avialable in the API. They are added the same way as custom validations.

```
:is_json - checks if the value is a valid JSON string
```