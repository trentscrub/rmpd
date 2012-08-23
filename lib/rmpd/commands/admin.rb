module Rmpd
  module Commands

    simple_command :outputs
    simple_command :tagtypes, :min_version => [0, 13, 0]
    simple_command :disableoutput
    simple_command :enableoutput
    simple_command :update
    simple_command :kill

    alias_method :disable_output, :disableoutput
    alias_method :tag_types, :tagtypes
    alias_method :enable_output, :enableoutput

  end
end
