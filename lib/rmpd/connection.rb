require "socket"


module Rmpd
  class Connection
    include Socket::Constants

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

      $stderr.puts read_response # protocol version, ignore for now

      if @config.password
        send_command("password", @config.password)
        $stderr.puts read_response
      end
    end

    def send_command(command, *args)
      @socket.puts("#{command} #{args.join(" ")}")
    end

    def read_response
      response = []

      while (line = @socket.readline)
        response << line.strip
        break if END_RE === line
      end

      # check_protocol_status(response.pop)

      response
    end


    private

    def check_protocol_status(status)
      raise MpdAckError.new($~) if ACK_RE === status
    end

  end
end
