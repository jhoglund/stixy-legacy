class ClearCache < ActionController
  def self.expire_all_actions
    path = "#{RAILS_ROOT}/tmp/cache/"
    benchmark "Expired action: #{path}" do
      File.delete(path) #if File.exists?(page_cache_path(path))
    end
  end
end