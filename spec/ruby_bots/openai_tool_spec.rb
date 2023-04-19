RSpec.describe RubyBots::OpenAITool do
  it 'can be initialized with a name and description' do
    tool = RubyBots::OpenAITool.new(name: 'Tool', description: 'This is a tool')
    expect(tool.name).to eq('Tool')
    expect(tool.description).to eq('This is a tool')
  end

  describe '#response' do
    it 'calls run with the prompt' do
      tool = RubyBots::OpenAITool.new(name: 'Tool', description: 'This is a tool')
      allow(tool).to receive(:run).with('This is a test prompt').and_return('answer')
      expect(tool.response('This is a test prompt')).to be_a(String)
    end

    it 'calls the OpenAI API and responds with answer' do
      tool = RubyBots::OpenAITool.new(name: 'Tool', description: 'This is a tool')

      params = {
        messages: [
          { role: :system, content: tool.system_instructions },
          { role: :user, content: 'This is a test prompt' }
        ]
      }.merge(tool.default_params)

      allow_any_instance_of(OpenAI::Client).to receive(:chat)
                                                 .with(parameters: params)
                                                 .and_return({ 'choices' => [{ 'message' => { 'content' => 'some answer' } }] })

      expect(tool.response('This is a test prompt')).to eq('some answer')
    end
  end
end
