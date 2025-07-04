class AlterSessionTable < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE `sessions` DROP INDEX `session_sessid_index`;"
    execute "ALTER TABLE `sessions` CHANGE `updated_on` `updated_at` datetime DEFAULT NULL;"
    execute "ALTER TABLE `sessions` CHANGE `sessid` `session_id` varchar(32) DEFAULT NULL;"
    execute "ALTER TABLE `sessions` ADD KEY `index_sessions_on_session_id` (`session_id`);"
    execute "ALTER TABLE `sessions` ADD KEY index_sessions_on_updated_at (updated_at);"
  end
  
  def self.down
    execute "ALTER TABLE `sessions` DROP INDEX `index_sessions_on_session_id`;"
    execute "ALTER TABLE `sessions` DROP INDEX index_sessions_on_updated_at;"
    execute "ALTER TABLE `sessions` CHANGE `updated_at` `updated_on` datetime DEFAULT NULL;"
    execute "ALTER TABLE `sessions` CHANGE `session_id` `sessid` varchar(32) DEFAULT NULL;"
    execute "ALTER TABLE `sessions` ADD KEY `session_sessid_index` (sessid);"
  end
end
