class TestChattableTool < RubyBots::Tool
  include RubyBots::Chattable

  def run(input, &block)
    output = "Hello, #{input}"
    yield(output)
  end
end

RSpec.describe RubyBots::Chattable do
  let(:test_tool) { TestChattableTool.new(name: 'test tool', description: 'Tool for testing') }

  describe '#response' do
    context 'when input is valid' do
      it 'returns the expected response' do
        expect(test_tool.response('John') { |output| "#{output}ny" }).to eq('Hello, Johnny')
      end

      it 'yields the block if given' do
        expect { |b| test_tool.response('John', &b) }.to yield_with_args('Hello, John')
      end
    end
  end
end
