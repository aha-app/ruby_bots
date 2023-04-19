RSpec.describe RubyBots::RouterBot do
  it 'can be initialized with a name and description' do
    tools = [
      RubyBots::Tool.new(name: 'Tool', description: 'This is a tool')
    ]
    bot = RubyBots::RouterBot.new(name: 'Bot', description: 'This is a bot', tools:)
    expect(bot.name).to eq('Bot')
    expect(bot.description).to eq('This is a bot')
  end

  describe '#response' do
    it 'calls run with the prompt' do
      tools = [
        RubyBots::Tool.new(name: 'Tool', description: 'This is a tool')
      ]
      bot = RubyBots::RouterBot.new(name: 'Bot', description: 'This is a bot', tools:)
      allow(bot).to receive(:run).with('This is a test prompt').and_return('some output')
      expect(bot.response('This is a test prompt')).to be_a(String)
    end

    it 'calls the appropriate tool and responds with answer' do
      tools = [
        Class.new(RubyBots::Tool) do
          def run(input) = 'tool output'
        end.new(name: 'Tool', description: 'This is a tool')
      ]

      bot = RubyBots::RouterBot.new(name: 'Bot', description: 'This is a bot', tools:)

      params = {
        messages: [
          { role: :system, content: bot.system_instructions },
          { role: :user, content: 'This is a test prompt' }
        ]
      }.merge(bot.default_params)

      allow_any_instance_of(OpenAI::Client).to receive(:chat)
                                                 .with(parameters: params)
                                                 .and_return({ 'choices' => [{ 'message' => { 'content' => 'Tool' } }] })

      expect(bot.response('This is a test prompt')).to eq('tool output')
    end

    it 'fails when response is not a tool name' do
      tools = [
        RubyBots::Tool.new(name: 'Tool', description: 'This is a tool')
      ]

      bot = RubyBots::RouterBot.new(name: 'Bot', description: 'This is a bot', tools:)

      params = {
        messages: [
          { role: :system, content: bot.system_instructions },
          { role: :user, content: 'This is a test prompt' }
        ]
      }.merge(bot.default_params)

      allow_any_instance_of(OpenAI::Client).to receive(:chat)
                                                 .with(parameters: params)
                                                 .and_return({ 'choices' => [{ 'message' => { 'content' => 'Not a tool' } }] })

      expect { bot.response('This is a test prompt') }.to raise_error(RubyBots::InvalidOutputError)
    end
  end
end
