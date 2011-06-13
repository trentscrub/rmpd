module Rmpd
  module Commands

    simple_command :_volume
    simple_command :crossfade
    simple_command :next
    simple_command :pause
    simple_command :play
    simple_command :playid
    simple_command :previous
    simple_command :random
    simple_command :repeat
    simple_command :seek
    simple_command :seekid
    simple_command :setvol
    simple_command :stop

    def volume(*args)
      $stderr.puts "volume is deprecated, use setvol instead"
      _volume(*args)
    end

    alias_method :cross_fade, :crossfade
    alias_method :play_id, :playid
    alias_method :prev, :previous
    alias_method :seek_id, :seekid
    alias_method :set_vol, :setvol

  end
end
