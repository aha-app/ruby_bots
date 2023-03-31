module RubyBots
  class << self
  end

  def self.bot
    RubyBots::Bot
  end

  def self.tool
    RubyBots::Tool
  end
end

require "ruby_bots/tool"
require "ruby_bots/bot"
# require "ruby_bots/version"
# require "ruby_bots/bots/openai_bot.rb"
# require "ruby_bots/bots/pipeline_bot.rb"
# require "ruby_bots/bots/router_bot.rb"
# require "ruby_bots/tools/openai_tool.rb"