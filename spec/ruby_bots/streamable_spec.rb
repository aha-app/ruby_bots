class TestTool < RubyBots::Tool
  include RubyBots::Streamable

  validate_output :json?

  def run(input)
    "Processed: #{input}"
  end
end

RSpec.describe RubyBots::Streamable do
  let(:test_tool) { TestTool.new(name: 'Test Tool', description: 'A test tool for Streamable module') }

  describe '#response' do
    it 'returns the output from the run method directly, skipping output validations' do
      input = 'Test input'
      expected_output = 'Processed: Test input'

      expect(test_tool.response(input)).to eq(expected_output)
    end
  end
end
