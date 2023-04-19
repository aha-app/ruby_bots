RSpec.describe RubyBots::PipelineBot do
  it 'can be initialized with a name and description' do
    tools = [
      RubyBots::Tool.new(name: 'Tool', description: 'This is a tool')
    ]
    bot = RubyBots::PipelineBot.new(name: 'Bot', description: 'This is a bot', tools:)
    expect(bot.name).to eq('Bot')
    expect(bot.description).to eq('This is a bot')
  end

  describe '#response' do
    it 'calls run with the prompt' do
      tools = [
        RubyBots::Tool.new(name: 'Tool', description: 'This is a tool')
      ]
      bot = RubyBots::PipelineBot.new(name: 'Bot', description: 'This is a bot', tools:)
      allow(bot).to receive(:run).with('This is a test prompt').and_return('some output')
      expect(bot.response('This is a test prompt')).to be_a(String)
    end

    it 'calls the appropriate tools and responds with answer' do
      tools = [
        Class.new(RubyBots::Tool) do
          def run(input) = input == 'tool1' ? 'tool2' : ''
        end.new(name: 'Tool1', description: 'This is a tool'),
        Class.new(RubyBots::Tool) do
          def run(input) = input == 'tool2' ? 'tool 2 output' : ''
        end.new(name: 'Tool2', description: 'This is a tool')
      ]

      bot = RubyBots::PipelineBot.new(name: 'Bot', description: 'This is a bot', tools:)

      expect(bot.response('tool1')).to eq('tool 2 output')
    end
  end
end
