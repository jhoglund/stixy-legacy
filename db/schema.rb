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

ActiveRecord::Schema.define(:version => 2) do

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
  end

  add_index "boards", ["status", "created_by_id", "updated_by_id"], :name => "boards_status_index", :unique => true
  add_index "boards", ["title"], :name => "boards_title_index", :unique => true

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

  create_table "invites", :force => true do |t|
    t.integer "board_id",                      :default => 0, :null => false
    t.integer "inviter_user_id",               :default => 0, :null => false
    t.integer "accepted_user_id"
    t.string  "nick_name"
    t.string  "first_name"
    t.string  "last_name"
    t.string  "email"
    t.string  "reference_token"
    t.text    "invitation_text"
    t.integer "status",           :limit => 4, :default => 0, :null => false
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

  create_table "user_images", :force => true do |t|
    t.integer "user_id",      :default => 0,  :null => false
    t.string  "content_type", :default => "", :null => false
    t.string  "filename"
    t.string  "kind"
    t.binary  "image"
  end

  create_table "users", :force => true do |t|
    t.string   "login",                                                   :null => false
    t.string   "email",                                                   :null => false
    t.string   "pwd",                        :limit => 60
    t.string   "crypted_password",           :limit => 40
    t.string   "salt",                       :limit => 40
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "nick_name"
    t.string   "first_name"
    t.string   "last_name"
    t.text     "description"
    t.datetime "last_login_date"
    t.datetime "created_on",                                              :null => false
    t.datetime "updated_on",                                              :null => false
    t.integer  "created_by_id",                            :default => 0, :null => false
    t.integer  "updated_by_id",                            :default => 0, :null => false
    t.integer  "status",                     :limit => 4,  :default => 1, :null => false
    t.string   "address"
    t.string   "city"
    t.string   "state",                      :limit => 60
    t.string   "zip",                        :limit => 20
    t.string   "country",                    :limit => 60
    t.string   "phone",                      :limit => 60
    t.string   "mobile_phone",               :limit => 60
    t.integer  "pref_enable_grag_drop",      :limit => 4,  :default => 0
    t.integer  "pref_send_email_and_mobile", :limit => 4,  :default => 0
    t.integer  "pref_photo_auto_upload",     :limit => 4,  :default => 0
  end

  add_index "users", ["status"], :name => "users_status_index", :unique => true
  add_index "users", ["login"], :name => "users_login_index", :unique => true

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
    t.integer  "board_id",      :default => 0,   :null => false
    t.integer  "widget_id",     :default => 0,   :null => false
    t.integer  "top",           :default => 100
    t.integer  "left",          :default => 100
    t.integer  "width"
    t.integer  "height"
    t.float    "zindex",        :default => 0.0, :null => false
    t.integer  "auto_front",    :default => 0,   :null => false
    t.integer  "opacity",       :default => 1,   :null => false
    t.integer  "opacity_value", :default => 100, :null => false
    t.integer  "proportional",  :default => 0,   :null => false
    t.integer  "shadow",        :default => 1,   :null => false
    t.integer  "created_by_id", :default => 0,   :null => false
    t.integer  "updated_by_id", :default => 0,   :null => false
    t.datetime "created_on",                     :null => false
    t.datetime "updated_on",                     :null => false
  end

  create_table "widgets", :force => true do |t|
    t.string "name", :limit => 30, :default => "untitled", :null => false
  end

end
