class AlterDefault3 < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE boards_keywords                     CHANGE board_id board_id                        int(11) DEFAULT NULL"
    execute "ALTER TABLE boards_keywords                     CHANGE keyword_id keyword_id                    int(11) DEFAULT NULL"
    execute "ALTER TABLE boards_users                        CHANGE board_id board_id                        int(11) DEFAULT NULL"
    execute "ALTER TABLE boards_users                        CHANGE user_id user_id                          int(11) DEFAULT NULL"
    execute "ALTER TABLE boards_widgets                      CHANGE board_id board_id                        int(11) DEFAULT NULL"
    execute "ALTER TABLE boards_widgets                      CHANGE widget_id widget_id                      int(11) DEFAULT NULL"
    execute "ALTER TABLE invites                             CHANGE inviter_user_id inviter_user_id          int(11) DEFAULT NULL"
    execute "ALTER TABLE invites                             CHANGE accepted_user_id accepted_user_id        int(11) DEFAULT NULL"
    execute "ALTER TABLE library_documents_widget_instances  CHANGE library_document_id library_document_id  int(11) DEFAULT NULL"
    execute "ALTER TABLE library_documents_widget_instances  CHANGE widget_instance_id widget_instance_id    int(11) DEFAULT NULL"
    execute "ALTER TABLE library_photos_widget_instances     CHANGE library_photo_id library_photo_id        int(11) DEFAULT NULL"
    execute "ALTER TABLE library_photos_widget_instances     CHANGE widget_instance_id widget_instance_id    int(11) DEFAULT NULL"
    execute "ALTER TABLE widget_instance_texts               CHANGE widget_instance_id widget_instance_id    int(11) DEFAULT NULL"
    execute "ALTER TABLE widget_instance_styles              CHANGE widget_instance_id widget_instance_id    int(11) DEFAULT NULL"
    execute "ALTER TABLE widget_instances                    CHANGE widget_id widget_id                      int(11) DEFAULT NULL"
    execute "ALTER TABLE widget_instances                    CHANGE board_id board_id                        int(11) DEFAULT NULL"
    
    #change_column "boards_keywords", "board_id",                                :integer, :limit => 4, :default => nil, :null => true
    #change_column "boards_keywords", "keyword_id",                              :integer, :limit => 4, :default => nil, :null => true
    #change_column "boards_users", "board_id",                                   :integer, :limit => 4, :default => nil, :null => true
    #change_column "boards_users", "user_id",                                    :integer, :limit => 4, :default => nil, :null => true
    #change_column "boards_widgets", "board_id",                                 :integer, :limit => 4, :default => nil, :null => true
    #change_column "boards_widgets", "widget_id",                                :integer, :limit => 4, :default => nil, :null => true
    #change_column "invites", "inviter_user_id",                                 :integer, :limit => 4, :default => nil, :null => true
    #change_column "invites", "accepted_user_id",                                :integer, :limit => 4, :default => nil, :null => true
    #change_column "library_documents_widget_instances", "library_document_id",  :integer, :limit => 4, :default => nil, :null => true
    #change_column "library_documents_widget_instances", "widget_instance_id",   :integer, :limit => 4, :default => nil, :null => true
    #change_column "library_photos_widget_instances", "library_photo_id",        :integer, :limit => 4, :default => nil, :null => true
    #change_column "library_photos_widget_instances", "widget_instance_id",      :integer, :limit => 4, :default => nil, :null => true
    #change_column "widget_instance_texts", "widget_instance_id",                :integer, :limit => 4, :default => nil, :null => true
    #change_column "widget_instance_styles", "widget_instance_id",               :integer, :limit => 4, :default => nil, :null => true
    #change_column "widget_instances", "widget_id",                              :integer, :limit => 4, :default => nil, :null => true
    #change_column "widget_instances", "board_id",                               :integer, :limit => 4, :default => nil, :null => true
  end            
                 
  def self.down  
    change_column "boards_keywords", "board_id", :integer, :limit => 4, :default => 0, :null => false
    change_column "boards_keywords", "keyword_id", :integer, :limit => 4, :default => 0, :null => false
    change_column "boards_users", "board_id", :integer, :limit => 4, :default => 0, :null => false
    change_column "boards_users", "user_id", :integer, :limit => 4, :default => 1, :null => false
    change_column "boards_widgets", "board_id", :integer, :limit => 4, :default => 0, :null => false
    change_column "boards_widgets", "widget_id", :integer, :limit => 4, :default => 0, :null => false
    change_column "invites", "inviter_user_id", :integer, :limit => 4, :default => 1, :null => false
    change_column "invites", "accepted_user_id", :integer, :limit => 4, :default => 1, :null => false
    change_column "library_documents_widget_instances", "library_document_id", :integer, :limit => 4, :default => 0, :null => false
    change_column "library_documents_widget_instances", "widget_instance_id", :integer, :limit => 4, :default => 0, :null => false
    change_column "library_photos_widget_instances", "library_photo_id", :integer, :limit => 4, :default => 0, :null => false
    change_column "library_photos_widget_instances", "widget_instance_id", :integer, :limit => 4, :default => 0, :null => false
    change_column "widget_instance_texts", "widget_instance_id", :integer, :limit => 4, :default => 0, :null => false
    change_column "widget_instance_styles", "widget_instance_id", :integer, :limit => 4, :default => 0, :null => false
    change_column "widget_instances", "widget_id", :integer, :limit => 4, :default => 0, :null => false
    change_column "widget_instances", "board_id", :integer, :limit => 4, :default => 0, :null => false
  end
end
