class CreateContentTables < ActiveRecord::Migration
  def self.up

=begin      
      Fields for attachment_fu metadata tables...
        in general:
          size,         :integer  # file size in bytes
          content_type, :string   # mime type, ex: application/mp3
          filename,     :string   # sanitized filename
        that reference images:
          height,       :integer  # in pixels
          width,        :integer  # in pixels
        that reference images that will be thumbnailed:
          parent_id,    :integer  # id of parent image (on the same table, a self-referencing foreign-key).
                                  # Only populated if the current object is a thumbnail.
          thumbnail,    :string   # the 'type' of thumbnail this attachment record describes.  
                                  # Only populated if the current object is a thumbnail.
                                  # Usage:
                                  # [ In Model 'Avatar' ]
                                  #   has_attachment :content_type => :image, 
                                  #                  :storage => :file_system, 
                                  #                  :max_size => 500.kilobytes,
                                  #                  :resize_to => '320x200>',
                                  #                  :thumbnails => { :small => '10x10>',
                                  #                                   :thumb => '100x100>' }
                                  # [ Elsewhere ]
                                  # @user.avatar.thumbnails.first.thumbnail #=> 'small'
=end

    create_table :abstract_files, :options => "TYPE=MyISAM" do |t|
          # inheritance type
          t.column :user_id,        :integer, :default => 0, :null => false
          t.column :type,           :string,  :limit => 20, :default => '', :null => false
          t.column :size,           :integer, :default => 0, :null => false
          t.column :width,          :integer, :limit => 6, :default => 0, :null => false
          t.column :height,         :integer, :limit => 6, :default => 0, :null => false
          t.column :filter,         :integer, :limit => 4, :default => 0, :null => false
          t.column :rotation,       :integer, :limit => 4, :default => 0, :null => false
          t.column :content_type,   :string,  :limit => 255, :default => '', :null => false
          t.column :filename,       :string,  :limit => 255, :default => '', :null => false
          t.column :thumbnail,      :string,  :limit => 20
          t.column :parent_id,      :integer
          t.column :session_id,     :string, :limit => 32
          t.column :upload_id,      :string, :limit => 255
          t.column :created_at,     :datetime, :null => false
          t.column :updated_at,     :datetime, :null => false
    end
    
    add_index :abstract_files, :user_id
    add_index :abstract_files, :session_id
    add_index :abstract_files, [:upload_id, :session_id]
    
    execute "ALTER TABLE abstract_files AUTO_INCREMENT = 20000;" # avoid the conflics
  end
  
  def self.down
    drop_table :abstract_files
  end
end
