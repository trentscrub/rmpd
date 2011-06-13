require "socket"


module Rmpd
  class Connection

    include Rmpd::Commands
    include Socket::Constants

    attr_reader :error

    def initialize(config_file=nil)
      @config = Rmpd::Config.new(config_file)
      @socket = nil
    end

    def server_version
      "#{@server_version_major}.#{@server_version_minor}.#{@server_version_patch}"
    end

    attr_reader :socket

    private

    def authenticate
      raise "Socket no good!" if (@socket.nil? || @socket.closed?)
      send_command("password", @config.password)
      read_response
      true
    end

    def connect
      return unless @socket.nil? || @socket.closed?
      error = nil

      Socket::getaddrinfo(@config.hostname, @config.port, nil, SOCK_STREAM).each do |info|
        begin
          puts "args: #{info.inspect}" if $DEBUG
          sockaddr = Socket.pack_sockaddr_in(info[1], info[3])
          @socket = Socket.new(info[4], info[5], 0)
          @socket.connect(sockaddr)
        rescue StandardError => error
          $stderr.puts "Failed to connect to #{info[3]}: #{error}"
          @socket = nil
        else
          break
        end
      end
      raise MpdConnRefusedError.new(error) if @socket.nil?

      parse_server_version(@socket.readline)
      authenticate if @config.password
    end

    def parse_server_version(version)
      /OK MPD (\d+)\.(\d+)\.(\d+)/.match(version.to_s)
      @server_version_major = $~[1].to_i
      @server_version_minor = $~[2].to_i
      @server_version_patch = $~[3].to_i
    end

    def read_response(klass=Response, *args)
      x = klass.new(receive_server_response, *args)
      @error = x.error
      x
    end

    def server_version_at_least(major, minor, patch)
      connect
      e = MpdError.new("Requires server version #{major}.#{minor}.#{patch}")

      raise e if major > @server_version_major
      return true if major < @server_version_major

      raise e if minor > @server_version_minor
      return true if minor < @server_version_minor

      raise e if patch > @server_version_patch
      return true if patch < @server_version_patch
      true
    end

  end
end
