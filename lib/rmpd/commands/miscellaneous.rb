module Rmpd
  module Commands

    simple_command :commands
    simple_command :notcommands
    simple_command :clearerror
    simple_command :idle
    simple_command :noidle
    simple_command :password
    simple_command :ping
    simple_command :stats
    simple_command :status
    simple_command :_close

    def close
      _close
      @socket.close
    end

    simple_command :command_list
    simple_command :command_list_ok

    alias_method :clear_error, :clearerror
    alias_method :not_commands, :notcommands

  end
end
