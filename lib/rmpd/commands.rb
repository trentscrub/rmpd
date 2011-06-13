require File.join(File.dirname(__FILE__), "commands/generators")
require File.join(File.dirname(__FILE__), "commands/admin")
require File.join(File.dirname(__FILE__), "commands/database")
require File.join(File.dirname(__FILE__), "commands/miscellaneous")
require File.join(File.dirname(__FILE__), "commands/playback")
require File.join(File.dirname(__FILE__), "commands/playlist")

module Rmpd
  module Commands

    private

    def read_responses(regexp=/(^file: )/i)
      read_response(MultiResponse, regexp)
    end

    def receive_server_response
      lines = []
      while lines << @socket.readline do
        puts "recv: #{lines.last.strip} (#{OK_RE === lines.last})" if $DEBUG
        case lines.last
        when ACK_RE, OK_RE: break
        end
      end
      return lines.join
    end

    def send_command(command, *args)
      tries = 0

      if $DEBUG
        a = command == "password" ? args.map{|x| "*" * 8} : args
        Kernel.puts "send: #{command.strip} #{a.join(" ")}".strip
      end

      begin
        connect
        @socket.puts("#{command} #{args.join(" ")}".strip)
      rescue Errno::EPIPE, EOFError
        @socket.close
        if (tries += 1) < 5
          retry
        else
          raise MpdError.new("Retry count exceeded")
        end
      end
    end

  end
end
