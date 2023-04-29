module RubyBots
  module Chattable
    def response(input, &block)
      run_input_validations(input)

      raise RubyBots::InvalidInputError, { errors: @errors } if @errors.any?

      run(input, &block)
    end

    private

    def run(input, &block)
      raise NotImplementedError
    end
  end
end
