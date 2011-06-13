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
      read_response
    ensure
      @in_command_list = false
    end
  end
end
