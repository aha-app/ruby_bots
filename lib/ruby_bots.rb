# Main module for RubyBots
module RubyBots
  class << self
    def config
      @config ||= Configuration.new
    end

    def configure
      yield config
    end
  end

  # Configuration class
  class Configuration
    attr_accessor :openai_api_key

    def initialize
      @openai_api_key = ENV['OPENAI_ACCESS_TOKEN']
      @wolfram_app_id = ENV['WOLFRAM_APPID']
    end
  end

  def self.bot
    RubyBots::Bot
  end

  def self.tool
    RubyBots::Tool
  end

  class Error < StandardError; end
  class InvalidInputError < Error; end
  class InvalidOutputError < Error; end
end

class String
  def strip_heredoc
    gsub(/^#{scan(/^[ \t]*(?=\S)/).min}/, ''.freeze)
  end
end

# tools
require_relative 'ruby_bots/tool'
require_relative 'ruby_bots/tools/openai_tool'

# bots
require_relative 'ruby_bots/bot'
require_relative 'ruby_bots/bots/openai_bot'
require_relative 'ruby_bots/bots/pipeline_bot'
require_relative 'ruby_bots/bots/router_bot'
require_relative 'ruby_bots/bots/openai_react_bot'

require_relative 'ruby_bots/version'
