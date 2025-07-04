
class SessionCleaner
  def self.remove_stale_sessions
    # TODO move this back. I need to get fixed that the right dependencies can't be found.
    # CGI::Session::ActiveRecordStore::Session.destroy_all( ['updated_at <?', (1.week+1.minute).ago] ) 
    # todo - its debatable whether the codt of cleaning orphans is worth it
    # LibraryPhoto.remove_orphans
    # LibraryDocument.remove_orphans
  end
end