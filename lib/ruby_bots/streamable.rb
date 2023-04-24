module RubyBots
  module Streamable
    def response(input)
      run_input_validations(input)

      raise RubyBots::InvalidInputError, { errors: @errors } if @errors.any?

      run(input)
    end
  end
end
