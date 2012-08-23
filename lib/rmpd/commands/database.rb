module Rmpd
  module Commands

    simple_command :count
    simple_command :find
    simple_command :list
    simple_command :listall
    simple_command :listallinfo
    simple_command :lsinfo
    simple_command :search

    alias_method :list_all, :listall
    alias_method :list_all_info, :listallinfo
    alias_method :ls_info, :lsinfo

  end
end
