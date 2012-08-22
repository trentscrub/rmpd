module Rmpd
  module Commands

    complex_command :listplaylist, :min_version => [0, 13, 0]
    complex_command :listplaylistinfo, :min_version => [0, 12, 0]
    complex_command :playlistfind, :min_version => [0, 13, 0]
    complex_command :playlistid
    complex_command :playlistinfo
    complex_command :playlistsearch, :min_version => [0, 13, 0]
    complex_command :plchanges
    complex_command :plchangesposid, :regexp => /(^Id: )/i

    simple_command :_playlist
    simple_command :add # The docs on the wiki don't line up with empirical
                        # results using 0.13.0
    simple_command :clear
    simple_command :currentsong
    simple_command :delete
    simple_command :deleteid
    simple_command :load
    simple_command :move
    simple_command :moveid
    simple_command :playlistadd, :min_version => [0, 13, 0]
    simple_command :playlistclear, :min_version => [0, 13, 0]
    simple_command :playlistdelete, :min_version => [0, 13, 0]
    simple_command :playlistmove, :min_version => [0, 13, 0]
    simple_command :rename
    simple_command :rm
    simple_command :save
    simple_command :shuffle
    simple_command :swap
    simple_command :swapid


    # must be a file only, cannot use with a directory
    def addid(path, pos=nil)
      # pos is only for r7153+, but what version is that?
      server_version_at_least(0, 14, 0) if pos
      args = [path]
      args << pos if pos
      send_command("addid", *quote(args))
      @add_id_response_regex ||= /(^Id: )/i
      if @in_command_list
        append_command_list_regexp(@add_id_response_regex)
      else
        read_response
      end
    end

    alias_method :add_id, :addid
    alias_method :current_song, :currentsong
    alias_method :delete_id, :deleteid
    alias_method :list_playlist, :listplaylist
    alias_method :list_playlist_info, :listplaylistinfo
    alias_method :move_id, :moveid
    alias_method :pl_changes, :plchanges
    alias_method :pl_changes_pos_id, :plchangesposid
    alias_method :playlist_add, :playlistadd
    alias_method :playlist_clear, :playlistclear
    alias_method :playlist_delete, :playlistdelete
    alias_method :playlist_find, :playlistfind
    alias_method :playlist_id, :playlistid
    alias_method :playlist_info, :playlistinfo
    alias_method :playlist_move, :playlistmove
    alias_method :playlist_search, :playlistsearch
    alias_method :swap_id, :swapid

  end
end
