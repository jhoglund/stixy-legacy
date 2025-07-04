require 'digest/sha1'
require 'fileutils'

class AbstractFile < ActiveRecord::Base

    belongs_to :user
    
    cattr_accessor :user_authorized, :user_base
    attr_accessor :authorization_certificate
    
    # Used for copying old names to new. Not to be used in production. Remove when done!!
    def old_name
      base_name(parent_id||id)
    end
    def new_name
      base_name encode(parent_id||id)
    end
    def base_name name
      "public/system/images/#{name}/#{filename}"
    end
    def copy_to_new
      begin
        new_path = File.join(RAILS_ROOT, new_name)
        old_path = File.join(RAILS_ROOT, old_name)
        
        if File.exists?(new_path)
          self.update_attribute(:storage_state, 12)
          yield 0, "Error #{id} new exist. #{new_path}, #{old_path}" if block_given?
        else 
          if File.exists?(old_path)
            FileUtils.mkdir_p(File.dirname(new_path))
            if FileUtils.cp(old_path, new_path)
              self.update_attribute(:storage_state, 9)
              yield 1, "#{old_path} -> #{new_path}" if block_given?
            else
              self.update_attribute(:storage_state, 10)
              yield 0, "Error #{id}, Couldn't copy #{old_path} -> #{new_path}" if block_given?
            end
          else
            self.update_attribute(:storage_state, 13)
            yield 0, "Error #{id} don't exist. #{old_path}" if block_given?
          end
        end
      rescue => m
        self.update_attribute(:storage_state, 11)
        yield 0, "Error #{id}: #{m}" if block_given?
      end
    end
    
    def self.find_temp id=0, upload_id=0, session_id=0
      # this strange thing is actually a security precaution to retrive files 
      # during widget creation before the widget was saved yet
      self.find_by_id_and_upload_id_and_session_id(id, upload_id, session_id)
    end
    
    def self.encode str
      Digest::SHA1.hexdigest("SCHNAUZER--#{str}--")
    end
    
    def encode str
      self.class.encode(str)
    end
    
    def certificate
      # A custom authorization method that ensures that only Rest actions originating with the right credentials are allowed on the upload server
      authorization_certificate = { :authorization_certificate => { :hashed => self.encode(self.id), :key => self.id } }
    end
        
    def copy
      # Clone a file in the db and all associated thumbnails
      # Once the file is cloned and saved, call the copy_attachment method on the inheriting class (ImageFile and DocumentFile)
      cloned = self.clone
      cloned.save!
      self.thumbnails.each do |thumb|
        cloned_thumb = thumb.clone
        cloned_thumb.parent_id = cloned.id
        cloned_thumb.save!
      end
      self.copy_attachments_to(cloned)
      return cloned
    end
    
end
