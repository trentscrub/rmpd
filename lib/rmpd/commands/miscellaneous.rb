module Rmpd
  module Commands

    simple_command :commands
    simple_command :notcommands
    simple_command :clearerror
    simple_command :_idle
    simple_command :_noidle
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

    def idle(*subsystems)
      @in_idle = true
      _idle(*subsystems)
    ensure
      @in_idle = false
    end

    def noidle
      return unless @in_idle
      _noidle
    end

    alias_method :clear_error, :clearerror
    alias_method :not_commands, :notcommands

  end
end
