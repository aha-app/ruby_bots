require 'cgi'
require 'uri'
require 'net/http'

module RubyBots
  class WolframTool < Tool
    # This tool requires an App ID key from Wolfram Alpha.
    # add it to your environment variables as WOLFRAM_APP_ID

    DEFAULT_DESCRIPTION = "This tool will use the Wolfram Alpha API to answer questions."

    def initialize(name: "Wolfram tool", description: DEFAULT_DESCRIPTION)
      super(name: name, description: description)
    end

    private

    def run(input)
      uri = URI("http://api.wolframalpha.com/v1/simple?appid=#{ENV['WOLFRAM_APPID']}&i=#{CGI.escape(input)}")
      resp = Net::HTTP.get_response(uri)
      resp.body
    end
  end
end