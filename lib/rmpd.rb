require File.join(File.dirname(__FILE__), "rmpd/config")
require File.join(File.dirname(__FILE__), "rmpd/commands")
require File.join(File.dirname(__FILE__), "rmpd/connection")
require File.join(File.dirname(__FILE__), "rmpd/multi_response")
require File.join(File.dirname(__FILE__), "rmpd/response")

module Rmpd
  ACK_RE = /^ACK \[(\d+)@(\d+)\] \{([^}]*)\} (.*)$/
  OK_RE = /^OK.*$/

  class MpdError < Exception ; end

  class MpdConnRefusedError < MpdError ; end

  class MpdAckError < MpdError
    def initialize(regex_match)
      @error, @command_list_num, @current_command, @message = regex_match.values_at(1..-1)
    end

    def to_s
      "ACK [#{@error}@#{@command_list_num}] {#{@current_command}} #{@message}"
    end
  end

end
