module RubyBots
  class << self
    def config
      @config ||= Configuration.new
    end

    def configure
      yield config
    end
  end

  class Configuration
    attr_accessor :openai_api_key
    def initialize()
      @openai_api_key = ENV["OPENAI_ACCESS_TOKEN"]
      @wolfram_app_id = ENV["WOLFRAM_APPID"]
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

require "ruby_bots/tool"
require "ruby_bots/bot"
require "ruby_bots/tools/openai_tool.rb"
require "ruby_bots/bots/openai_bot.rb"
require "ruby_bots/bots/pipeline_bot.rb"
require "ruby_bots/bots/router_bot.rb"
require "ruby_bots/bots/openai_react_bot.rb"