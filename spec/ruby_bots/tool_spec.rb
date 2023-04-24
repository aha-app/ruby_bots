RSpec.describe RubyBots::Tool do
  it "can be initialized with a name and description" do
    tool = RubyBots::Tool.new(name: "Tool", description: "This is a tool")
    expect(tool.name).to eq("Tool")
    expect(tool.description).to eq("This is a tool")
  end

  describe "validations" do
    it "can fail a validate input" do
      tool = Class.new(RubyBots::Tool) do
        validate_input :json?
        def run(input) = input
      end.new(name: "Tool", description: "This is a tool")
      expect { tool.response("") }.to raise_error(RubyBots::InvalidInputError)
      expect(tool.errors).to eq(["invalid JSON"])
    end

    it "can pass a validate input" do
      tool = Class.new(RubyBots::Tool) do
        validate_input :json?
        def run(input) = input
      end.new(name: "Tool", description: "This is a tool")
      expect(tool.response("{}")).to eq("{}")
      expect(tool.errors).to eq([])
    end

    it "can validate output" do
      tool = Class.new(RubyBots::Tool) do
        validate_output :json?
        def run(input) = input
      end.new(name: "Tool", description: "This is a tool")
      expect { tool.response("") }.to raise_error(RubyBots::InvalidOutputError)
    end

    it "can pass a validate output" do
      tool = Class.new(RubyBots::Tool) do
        validate_output :json?
        def run(input) = input
      end.new(name: "Tool", description: "This is a tool")
      expect(tool.response("{}")).to eq("{}")
      expect(tool.errors).to eq([])
    end
  end
end
