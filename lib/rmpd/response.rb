require "delegate"

module Rmpd
  class Response < SimpleDelegator

    KEY_VALUE_RE = /^([^:]+):\s*(.*)$/
    KNOWN_INT_FIELDS = [
                        "bitrate",
                        "consume",
                        "id",
                        "nextsong",
                        "nextsongid",
                        "playlist",
                        "playlistlength",
                        "playtime",
                        "pos",
                        "queued",
                        "random",
                        "repeat",
                        "single",
                        "song",
                        "songid",
                        "songs",
                        "track",
                        "volume",
                        "xfade",
                       ]
    KNOWN_FLOAT_FIELDS = [
                          "elapsed",
                          "mixrampdb",
                         ]
    KNOWN_COMPLEX_FIELDS = [
                            "time",
                            "audio"
                           ]
    MULTI_RESPONSE_COMMANDS = [
                               "commands",
                               "find",
                               "idle",
                               "list",
                               "outputs",
                               "playlistinfo",
                               "plchanges",
                               "plchangesposid",
                               "search",
                               "tagtypes",
                              ]


    attr_reader :error


    def self.choose_strategy(name)
      if MULTI_RESPONSE_COMMANDS.include?(name.to_s)
        [Array, ResponseMultiStrategy]
      else
        [Hash, ResponseSingleStrategy]
      end
    end

    def self.factory(command_name)
      if MULTI_RESPONSE_COMMANDS.include?(command_name.to_s)
        MultiResponse.new
      else
        SingleResponse.new
      end
    end

    def initialize(parent)
      super
      @error = nil
    end

    def marshal_dump
      [@delegate_sd_obj, @error]
    end

    def marshal_load(array)
      @delegate_sd_obj, @error = array
      each {|k, v| define_getter(k)}
    end

    def ok?
      @error.nil?
    end

    def ack?
      !ok?
    end

    def parse(lines)
      lines.each do |line|
        case line
        when KEY_VALUE_RE
          register_key_val_pair($~)
        when ACK_RE
          @error = $~[0]
          break
        when OK_RE
          break
        else
          $stderr.puts "Don't know how to parse: #{line}"
        end
      end

      self
    end


    protected

    def transform_value(key, val)
      val = val.to_i if KNOWN_INT_FIELDS.include?(key)
      val = val.to_f if KNOWN_FLOAT_FIELDS.include?(key)
      val = send("parse_complex_#{key}", val) if KNOWN_COMPLEX_FIELDS.include?(key.to_s)
      val = val.to_s.encode("UTF-8", {:invalid => :replace, :undef => :replace, :replace => "?"}) if val.is_a?(String)
      val
    end

    # time can be either an integer (playlistinfo) or elapsed:total (status)
    def parse_complex_time(value)
      if /:/ === value
        value.split(":", 2).map(&:to_i)
      else
        value.to_i
      end
    end

    def parse_complex_audio(value)
      value.split(":", 3).map(&:to_i)
    end

    def define_getter(key, instance=self)
      instance.class.send(:define_method, key.to_s.gsub(/-/, "_")) {self[key]}
    end

  end

  class MultiResponse < Response

    def initialize
      super([])
    end

    def parse(lines)
      @first_key = nil
      @temp = NilHash.new

      super(lines)
      self << @temp unless @temp.empty?
      self
    end

    def register_key_val_pair(match_data)
      key = match_data[1].downcase
      val = transform_value(key, match_data[2])

      if @first_key == key
        self << @temp
        @temp = NilHash.new({key => val})
      else
        @first_key ||= key
        @temp[key] = val
      end
      define_getter(key, @temp) unless respond_to?(key)
    end

  end

  class SingleResponse < Response

    def initialize
      super(NilHash.new)
    end

    def register_key_val_pair(match_data)
      key = match_data[1].downcase
      val = transform_value(key, match_data[2])

      self[key] = include?(key) ? ([self[key]] << val).flatten : val
      define_getter(key)
    end

  end
end
