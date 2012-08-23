require "delegate"

module Rmpd

  KEY_VALUE_RE = /^([^:]+):\s*(.*)$/
  KNOWN_INT_FIELDS = [:pos, :id, :track, :playlistlength, :playlist,
    :xfade, :repeat, :random, :queued, :volume, :song, :songid, :bitrate, :nextsongid, :single, :consume, :nextsong]
  KNOWN_FLOAT_FIELDS = [:elapsed, :mixrampdb]
  KNOWN_COMPLEX_FIELDS = [:time, :audio]

  class Response < DelegateClass(Hash)

    attr_reader :error

    def initialize(lines=[])
      super({})
      @error = nil
      parse(lines)
    end

    def ok?
      @error.nil?
    end

    def ack?
      !ok?
    end


    private

    def register_key_val_pair(match_data)
      key, val = match_data[1].downcase.to_sym, match_data[2]

      val = val.to_i if KNOWN_INT_FIELDS.include?(key)
      val = val.to_f if KNOWN_FLOAT_FIELDS.include?(key)
      val = send("parse_complex_#{key}", val) if KNOWN_COMPLEX_FIELDS.include?(key)
      self[key] = include?(key) ? ([self[key]] << val).flatten : val
      self.class.send(:define_method, key) {self[key]}
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

  end
end
