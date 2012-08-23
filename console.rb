require "pry"

require "rmpd"
require "ruby-debug"

mpd = Rmpd::Connection.new

class Foo
  include Rmpd::Commands

  def mpd
    @mpd ||= Rmpd::Connection.new
  end
end

f = Foo.new

binding.pry
