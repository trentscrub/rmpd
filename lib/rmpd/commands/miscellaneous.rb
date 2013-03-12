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

    # def idle(*subsystems)
    #   # Guard against calling idle while @in_idle here, since
    #   # Connection#check_idle can't, since we're the one setting it!
    #   raise MpdError.new("Idling. Call noidle first.") if @in_idle

    #   # TODO block signals around this block?
    #   @in_idle = true
    #   _idle(*subsystems)
    # ensure
    #   @in_idle = false
    # end

    # def noidle
    #   _noidle if @in_idle
    # ensure
    #   @in_idle = false
    # end

    alias_method :clear_error, :clearerror
    alias_method :not_commands, :notcommands
  end
end
