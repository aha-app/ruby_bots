require 'bundler/setup'
require 'dotenv/load'
require 'ruby_bots'

# Dir[File.expand_path("spec/support/**/*.rb")].sort.each { |f| require f }

RSpec.configure do |c|
  # Enable flags like --only-failures and --next-failure
  c.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  c.disable_monkey_patching!

  # c.before(:all) do
  #   OpenAI.configure do |config|
  #     config.access_token = ENV.fetch("OPENAI_ACCESS_TOKEN", "dummy-token")
  #   end
  # end
end

# RSPEC_ROOT = File.dirname __FILE__
