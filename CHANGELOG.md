# Changelog

## [0.2.0] - 2023-06-25
### Changed
- Updated OpenAIStreamingTool
  - messages is now an initialization parameter. These messages are then added to the prompt.
  - response can now take no arguments and will return the response based on the @messages present.
- Changed the default OpenAI model to be gpt-3.5-turbo rather than gpt-4 due to restrictions with gpt-4.

## [0.1.6] - 2023-06-01
### Changed
- Fixed bug introduced in 0.1.3 for OpenAIStreamingTool

## [0.1.4-0.1.5] - 2023-05-23
### Changed
- Dependency cleanup

## [0.1.3] - 2023-05-23
### Added
- RubyBots::OpenAIStreamingTool - a tool that can stream a response from OpenAI

### Changed
- Updated ruby-openai gem to the latest and removed lock in gemfile

## [0.1.2] - 2023-04-26
### Added
- RubyBots::Chattable - module that allows for a block to be passed into a tool and the tool to yield for additional input
- RubyBots::OpenAIChatTool - Utilizes RubyBots::Chattable to open a chat with OpenAI instead of a single response
- RubyBots::OpenAIChatBot - Utilizes RubyBots::Chattable to open a chat with OpenAI to determine which tool to utilize

## [0.1.1] - 2023-04-24
### Added
- RubyBots::Streamable - module that directly returns the output from the run function on a Tool and skips the output validations so that the output can be streamed directly to the user.

## [0.1.0] - 2023-04-20
### Added
- CHANGELOG.md for these changes

### Changed
- README.md is much more comprehensive
