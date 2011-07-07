# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rmpd/version"

Gem::Specification.new do |s|
  s.name        = "rmpd"
  s.version     = Rmpd::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Eric Wollesen"]
  s.email       = ["ericw@xmtp.net"]
  s.homepage    = "http://github.com/ewollesen/rmpd"
  s.summary     = %q{Music Player Daemon client in Ruby}
  s.description = %q{Music Player Daemon client in Ruby}

  # s.rubyforge_project = "rmpd"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency("rspec", "~> 2.6.0")
  s.add_development_dependency("ruby-debug")
  s.add_development_dependency("rake")
end
