module Rmpd
  module IO

    def to_io
      send_command("idle") unless @in_idle
      @in_idle = true
      @socket
    end

    def check_select
      return unless @in_idle
      Response.factory("idle").parse(read_response)
    ensure
      @in_idle = false
    end

  end
end
