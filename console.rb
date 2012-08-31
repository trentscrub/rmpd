#!/usr/bin/env ruby

require "pry"
require "rmpd"
require "ruby-debug"
require "stringio"

conf = StringIO.new <<EOF
hostname: admin@localhost
port: 6601
EOF

mpd = Rmpd::Connection.new(conf)

binding.pry
