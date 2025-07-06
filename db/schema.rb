# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20091112135503) do

  create_table "abstract_files", :force => true do |t|
    t.integer  "user_id",                    :default => 0,  :null => false
    t.string   "type",         :limit => 20, :default => "", :null => false
    t.integer  "size",                       :default => 0,  :null => false
    t.integer  "width",                      :default => 0,  :null => false
    t.integer  "height",                     :default => 0,  :null => false
    t.integer  "filter",                     :default => 0,  :null => false
    t.integer  "rotation",                   :default => 0,  :null => false
    t.string   "content_type",               :default => "", :null => false
    t.string   "filename",                   :default => "", :null => false
    t.string   "thumbnail",    :limit => 20
    t.integer  "parent_id"
    t.string   "session_id",   :limit => 32
    t.string   "upload_id"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  add_index "abstract_files", ["user_id"], :name => "index_abstract_files_on_user_id", :unique => true
  add_index "abstract_files", ["session_id"], :name => "index_abstract_files_on_session_id", :unique => true
  add_index "abstract_files", ["upload_id", "session_id"], :name => "index_abstract_files_on_upload_id_and_session_id", :unique => true

  create_table "activities", :force => true do |t|
    t.datetime "start"
    t.datetime "stop"
    t.integer  "activatable_id"
    t.string   "activatable_type"
    t.integer  "unit",             :default => 0
    t.integer  "frequency",        :default => 1
    t.integer  "recurring_status", :default => 0
    t.integer  "status",           :default => 1
  end

  create_table "beta_testers", :force => true do |t|
    t.integer  "user_id",       :default => 1, :null => false
    t.text     "comment"
    t.datetime "created_on",                   :null => false
    t.datetime "updated_on",                   :null => false
    t.integer  "created_by_id", :default => 0, :null => false
    t.integer  "updated_by_id", :default => 0, :null => false
    t.integer  "notify_only",   :default => 0, :null => false
    t.integer  "status",        :default => 1, :null => false
  end

  create_table "board_filters", :force => true do |t|
    t.string  "filter",  :default => "", :null => false
    t.integer "user_id",                 :null => false
  end

  add_index "board_filters", ["user_id", "filter"], :name => "index_board_filters_on_user_id_and_filter", :unique => true

  create_table "boards", :force => true do |t|
    t.string   "title",                       :default => "", :null => false
    t.string   "url",                         :default => "", :null => false
    t.text     "description",                 :default => "", :null => false
    t.integer  "visible",       :limit => 4,  :default => 0,  :null => false
    t.integer  "editable",      :limit => 4,  :default => 0,  :null => false
    t.integer  "pwd_protected", :limit => 4,  :default => 0,  :null => false
    t.integer  "pwd",           :limit => 60
    t.integer  "status",        :limit => 4,  :default => 1,  :null => false
    t.datetime "created_on",                                  :null => false
    t.datetime "updated_on",                                  :null => false
    t.integer  "created_by_id",               :default => 1,  :null => false
    t.integer  "updated_by_id",               :default => 1,  :null => false
    t.integer  "left",                        :default => 0
    t.integer  "top",                         :default => 0
  end

  add_index "boards", ["title"], :name => "boards_title_index", :unique => true
  add_index "boards", ["status", "created_by_id", "updated_by_id"], :name => "boards_status_index", :unique => true

  create_table "boards_keywords", :id => false, :force => true do |t|
    t.integer "board_id",   :default => 0, :null => false
    t.integer "keyword_id", :default => 0, :null => false
  end

  add_index "boards_keywords", ["board_id", "keyword_id"], :name => "keywords_boards_board_id_index", :unique => true

  create_table "boards_users", :id => false, :force => true do |t|
    t.integer "user_id",  :default => 0, :null => false
    t.integer "board_id", :default => 0, :null => false
  end

  add_index "boards_users", ["user_id", "board_id"], :name => "boards_users_user_id_index", :unique => true

  create_table "boards_widgets", :id => false, :force => true do |t|
    t.integer "board_id",  :default => 0, :null => false
    t.integer "widget_id", :default => 0, :null => false
  end

  add_index "boards_widgets", ["widget_id", "board_id"], :name => "boards_widgets_widget_id_index", :unique => true

  create_table "boardusers", :force => true do |t|
    t.integer  "board_id",                     :null => false
    t.integer  "user_id",                      :null => false
    t.integer  "status",        :default => 1, :null => false
    t.datetime "created_on",                   :null => false
    t.datetime "updated_on",                   :null => false
    t.integer  "created_by_id",                :null => false
    t.datetime "visited_on",                   :null => false
  end

  add_index "boardusers", ["board_id"], :name => "index_boardusers_on_board_id", :unique => true
  add_index "boardusers", ["user_id"], :name => "index_boardusers_on_user_id", :unique => true
  add_index "boardusers", ["status"], :name => "index_boardusers_on_status", :unique => true

  create_table "emails", :force => true do |t|
  end

  create_table "invites", :force => true do |t|
    t.integer  "board_id",                      :default => 0, :null => false
    t.integer  "inviter_user_id",               :default => 0, :null => false
    t.integer  "accepted_user_id"
    t.string   "nick_name"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "reference_token"
    t.text     "invitation_text"
    t.integer  "status",           :limit => 4, :default => 0, :null => false
    t.datetime "updated_on"
    t.datetime "created_on"
  end

  add_index "invites", ["board_id", "inviter_user_id", "accepted_user_id", "status"], :name => "invites_board_id_index", :unique => true

  create_table "keywords", :force => true do |t|
    t.string   "tag",           :default => "", :null => false
    t.datetime "created_on",                    :null => false
    t.datetime "updated_on",                    :null => false
    t.integer  "created_by_id", :default => 1,  :null => false
    t.integer  "updated_by_id", :default => 1,  :null => false
  end

  add_index "keywords", ["tag"], :name => "keywords_tag_index", :unique => true

  create_table "library_documents", :force => true do |t|
    t.binary   "file"
    t.integer  "user_id",      :default => 0,  :null => false
    t.string   "content_type", :default => "", :null => false
    t.string   "file_name",    :default => "", :null => false
    t.datetime "created_on",                   :null => false
    t.datetime "updated_on",                   :null => false
  end

  create_table "library_documents_widget_instances", :id => false, :force => true do |t|
    t.integer "library_document_id", :default => 0, :null => false
    t.integer "widget_instance_id",  :default => 0, :null => false
  end

  add_index "library_documents_widget_instances", ["library_document_id", "widget_instance_id"], :name => "library_documents_widget_instances_library_document_id_index", :unique => true

  create_table "library_photos", :force => true do |t|
    t.binary   "file"
    t.integer  "user_id",                    :default => 0,  :null => false
    t.string   "content_type",               :default => "", :null => false
    t.string   "file_name",                  :default => "", :null => false
    t.datetime "created_on",                                 :null => false
    t.datetime "updated_on",                                 :null => false
    t.integer  "variant_of_id"
    t.integer  "width",                      :default => 0
    t.integer  "height",                     :default => 0
    t.integer  "filter",        :limit => 4, :default => 0
    t.integer  "rotation",      :limit => 4, :default => 0
  end

  create_table "library_photos_widget_instances", :id => false, :force => true do |t|
    t.integer "library_photo_id",   :default => 0, :null => false
    t.integer "widget_instance_id", :default => 0, :null => false
  end

  add_index "library_photos_widget_instances", ["library_photo_id", "widget_instance_id"], :name => "library_photos_widget_instances_library_photo_id_index", :unique => true

  create_table "members", :force => true do |t|
    t.integer "user_id"
    t.integer "membershipable_id"
    t.string  "membershipable_type"
  end

  create_table "roles", :force => true do |t|
    t.string   "name",          :limit => 30, :default => "", :null => false
    t.integer  "status",        :limit => 4,  :default => 0,  :null => false
    t.integer  "is_visible",    :limit => 4,  :default => 1,  :null => false
    t.integer  "is_locked",     :limit => 4,  :default => 1,  :null => false
    t.integer  "created_by_id",               :default => 1,  :null => false
    t.datetime "created_on",                                  :null => false
    t.datetime "updated_on",                                  :null => false
    t.integer  "updated_by_id",               :default => 1,  :null => false
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "user_id", :default => 0, :null => false
    t.integer "role_id", :default => 0, :null => false
  end

  add_index "roles_users", ["user_id", "role_id"], :name => "roles_users_user_id_index", :unique => true

  create_table "taggings", :force => true do |t|
    t.integer "taggable_id"
    t.integer "tag_id"
    t.string  "taggable_type"
  end

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "user_images", :force => true do |t|
    t.integer "user_id",      :default => 0,  :null => false
    t.string  "content_type", :default => "", :null => false
    t.string  "filename"
    t.string  "kind"
    t.binary  "image"
  end

  create_table "user_notifications", :force => true do |t|
    t.integer  "user_id",                           :null => false
    t.integer  "widget_instance_id",                :null => false
    t.datetime "time",                              :null => false
    t.integer  "created_by_id",      :default => 1, :null => false
    t.integer  "updated_by_id",      :default => 1, :null => false
    t.datetime "created_on",                        :null => false
    t.datetime "updated_on",                        :null => false
    t.integer  "status",             :default => 0, :null => false
  end

  create_table "user_tags", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "user_id"
    t.datetime "created_on"
  end

  create_table "users_contacts", :id => false, :force => true do |t|
    t.integer "user_id",    :default => 0, :null => false
    t.integer "contact_id", :default => 0, :null => false
  end

  add_index "users_contacts", ["user_id", "contact_id"], :name => "contact_id", :unique => true

  create_table "widget_instance_styles", :force => true do |t|
    t.string  "value"
    t.string  "name",               :limit => 50
    t.string  "attribute",          :limit => 50
    t.integer "widget_instance_id",               :default => 0, :null => false
  end

  create_table "widget_instance_texts", :force => true do |t|
    t.text    "value"
    t.string  "name",               :limit => 50
    t.integer "widget_instance_id",               :default => 0, :null => false
  end

  create_table "widget_instances", :force => true do |t|
    t.integer  "board_id",                    :default => 0,   :null => false
    t.integer  "widget_id",                   :default => 0,   :null => false
    t.integer  "top",                         :default => 100
    t.integer  "left",                        :default => 100
    t.integer  "width"
    t.integer  "height"
    t.float    "zindex",                      :default => 0.0, :null => false
    t.integer  "auto_front",                  :default => 0,   :null => false
    t.integer  "opacity",                     :default => 1,   :null => false
    t.integer  "opacity_value",               :default => 100, :null => false
    t.integer  "proportional",                :default => 0,   :null => false
    t.integer  "shadow",                      :default => 1,   :null => false
    t.integer  "created_by_id",               :default => 0,   :null => false
    t.integer  "updated_by_id",               :default => 0,   :null => false
    t.datetime "created_on",                                   :null => false
    t.datetime "updated_on",                                   :null => false
    t.integer  "locked",                      :default => 0,   :null => false
    t.integer  "status",                      :default => 1,   :null => false
    t.string   "widget_name",   :limit => 32, :default => ""
  end

  create_table "widget_members", :force => true do |t|
    t.integer "widget_instance_id"
    t.integer "widget_membership_id"
    t.string  "widget_membership_type"
  end

  create_table "widgets", :force => true do |t|
    t.string "name", :limit => 30, :default => "untitled", :null => false
  end

end
