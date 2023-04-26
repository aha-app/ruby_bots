RSpec.describe RubyBots::OpenAIChatBot do
  let(:tools) do
    [
      Class.new(RubyBots::Tool) do
        def run(input) = 'search tool output'
      end.new(name: 'search', description: 'This is a tool')
    ]
  end

  it 'can be initialized with a name and description' do
    tool = RubyBots::OpenAIChatBot.new(name: 'Tool', description: 'This is a tool', tools: tools)
    expect(tool.name).to eq('Tool')
    expect(tool.description).to eq('This is a tool')
  end

  describe '#response' do
    it 'calls run with the input and block' do
      tool = RubyBots::OpenAIChatBot.new(name: 'Tool', description: 'This is a tool', tools: tools)
      allow(tool).to receive(:run).with('This is a test prompt').and_return('answer')
      expect(tool.response('This is a test prompt')).to be_a(String)
    end

    it 'calls the OpenAI API and responds with the correct tool' do
      tool = RubyBots::OpenAIChatBot.new(name: 'Tool', description: 'This is a tool', tools: tools)

      params1 = {
        messages: [
          { role: :system, content: tool.system_instructions },
          { role: :user, content: 'This is a test prompt' }
        ]
      }.merge(tool.default_params)

      params2 = {
        messages: [
          { role: :system, content: tool.system_instructions },
          { role: :user, content: 'This is a test prompt' },
          { role: :assistant, content: 'tell me more' },
          { role: :user, content: 'more information' }
        ]
      }.merge(tool.default_params)

      response1 = { 'choices' => [{ 'message' => { 'content' => 'tell me more' } }] }
      response2 = { 'choices' => [{ 'message' => { 'content' => 'search' } }] }

      allow(tool.client).to receive(:chat).with({parameters: params1}).and_return(response1)
      allow(tool.client).to receive(:chat).with({parameters: params2}).and_return(response2)

      response_test = nil

      expect(tool.response('This is a test prompt') { |response| response_test = response; 'more information' }).to eq('search tool output')

      expect(response_test).to eq('tell me more')
    end
  end
end
