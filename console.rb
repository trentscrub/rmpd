require "pry"

require "rmpd"
require "lib/rmpd/command"
require "lib/rmpd/response_splitter"

mpd = Rmpd::Connection.new
mpd.connect

# module Rmpd
#   module Commands
#     complex_command mpd, :outputs, :regexp => /(^outputid: )/i
#   end
# end

binding.pry
