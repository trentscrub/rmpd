require "pathname"
require "yaml"

module Rmpd

  class Config

    DEFAULT_HOSTNAME = "localhost"
    DEFAULT_PORT = 6600
    DEFAULT_PASSWORD = nil

    attr_accessor :hostname, :password, :port
    alias_method :host, :hostname

    def initialize(config_file=nil)
      case config_file
      when String, Pathname
        config = YAML::load_file(config_file)
      when File
        config = YAML::load(config_file)
      else
        config = {}
      end
      config = config[Rails.env] if defined?(Rails) && config[Rails.env]
      puts "config: #{config.inspect}" if $DEBUG
      init_host_and_password(config)
      init_port(config)
    end

    # def password
    #   @password || parse_password(ENV["MPD_HOST"]) || DEFAULT_PASSWORD
    # end
    #
    # def host
    #   @host || parse_hostname(ENV["MPD_HOST"]) || DEFAULT_HOSTNAME
    # end
    # alias_method :hostname, :host
    #
    # def port
    #   @port || ENV["MPD_PORT"] || DEFAULT_PORT
    # end


    private

    HOSTNAME_RE = /(.*)@(.*)/


    def init_host_and_password(config)
      if config["hostname"]
        @hostname = parse_hostname(config["hostname"])
        @password = parse_password(config["hostname"])
      elsif ENV["MPD_HOST"]
        @hostname = parse_hostname(ENV["MPD_HOST"])
        @password = parse_password(ENV["MPD_HOST"])
      else
        @hostname = DEFAULT_HOSTNAME
        @password = DEFAULT_PASSWORD
      end
    end

    def init_port(config)
      if config["port"]
        @port = config["port"].to_i
      elsif ENV["MPD_PORT"]
        @port = ENV["MPD_PORT"].to_i
      else
        @port = DEFAULT_PORT
      end
    end

    def parse_hostname(hostname)
      if HOSTNAME_RE === hostname
        $~[2]
      else
        hostname
      end
    end

    def parse_password(hostname)
      if HOSTNAME_RE === hostname
        $~[1]
      else
        nil
      end
    end

  end

end
