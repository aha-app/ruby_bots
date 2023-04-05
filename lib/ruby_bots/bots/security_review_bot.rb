module RubyBots
  class SecurityReviewBot < OpenAIChatBot
    DEFAULT_DESCRIPTION = "This bot will use OpenAI to determine the appropriate tool. It will also chat responses to the user to clarify their request."

    def initialize(name: "OpenAI chat bot", description: DEFAULT_DESCRIPTION, tools: nil)
      super(name: name, description: description, tools: tools)
    end

    def ruby_system_instructions
      <<~'PROMPT'
      You are assisting a code review of ruby code changes. Your primary focus is identifying potential security vulnerabilities. 

      You will be provided a git diff and you should flag any lines that contain a potential vulnerability. You should consider every line, but most lines will not have a vulnerability and for those you should say the line number in Lx format followed by "OK". Example for a line four where you have no concerns: "L4 OK". Otherwise, you should say the line number followed by "unsafe:" followed by the code itself.  

      Here are some specific kinds of vulnerabilities preceded by "unsafe:" with a comment explaining the concern, with a safe "suggestion:" if applicable. Keep in mind that you are not limited to these specific examples when detecting vulnerabilities.

      It is unsafe to run queries directly on ActiveRecord models, which will look like a capitalized word followed by .find or .where, like "Test.find(params[:id))". Instead they should be queried associated with Account.current to prevent cross-account data access. Example: 
      L1 unsafe: Feature.find(params[:id]) 
      suggestion: Account.current.features.find(params[:id])

      It is unsafe to directly interpolate strings into SQL queries because of SQL injection. Many ActiveRecord methods like exists? and order can also be unsafe when used with params. Example:
      L1 unsafe: Account.current.features.where("features.workflow_status_id IN #{params[:workflow_status_ids]}") # vulnerable to sql injection
      suggestion: Account.current.features.where("features.workflow_status_id IN (?)", workflow_status_ids) # bind params are safe

      L1 OK
      L2 OK
      L3 unsafe: user_input.constantize 

      L1 unsafe: User.exists?(params[:user_id]) # vulnerable to SQL injection

      L1 unsafe: redirect_to params[:return_to] # vulnerable to open redirect
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

    def review_code(input, filetype: "ruby")

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
        { role: :user, content: input }
      ]
      
      while(input!="exit")
        puts "\nprocessing..."      
        response = client.chat(parameters: params)
        
        bot_output = response.dig("choices", 0, "message", "content")

        @messages << { role: :assistant, content: bot_output }

        puts "RESPONSE =>\n" + remove_ok_lines(bot_output) + "\n\n"

        input = gets.chomp

        @messages << { role: :user, content: input }
      end
    end

    OK_LINE_REGEX = /L\d+ OK\n?/
    def remove_ok_lines(bot_output)
      bot_output.gsub(OK_LINE_REGEX, "") # remove OK lines
    end

    def params
      {
        messages: @messages
      }.merge(default_params)
    end
  end
end