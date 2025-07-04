module ActiveRecord
  module Acts #:nodoc:
    module Taggable #:nodoc:
      def self.included(base)
        base.extend(ClassMethods)  
      end
      
      module ClassMethods
        def acts_as_taggable(options = {})
          write_inheritable_attribute(:acts_as_taggable_options, {
            :taggable_type => ActiveRecord::Base.send(:class_name_of_active_record_descendant, self).to_s,
            :from => options[:from]
          })
          
          class_inheritable_reader :acts_as_taggable_options

          has_many :taggings, :as => :taggable, :dependent => :destroy
          has_many :tags, :through => :taggings

          include ActiveRecord::Acts::Taggable::InstanceMethods
          extend ActiveRecord::Acts::Taggable::SingletonMethods          
        end
      end
      
      module SingletonMethods
        def find_tagged_with(list)
          find_by_sql([
            "SELECT #{table_name}.* FROM #{table_name}, tags, taggings " +
            "WHERE #{table_name}.#{primary_key} = taggings.taggable_id " +
            "AND taggings.taggable_type = ? " +
            "AND taggings.tag_id = tags.id AND tags.name IN (?)",
            acts_as_taggable_options[:taggable_type], list
          ])
        end
        
        #def find_tagged_by_user(list, user_id)
        #end
        
        def find_tagged_with!(list)
          find_by_sql([
            "SELECT #{table_name}.* FROM #{table_name} " +
            "WHERE #{table_name}.#{primary_key} in (" +
            "  SELECT taggable_id FROM taggings, tags " +
            "    WHERE tags.id=taggings.tag_id " +
            "     AND taggings.taggable_type = ? " +
            "     AND tags.name IN (?) " + 
            "    GROUP BY taggable_id " + 
            "    HAVING count(tags.id) >= ? " + 
            "  )",
            acts_as_taggable_options[:taggable_type], list, list.to_a.length
          ])
        end
      end
      
      module InstanceMethods
        def tag_with(list, user_id)
          Tag.transaction do
            taggings.destroy_all
            Tag.parse(list).each do |name|
              if acts_as_taggable_options[:from]
                t = send(acts_as_taggable_options[:from]).tags.find_or_create_by_name(name)
                t.on(self)
              else
                t = Tag.find_or_create_by_name(name)
                t.on(self)
              end
              UserTag.find_or_create_by_user_id_and_tag_id(user_id, t.id) if user_id
            end
          end
        end

        def tag_list
          tags.collect { |tag| tag.name.include?(" ") ? "'#{tag.name}'" : tag.name }.join(", ")
        end
      end
    end
  end
end