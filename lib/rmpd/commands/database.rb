module Rmpd
  module Commands

    complex_command :count, :regexp => /(^songs: )/i
    complex_command :find, :regexp => /(^file: )/i
    complex_command :list, :regexp => /(^[^:]+: )/i
    complex_command :listall, :regexp => /(^[^:]+: )/i
    complex_command :listallinfo, :regexp => /(^(directory|file): )/i
    complex_command :lsinfo, :regexp => /(^(directory|file): )/i
    complex_command :search, :regexp => /(^file: )/i

    alias_method :list_all, :listall
    alias_method :list_all_info, :listallinfo
    alias_method :ls_info, :lsinfo

  end
end
