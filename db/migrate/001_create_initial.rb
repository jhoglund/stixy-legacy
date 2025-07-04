class CreateInitial < ActiveRecord::Migration
  def self.up
    create_table "boards", :options => "TYPE=MyISAM" do |t|
      t.column "title", :string, :default => "", :null => false
      t.column "url", :string, :default => "", :null => false
      t.column "description", :text, :default => "", :null => false
      t.column "visible", :integer, :limit => 4, :default => 0, :null => false
      t.column "editable", :integer, :limit => 4, :default => 0, :null => false
      t.column "pwd_protected", :integer, :limit => 4, :default => 0, :null => false
      t.column "pwd", :integer, :limit => 60
      t.column "status", :integer, :limit => 4, :default => 1, :null => false
      t.column "created_on", :datetime, :null => false
      t.column "updated_on", :datetime, :null => false
      t.column "created_by_id", :integer, :default => 1, :null => false
      t.column "updated_by_id", :integer, :default => 1, :null => false
    end

    add_index "boards", ["title"], :name => "boards_title_index"
    add_index "boards", ["status", "created_by_id", "updated_by_id"], :name => "boards_status_index"

    create_table "boards_users", :id => false, :options => "TYPE=MyISAM" do |t|
      t.column "user_id", :integer, :default => 0, :null => false
      t.column "board_id", :integer, :default => 0, :null => false
    end

    add_index "boards_users", ["user_id", "board_id"], :name => "boards_users_user_id_index", :unique => true

    create_table "boards_widgets", :id => false, :options => "TYPE=MyISAM" do |t|
      t.column "board_id", :integer, :default => 0, :null => false
      t.column "widget_id", :integer, :default => 0, :null => false
    end

    add_index "boards_widgets", ["widget_id", "board_id"], :name => "boards_widgets_widget_id_index", :unique => true

    create_table "invites", :options => "TYPE=MyISAM" do |t|
      t.column "board_id", :integer, :default => 0, :null => false
      t.column "inviter_user_id", :integer, :default => 0, :null => false
      t.column "accepted_user_id", :integer
      t.column "nick_name", :string
      t.column "first_name", :string
      t.column "last_name", :string
      t.column "email", :string
      t.column "reference_token", :string
      t.column "invitation_text", :text
      t.column "status", :integer, :limit => 4, :default => 0, :null => false
    end

    add_index "invites", ["board_id", "inviter_user_id", "accepted_user_id", "status"], :name => "invites_board_id_index"

    create_table "keywords", :options => "TYPE=MyISAM" do |t|
      t.column "tag", :string, :default => "", :null => false
      t.column "created_on", :datetime, :null => false
      t.column "updated_on", :datetime, :null => false
      t.column "created_by_id", :integer, :default => 1, :null => false
      t.column "updated_by_id", :integer, :default => 1, :null => false
    end

    add_index "keywords", ["tag"], :name => "keywords_tag_index"

    create_table "boards_keywords", :id => false, :options => "TYPE=MyISAM" do |t|
      t.column "board_id", :integer, :default => 0, :null => false
      t.column "keyword_id", :integer, :default => 0, :null => false
    end

    add_index "boards_keywords", ["board_id", "keyword_id"], :name => "keywords_boards_board_id_index", :unique => true

    create_table "library_documents", :options => "TYPE=MyISAM" do |t|
      t.column "file", :binary
      t.column "user_id", :integer, :default => 0, :null => false
      t.column "content_type", :string, :default => "", :null => false
      t.column "file_name", :string, :default => "", :null => false
      t.column "created_on", :datetime, :null => false
      t.column "updated_on", :datetime, :null => false
    end

    create_table "library_documents_widget_instances", :id => false, :options => "TYPE=MyISAM" do |t|
      t.column "library_document_id", :integer, :default => 0, :null => false
      t.column "widget_instance_id", :integer, :default => 0, :null => false
    end

    add_index "library_documents_widget_instances", ["library_document_id", "widget_instance_id"], :name => "library_documents_widget_instances_library_document_id_index", :unique => true

    create_table "library_photos", :options => "TYPE=MyISAM" do |t|
      t.column "file", :binary
      t.column "user_id", :integer, :default => 0, :null => false
      t.column "content_type", :string, :default => "", :null => false
      t.column "file_name", :string, :default => "", :null => false
      t.column "created_on", :datetime, :null => false
      t.column "updated_on", :datetime, :null => false
      t.column "variant_of_id", :integer
      t.column "width", :integer, :default => 0
      t.column "height", :integer, :default => 0
      t.column "filter", :integer, :limit => 4, :default => 0
      t.column "rotation", :integer, :limit => 4, :default => 0
    end

    create_table "library_photos_widget_instances", :id => false, :options => "TYPE=MyISAM" do |t|
      t.column "library_photo_id", :integer, :default => 0, :null => false
      t.column "widget_instance_id", :integer, :default => 0, :null => false
    end

    add_index "library_photos_widget_instances", ["library_photo_id", "widget_instance_id"], :name => "library_photos_widget_instances_library_photo_id_index", :unique => true

    create_table "roles", :options => "TYPE=MyISAM" do |t|
      t.column "name", :string, :limit => 30, :default => "", :null => false
      t.column "status", :integer, :limit => 4, :default => 0, :null => false
      t.column "is_visible", :integer, :limit => 4, :default => 1, :null => false
      t.column "is_locked", :integer, :limit => 4, :default => 1, :null => false
      t.column "created_by_id", :integer, :default => 1, :null => false
      t.column "created_on", :datetime, :null => false
      t.column "updated_on", :datetime, :null => false
      t.column "updated_by_id", :integer, :default => 1, :null => false
    end

    create_table "roles_users", :id => false, :options => "TYPE=MyISAM" do |t|
      t.column "user_id", :integer, :default => 0, :null => false
      t.column "role_id", :integer, :default => 0, :null => false
    end

    add_index "roles_users", ["user_id", "role_id"], :name => "roles_users_user_id_index", :unique => true
    
    create_table "users_contacts", :id => false, :options => "TYPE=MyISAM" do |t|
      t.column "user_id", :integer, :default => 0, :null => false
      t.column "contact_id", :integer, :default => 0, :null => false
    end

    add_index "users_contacts", ["user_id", "contact_id"], :name => "contact_id", :unique => true
    
    create_table "user_images", :options => "TYPE=MyISAM" do |t|
      t.column "user_id", :integer, :default => 0, :null => false
      t.column "content_type", :string, :default => "", :null => false
      t.column "filename", :string
      t.column "kind", :string
      t.column "image", :binary
    end

    create_table "users", :options => "TYPE=MyISAM" do |t|
      t.column "login", :string, :null => false
      t.column "email", :string, :null => false
      t.column "pwd", :string, :limit => 60, :null => true
      t.column :crypted_password,          :string, :limit => 40
      t.column :salt,                      :string, :limit => 40
      t.column :remember_token,            :string
      t.column :remember_token_expires_at, :datetime
      t.column "nick_name", :string
      t.column "first_name", :string
      t.column "last_name", :string
      t.column "description", :text
      t.column "last_login_date", :datetime
      t.column "created_on", :datetime, :null => false
      t.column "updated_on", :datetime, :null => false
      t.column "created_by_id", :integer, :default => 0, :null => false
      t.column "updated_by_id", :integer, :default => 0, :null => false
      t.column "status", :integer, :limit => 4, :default => 1, :null => false
      t.column "address", :string
      t.column "city", :string
      t.column "state", :string, :limit => 60
      t.column "zip", :string, :limit => 20
      t.column "country", :string, :limit => 60
      t.column "phone", :string, :limit => 60
      t.column "mobile_phone", :string, :limit => 60
      t.column "pref_enable_grag_drop", :integer, :limit => 4, :default => 0
      t.column "pref_send_email_and_mobile", :integer, :limit => 4, :default => 0
      t.column "pref_photo_auto_upload", :integer, :limit => 4, :default => 0
    end

    add_index "users", ["login"], :name => "users_login_index", :unique => true
    add_index "users", ["status"], :name => "users_status_index"

    create_table "widget_instance_styles", :options => "TYPE=MyISAM" do |t|
      t.column "value", :string
      t.column "name", :string, :limit => 50
      t.column "attribute", :string, :limit => 50
      t.column "widget_instance_id", :integer, :default => 0, :null => false
    end

    create_table "widget_instance_texts", :options => "TYPE=MyISAM" do |t|
      t.column "value", :text
      t.column "name", :string, :limit => 50
      t.column "widget_instance_id", :integer, :default => 0, :null => false
    end

    create_table "widget_instances", :options => "TYPE=MyISAM" do |t|
      t.column "board_id", :integer, :default => 0, :null => false
      t.column "widget_id", :integer, :default => 0, :null => false
      t.column "top", :integer, :default => 100 
      t.column "left", :integer, :default => 100
      t.column "width", :integer
      t.column "height", :integer
      t.column "zindex", :double, :default => 0, :null => false
      t.column "auto_front", :integer, :default => 0, :null => false
      t.column "opacity", :integer, :default => 1, :null => false
      t.column "opacity_value", :integer, :default => 100, :null => false
      t.column "proportional", :integer, :default => 0, :null => false
      t.column "shadow", :integer, :default => 1, :null => false
      t.column "created_by_id", :integer, :default => 0, :null => false
      t.column "updated_by_id", :integer, :default => 0, :null => false
      t.column "created_on", :datetime, :null => false
      t.column "updated_on", :datetime, :null => false
    end

    create_table "widgets", :options => "TYPE=MyISAM" do |t|
      t.column "name", :string, :limit => 30, :default => "untitled", :null => false
    end
  end
  
  def self.down
    drop_table "boards"
    drop_table "boards_users"
    drop_table "boards_widgets"
    drop_table "invites"
    drop_table "keywords"
    drop_table "keywords_boards"
    drop_table "library_documents"
    drop_table "library_documents_widget_instances"
    drop_table "library_photos"
    drop_table "library_photos_widget_instances"
    drop_table "roles_users"
    drop_table "users_contacts"
    drop_table "user_images"
    drop_table "users"
    drop_table "widget_instance_styles"
    drop_table "widget_instance_texts"
    drop_table "widget_instances"
    drop_table "widgets"
  end
end
