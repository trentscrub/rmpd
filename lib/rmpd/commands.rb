require File.join(File.dirname(__FILE__), "commands/generators")
require File.join(File.dirname(__FILE__), "commands/admin")
require File.join(File.dirname(__FILE__), "commands/database")
require File.join(File.dirname(__FILE__), "commands/miscellaneous")
require File.join(File.dirname(__FILE__), "commands/playback")
require File.join(File.dirname(__FILE__), "commands/playlist")

module Rmpd
  module Commands

    private

    def receive_response
      lines = []

      while lines << @socket.readline do
        puts "recv: #{lines.last.strip}" if $DEBUG
        case lines.last
        when ACK_RE, OK_RE
          break
        end
      end

      lines
    end

    def send_command(command, *args)
      if in_command_list?
        @command_list << [command, args]
      else
        case command
        when /^command_list_end$/
          # blah
          @command_list = nil
        when /^command_list.*begin$/
          @command_list = [command, args]
        else
          send_command_now(command, *args)
        end
      end
    end

    def in_command_list?
      !@command_list.nil?
    end

    def send_command_now(command, *args)
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

    def send_command_old(command, *args)
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

      receive_response unless @in_command_list
    end

  end
end
