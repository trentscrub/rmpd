module Rmpd
  module IO

    def with_io(&block)
      send_command("idle") unless @in_idle
      @in_idle = true
      yield @socket
    ensure
      send_command("noidle")
    end

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
