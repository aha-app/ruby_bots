# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require_relative 'lib/ruby_bots/version'

Gem::Specification.new do |spec|
  spec.name = 'ruby_bots'
  spec.version = RubyBots::VERSION
  spec.authors = ['Justin Paulson']
  spec.email = ['jpaulson@aha.io']

  spec.summary = 'Ruby Bots lets you create tools and bots to complete tasks. Inspired by python langchain.'
  spec.description = 'Bots can use different tools to solve any number of tasks. Bots can be powered by OpenAI.'
  spec.homepage = 'https://github.com/aha-app/ruby_bots'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = spec.homepage
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir['lib/**/*.rb', 'bin/*']
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # dev / test dependencies
  spec.add_development_dependency 'debug', '~> 1.1'
  spec.add_development_dependency 'dotenv', '~> 2.8'
  spec.add_development_dependency 'rspec', '~> 3.2'

  # runtime dependencies
  spec.add_dependency 'ruby-openai', '~> 4.0'
end
