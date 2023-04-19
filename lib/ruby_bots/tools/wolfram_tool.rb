require 'cgi'
require 'uri'
require 'net/http'

module RubyBots
  # This tool provides an interface to get responses from the Wolfram Alpha API.
  # This tool requires an App ID key from Wolfram Alpha.
  # add it to your environment variables as WOLFRAM_APP_ID
  # it is currently alpha and not fully working or tested.
  class WolframTool < Tool
    DEFAULT_DESCRIPTION = 'This tool will use the Wolfram Alpha API to answer questions.'.freeze

    def initialize(name: 'Wolfram tool', description: DEFAULT_DESCRIPTION)
      super(name:, description:)
    end

    private

    def run(input)
      uri = URI("http://api.wolframalpha.com/v1/simple?appid=#{ENV['WOLFRAM_APPID']}&i=#{CGI.escape(input)}")
      resp = Net::HTTP.get_response(uri)
      resp.body
    end
  end
end
