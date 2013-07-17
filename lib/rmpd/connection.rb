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

    def close
      @socket.close
    end

    def connect
      return unless @socket.nil? || @socket.closed?

      if %r{^/} === @config.hostname
        connect_unix_socket
      else
        connect_inet_socket
      end

      read_response # protocol version, ignore for now
      password(@config.password) if @config.password
    end

    def connect_unix_socket
      @socket = UNIXSocket.new(@config.hostname)
    rescue StandardError => error
      @socket = nil
      raise MpdConnRefusedError.new(error)
    end

    def connect_inet_socket
      Socket::getaddrinfo(@config.hostname, @config.port, nil, SOCK_STREAM).each do |info|
        begin
          sockaddr = Socket.pack_sockaddr_in(info[1], info[3])
          @socket = Socket.new(info[4], info[5], 0)
          @socket.connect(sockaddr)
        rescue StandardError => error
          @socket = nil
          raise MpdConnRefusedError.new(error)
        else
          break
        end
      end
    end

    def send_command(command, *args)
      tries = 0

      begin
        connect
        @socket.puts("#{command} #{quote(args).join(" ")}".strip)
      rescue Errno::EPIPE, EOFError
        @socket.close
        if (tries += 1) < MAX_RETRIES
          retry
        else
          raise MpdError.new("Retry count exceeded")
        end
      end
    end

    def read_response
      response = []

      while (line = @socket.readline.force_encoding("UTF-8"))
        response << line.strip
        break if END_RE === line
      end
      response
    end

    def mpd
      self
    end

    def quote(args)
      args.collect {|arg| "\"#{arg.to_s.gsub(/"/, "\\\"").gsub(/\\/, "\\\\\\\\")}\""}
    end

  end
end
