require "delegate"

module Rmpd

  KEY_VALUE_RE = /^([^:]+):\s*(.*)$/
  KNOWN_INT_FIELDS = [:pos, :id, :track, :playlistlength, :playlist,
    :xfade, :repeat, :random, :queued, :volume, :song, :songid]
  KNOWN_COMPLEX_FIELDS = [:time,]

  class Response < DelegateClass(Hash)

    attr_reader :error

    def initialize(data)
      super({})
      @error = nil
      parse(data)
    end

    def ok?
      @error.nil?
    end

    def ack?
      !ok?
    end

    private

    def register_key_val_pair(r)
      key, val = r[1].downcase.to_sym, r[2]
      val = val.to_i if KNOWN_INT_FIELDS.include?(key)
      val = send("parse_complex_#{key}", val) if KNOWN_COMPLEX_FIELDS.include?(key)
      self[key] = include?(key) ? ([self[key]] << val).flatten : val
      self.class.send(:define_method, key) {self[key]}
    end

    def parse(data)
      data.split("\n").each do |line|
        case line
        when KEY_VALUE_RE; register_key_val_pair($~)
        when LIST_OK_RE, OK_RE; @error = nil
        when ACK_RE; @error = MpdAckError.new($~.values_at(0..-1))
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

  end
end
