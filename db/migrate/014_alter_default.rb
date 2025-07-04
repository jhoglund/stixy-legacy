class AlterDefault < ActiveRecord::Migration
  def self.up
    User.find(:all).each do |u|
        [:nick_name, :first_name, :last_name, :description, :created_by_id, :updated_by_id, 
        :status, :address, :city, :state, :zip, :country, :phone, :mobile_phone].each do |col|
            u.update_attribute(col, "") if u[col].nil?
        end
        u.save
    end
    change_column "boards", "editable", :integer, :limit => 4, :default => 0, :null => false
    change_column "boards_users", "user_id", :integer, :default => 1, :null => false
    change_column "boards_users", "board_id", :integer, :default => 1, :null => false
    change_column "invites", "inviter_user_id", :integer, :default => 1, :null => false
    change_column "invites", "accepted_user_id", :integer, :default => 1, :null => false
    change_column "invites", "invitation_text", :text, :default => "", :null => false
    execute "ALTER TABLE library_documents MODIFY file longblob"
    change_column "library_documents", "user_id", :integer, :default => 1, :null => false
    change_column "library_photos", "user_id", :integer, :default => 1, :null => false
    change_column "roles_users", "user_id", :integer, :default => 1, :null => false
    change_column "roles_users", "role_id", :integer, :default => Role.find_by_name("anonymous role").id, :null => false
    change_column "users_contacts", "user_id", :integer, :default => 1, :null => false
    change_column "users_contacts", "contact_id", :integer, :default => 1, :null => false
    change_column "user_images", "user_id", :integer, :default => 1, :null => false
    change_column "user_images", "content_type", :string, :default => "", :null => false
    change_column "user_images", "filename", :string, :default => "", :null => false
    change_column "user_images", "kind", :string, :default => "", :null => false
    change_column "users", "nick_name", :string, :default => "", :null => false
    change_column "users", "first_name", :string, :default => "", :null => false
    change_column "users", "last_name", :string, :default => "", :null => false
    change_column "users", "description", :text, :default => "", :null => false
    change_column "users", "created_by_id", :integer, :default => 1, :null => false
    change_column "users", "updated_by_id", :integer, :default => 1, :null => false
    change_column "users", "status", :integer, :limit => 4, :default => 1, :null => false
    change_column "users", "address", :string, :default => "", :null => false
    change_column "users", "city", :string, :default => "", :null => false
    change_column "users", "state", :string, :limit => 60, :default => "", :null => false
    change_column "users", "zip", :string, :limit => 20, :default => "", :null => false
    change_column "users", "country", :string, :limit => 60, :default => "", :null => false
    change_column "users", "phone", :string, :limit => 60, :default => "", :null => false
    change_column "users", "mobile_phone", :string, :limit => 60, :default => "", :null => false
    change_column "widget_instance_styles", "value", :string, :default => "", :null => false
    change_column "widget_instance_styles", "name", :string, :limit => 50, :default => "", :null => false
    change_column "widget_instance_styles", "attribute", :string, :limit => 50, :default => "", :null => false
    change_column "widget_instance_texts", "value", :text, :default => "", :null => false
    change_column "widget_instance_texts", "name", :string, :limit => 50, :default => "", :null => false
    change_column "widget_instances", "created_by_id", :integer, :default => 1, :null => false
    change_column "widget_instances", "updated_by_id", :integer, :default => 1, :null => false
    execute "ALTER TABLE user_images MODIFY image longblob"
  end            
                 
  def self.down  
    change_column "boards", "editable", :integer, :limit => 4, :default => 0, :null => false
    change_column "boards_users", "user_id", :integer, :default => 0, :null => false
    change_column "boards_users", "board_id", :integer, :default => 0, :null => false
    change_column "invites", "inviter_user_id", :integer, :default => 0, :null => false
    change_column "invites", "accepted_user_id", :integer
    change_column "invites", "invitation_text", :text
    change_column "library_documents", "file", :binary
    change_column "library_documents", "user_id", :integer, :default => 0, :null => false
    change_column "library_photos", "user_id", :integer, :default => 0, :null => false
    change_column "roles_users", "user_id", :integer, :default => 0, :null => false
    change_column "roles_users", "role_id", :integer, :default => 0, :null => false
    change_column "users_contacts", "user_id", :integer, :default => 0, :null => false
    change_column "users_contacts", "contact_id", :integer, :default => 0, :null => false
    change_column "user_images", "user_id", :integer, :default => 0, :null => false
    change_column "user_images", "content_type", :string, :default => "", :null => false
    change_column "user_images", "filename", :string
    change_column "user_images", "kind", :string
    change_column "user_images", "image", :binary
    change_column "users", "nick_name", :string
    change_column "users", "first_name", :string
    change_column "users", "last_name", :string
    change_column "users", "description", :text
    change_column "users", "created_by_id", :integer, :default => 0, :null => false
    change_column "users", "updated_by_id", :integer, :default => 0, :null => false
    change_column "users", "address", :string
    change_column "users", "city", :string
    change_column "users", "state", :string, :limit => 60
    change_column "users", "zip", :string, :limit => 20
    change_column "users", "country", :string, :limit => 60
    change_column "users", "phone", :string, :limit => 60
    change_column "users", "mobile_phone", :string, :limit => 60
    change_column "widget_instance_styles", "value", :string
    change_column "widget_instance_styles", "name", :string, :limit => 50
    change_column "widget_instance_styles", "attribute", :string, :limit => 50
    change_column "widget_instance_texts", "value", :text
    change_column "widget_instance_texts", "name", :string, :limit => 50
    change_column "widget_instances", "created_by_id", :integer, :default => 0, :null => false
    change_column "widget_instances", "updated_by_id", :integer, :default => 0, :null => false
  end
end
