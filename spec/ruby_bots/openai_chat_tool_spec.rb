RSpec.describe RubyBots::OpenAIChatTool do
  it 'can be initialized with a name and description' do
    tool = RubyBots::OpenAIChatTool.new(name: 'Tool', description: 'This is a tool')
    expect(tool.name).to eq('Tool')
    expect(tool.description).to eq('This is a tool')
  end

  describe '#response' do
    it 'calls run with the input and block' do
      tool = RubyBots::OpenAIChatTool.new(name: 'Tool', description: 'This is a tool')
      allow(tool).to receive(:run).with('This is a test prompt').and_return('answer')
      expect(tool.response('This is a test prompt')).to be_a(String)
    end

    it 'calls the OpenAI API and responds with the correct tool' do
      tool = RubyBots::OpenAIChatTool.new(name: 'Tool', description: 'This is a tool')

      params = {
        messages: [
          { role: :system, content: tool.system_instructions },
          { role: :user, content: 'This is a test prompt' }
        ]
      }.merge(tool.default_params)

      response = { 'choices' => [{ 'message' => { 'content' => 'some answer' } }] }

      allow_any_instance_of(OpenAI::Client).to receive(:chat).with(parameters: params).and_return(response)

      response_test = nil

      expect(tool.response('This is a test prompt') { |response| response_test = response; 'exit' }).to be_nil

      expect(response_test).to eq('some answer')
    end
  end
end
