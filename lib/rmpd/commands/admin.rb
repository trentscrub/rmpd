module Rmpd
  module Commands

    complex_command :outputs, :regexp => /(^outputid: )/i
    complex_command :tagtypes, :regexp => /(^tagtype: )/i, :min_version => [0, 13, 0]

    simple_command :disableoutput
    simple_command :enableoutput
    simple_command :update

    def kill
      send_command("kill")
      @socket.close
    end

    alias_method :disable_output, :disableoutput
    alias_method :tag_types, :tagtypes
    alias_method :enable_output, :enableoutput

  end
end
