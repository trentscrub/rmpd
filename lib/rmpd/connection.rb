require "socket"


module Rmpd
  class Connection
    include Socket::Constants
    include Rmpd::Commands


    MAX_RETRIES = 5


    attr_reader :socket


    def initialize(config_file=nil)
      @config = Rmpd::Config.new(config_file)
      @socket = nil
    end

    def connect
      return unless @socket.nil? || @socket.closed?

      Socket::getaddrinfo(@config.hostname, @config.port, nil, SOCK_STREAM).each do |info|
        begin
          sockaddr = Socket.pack_sockaddr_in(info[1], info[3])
          @socket = Socket.new(info[4], info[5], 0)
          @socket.connect(sockaddr)
        rescue StandardError => error
          $stderr.puts "Failed to connect to #{info[3]}: #{error}"
          @socket = nil
          raise MpdConnRefusedError.new(error)
        else
          break
        end
      end

      read_response # protocol version, ignore for now
      password(@config.password) if @config.password
    end

    def send_command(command, *args)
      tries = 0

      begin
        connect
        @socket.puts("#{command} #{quote(args).join(" ")}".strip)
      rescue EOFError => e
        @socket.close
        if (tries += 1) < MAX_RETRIES
          retry
        else
          raise MpdError.new("Retry count exceeded")
        end
      end
    end

    def read_response
      tries = 0
      response = []

      begin
        while (line = @socket.readline)
          response << line.strip
          break if END_RE === line
        end
      rescue EOFError => e
        @socket.close
        if (tries += 1) < MAX_RETRIES
          retry
        else
          raise MpdError.new("Retry count exceeded")
        end
      end
      response
    end

    def mpd
      self
    end

    def quote(args)
      args.collect {|arg| "\"#{arg.to_s.gsub(/"/, "\\\"")}\""}
    end

  end
end
