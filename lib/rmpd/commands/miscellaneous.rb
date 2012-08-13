module Rmpd
  module Commands

    complex_command :commands, :regexp => /(^command: )/i
    simple_command :notcommands, :regexp => /(^command: )/i

    simple_command :clearerror
    simple_command :idle
    simple_command :noidle
    simple_command :password
    simple_command :ping
    simple_command :stats
    simple_command :status

    def close
      send_command("close")
      @socket.close
    end

    alias_method :clear_error, :clearerror
    alias_method :not_commands, :notcommands

    def command_list
      send_command("command_list_begin")
      @in_command_list = true
      yield self
      send_command("command_list_end")
      handle_command_list_response
    ensure
      @in_command_list = false
      @in_command_list_response_regexp = nil
    end

    def command_list_ok
      send_command("command_list_ok_begin")
      @in_command_list = true
      yield self
      send_command("command_list_end")
      read_command_list_ok_responses do |responses|
        handle_command_list_response.tap do |res|
          responses << res unless res.empty?
        end
      end
    ensure
      @in_command_list = false
      @in_command_list_response_regexp = nil
    end


    private

    def handle_command_list_response
      if @in_command_list_response_regexp
        read_responses(@in_command_list_response_regexp)
      else
        read_response
      end
    end

    def read_command_list_ok_responses
      responses = []

      begin
        yield responses
      end while LIST_OK_RE === @last_response

      responses
    end
  end
end
