module Rmpd
  module Commands

    simple_command :listplaylist, :min_version => [0, 13, 0]
    simple_command :listplaylistinfo, :min_version => [0, 12, 0]
    simple_command :playlistfind, :min_version => [0, 13, 0]
    simple_command :playlistid
    simple_command :playlistinfo
    simple_command :playlistsearch, :min_version => [0, 13, 0]
    simple_command :plchanges
    simple_command :plchangesposid

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
    simple_command :addid

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
