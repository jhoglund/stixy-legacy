class ExtendSessionSize < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE `sessions` CHANGE `data` `data` longtext DEFAULT NULL ;"
  end
  
  def self.down
    change_column "sessions", "data", :text
  end
end
