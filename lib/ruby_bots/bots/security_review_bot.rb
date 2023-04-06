module RubyBots
  class SecurityReviewBot < OpenAIChatBot
    DEFAULT_DESCRIPTION = "This bot will use OpenAI to determine the appropriate tool. It will also chat responses to the user to clarify their request."

    def initialize(name: "OpenAI chat bot", description: DEFAULT_DESCRIPTION, tools: nil)
      super(name: name, description: description, tools: tools)
    end

    def ruby_system_instructions
      <<~'PROMPT'
      You are assisting a code review for a multi-tenant Ruby on Rails application. Your primary focus is identifying potential security vulnerabilities. You are a detail oriented and extremely helpful code reviewer. 

      You will be provided ruby code. You should consider every line, but most lines will not have an issue and for those you should say the line number in Lx format followed by "OK" like "L4 OK". Otherwise, you should say the line number followed by "unsafe:" followed by the code itself.  

      Here are some examples of kinds of vulnerabilities flagged as unsafe, with a safer "suggestion:" if applicable. The suggestion may either be ruby code or a higher level consideration in plain text. Keep in mind that you are not limited to these specific examples when detecting vulnerabilities, please consider all relevant types of security issues.

      It is unsafe to run queries directly on ActiveRecord models, which will look like a capitalized word followed by .find or .where, like "Test.find(params[:id))". Instead they should be queried associated with Account.current to prevent cross-account data access. Example: 
      L1 unsafe: Feature.find(params[:id]) 
      suggestion: ```ruby
      Account.current.features.find(params[:id])
      ```

      It is unsafe to directly interpolate strings into SQL queries because of SQL injection. Example:
      L1 unsafe: Account.current.features.where("features.workflow_status_id IN #{params[:workflow_status_ids]}") # vulnerable to sql injection
      suggestion: ```ruby
      Account.current.features.where("features.workflow_status_id IN (?)", workflow_status_ids) # bind params are safe
      ```

      L1 OK
      L2 OK
      L3 unsafe: user_input.constantize
      suggestion: Use a whitelist to ensure only expected class values can used for constantize.

      L1 unsafe: User.exists?(params[:user_id]) # vulnerable to SQL injection

      It is unsafe to redirect to a param value without validation. Example:
      L1 unsafe: redirect_to params[:return_to]
      suggestion: Validate that the redirect value is safe.

      L1 OK
      L2 OK
      L3 OK
      L4 unsafe: open(params[:filename]) { |file| file.read } # unsafe because Kernel#open executes OS command if the argument starts with a vertical bar (|).
      suggestion: Use a safer method for opening the file. ```ruby
      File.open(params[:filename]) { |file| file.read } if allowed_filename?(params[:filename]) # File.open doesn't execute commands
      ```
      PROMPT
    end

    def javascript_system_instructions
      <<~'PROMPT'
      You are assisting a code review of javascript code changes. Your primary focus is identifying potential security vulnerabilities.

      You will be provided code and you should flag any lines that contain a vulnerability. You should consider every line, but most lines will not have a vulnerability and for those you should say the line number in Lx format followed by "OK". Example for a line four where you have no concerns: "L4 OK". Otherwise, you should say the line number followed by "unsafe:" followed by the code itself. 

      Example:
      L1 OK
      L2 OK
      L3 unsafe: document.getElementById("temp").innerHTML = user_input;
      PROMPT
    end

    def review_code(code, filetype: "ruby", temperature: 0)

      system_instructions = case filetype
      when "ruby"
        ruby_system_instructions
      when "javascript"
        javascript_system_instructions
      else 
        raise "Unsupported filetype: #{filetype}"
      end

      @messages = [
        { role: :system, content: system_instructions },
        { role: :user, content: code }
      ]
      
      input = ""
      while(input!="exit" && input!="pexit")
        bot_puts "\nprocessing..."      
        response = client.chat(parameters: params.merge(temperature: temperature))
        
        bot_output = response.dig("choices", 0, "message", "content")

        @messages << { role: :assistant, content: bot_output }

        bot_puts "RESPONSE =>\n" + remove_ok_lines(bot_output) + "\n\n"

        input = gets.chomp

        @messages << { role: :user, content: input }
      end

      if input == "pexit"
        @messages.each do |message|
          puts "#{message[:role]}: #{message[:content]}"
        end
      end
    rescue StandardError => e
      puts "rescued error #{e.inspect}"
    end

    OK_LINE_REGEX = /L\d+ OK\n?/
    def remove_ok_lines(bot_output)
      bot_output&.gsub(OK_LINE_REGEX, "") # remove OK lines
    end

    def params
      {
        messages: @messages
      }.merge(default_params)
    end

    def bot_puts(message)
      puts "\e[35m#{message}\e[0m"
    end
  end
end