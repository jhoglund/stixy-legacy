#ENV['RAILS_ENV'] ||= 'development'
#
#Rails::Initializer.run do |config|
#    config.plugins = ['attachment_fu']
#end
#Rails::Initializer.run(:set_load_path)
#
#
#
#
#namespace :s3 do
#    
#    desc 'clean up abandoned records prior to doing anything'
#    task :clean_up_orphans do
#        # def self.orphans
#        db_connection = ActiveRecord::Base.connection
#        # finally .... this is how you can delete in mysql while doing table join. note 'using' keyword and not using 'as' aliasing
#        db_connection.execute("delete from library_documents using library_documents LEFT OUTER JOIN library_documents_widget_instances rel on library_documents.id = rel.library_document_id where rel.id is NULL and updated_on < subdate(now(), INTERVAL 1 day)")
#        
#        # the record in library_photos_widget_instances is of the variant one with variant_of_id set
#        # but then the variant one gets deleted ....
#        db_connection.execute("CREATE TEMPORARY TABLE tmptable (`variant_of_id` int(11) default NULL);insert into tmptable select library_photos.variant_of_id from library_photos LEFT OUTER JOIN library_photos_widget_instances rel on library_photos.id = rel.library_photo_id where rel.id is NULL and variant_of_id is not null and updated_on < subdate(now(), INTERVAL 1 day);delete from library_photos using library_photos join tmptable on library_photos.id = tmptable.variant_of_id;drop table tmptable;")
#        
#        # dont do this while the app is running. performance killer!
#        #db_connection.execute("delete from library_photos using library_photos LEFT JOIN sessions ON library_photos.session_id != sessions.session_id WHERE sessions.session_id is NULL and library_photos.session_id is not NULL;")
#        #db_connection.execute("delete from library_documents using library_documents LEFT JOIN sessions ON library_documents.session_id != sessions.session_id WHERE sessions.session_id is NULL and library_documents.session_id is not NULL;")
#
#        # todo - deletes are expensive as they do a fool table lock and nobody can even read from table
#        # so for new abstract_files tables, we are not gonna clean up orphans untill db space or amazon storage cost are gonna become an issue.
#        # at this poing, do the same as above, including condion (and index) on type column, but also write matching ids and filenames and types into anyther table prior to delete, so that they can be deleted from amazon
#
#    end
#    
#    
#    desc 'Migrates maximum of X documents to amazon and marke them as such. run it till all are there.'
#    task :migrate_documents do
#        10.times do |item|
#         msg " - Running batch: #{item}\n\n" 
#         exit if move_it(LibraryDocument, DocumentFile, {:migrated_date => nil})
#        end
#    end
#    
#    
#    desc 'Migrates maximum of X images to amazon and marks them as such. run it till all are there.'
#    task :migrate_images do
#        25.times do |item|
#         msg " - Running batch: #{item+1}\n\n" 
#         post_processor = method(:post_process_image)
#         exit if move_it(LibraryPhoto, ImageFile, {:migrated_date => nil, :variant_of_id => nil}, 6000, post_processor)
#        end
#    end
#    
#    
#    desc 'Migrates maximum of X user pics to amazon and marks them as such. run it till all are there.'
#    task :migrate_pics do
#        UserImage.send(:include, UserImageEnhancer)
#        move_it(UserImage, AvatarFile, {:migrated_date => nil}, 5000)
#    end
#    
#    
#    desc 'updating ids to correspond to new images records'
#    task :update_pics_ids do
#        db_connection = ActiveRecord::Base.connection
#        db_connection.execute("UPDATE library_photos_widget_instances SET library_photo_id = library_photo_id + 6000 where library_photo_id < 6000")
#    end
#    
#    desc 'dd'
#    task :test do
#            old_file = LibraryPhoto.find(1)
#            new_file = ImageFile.find(6001)
#            post_process_image(old_file, new_file)
#            puts new_file.thumb(:t).public_filename
#        end
#    desc 'xx'
#    task :test_2 do
#            old_file = LibraryDocument.find(1)
#            puts old_file.respond_to?(:variant_of_id)
#        end
#    
#end
#
#
#
#
#private
#
#def post_process_image(old_file, new_file)
#  msg "   ... postprosesing thumb" 
#  new_file.thumb(:t).regenerate({:width => old_file.width, :height => old_file.height, :filter => old_file.filter, :rotation => old_file.rotation})
#  msg "   ... done postprosesing" 
#end
#
#def msg(text)
#  puts "#{Time.now} -- msg: #{text}"
#end
#
#
#def move_it(old_clazz, new_clazz, conditions, id_offset = 0, callback_method = nil)
#    msg "Looking for docs" 
#    limit = 100
#    old_files = old_clazz.find(:all, :conditions => conditions, :limit => limit)
#    msg "Found #{old_files.size} docs" 
#    counter = 0
#    old_files.each do | old_file |
#        msg "Attemting to move id:#{old_file.id} (#{old_file.file_name}) to S3" 
#        new_file = new_clazz.new(
#             :user_id => old_file.user_id,
#             :content_type => old_file.content_type,
#             :filename => old_file.file_name)
#        new_file.temp_data = old_file.file
#        if old_file.respond_to?(:variant_of_id)
#            variant = old_clazz.find(:first, :conditions => {:variant_of_id => old_file.id})
#            unless variant.nil?
#                new_file.id = id_offset + variant.id.to_i
#            end
#        end
#        if new_file.id.nil?
#            new_file.id = id_offset + old_file.id.to_i
#        end
#        new_file.save!
#        msg "   ... uploaded to: #{new_file.public_filename}" 
#        unless callback_method.nil?
#            unless variant.nil?
#                callback_method.call(variant, new_file) 
#            else
#                callback_method.call(old_file, new_file)
#            end
#        end
#        db_connection = ActiveRecord::Base.connection
#        db_connection.execute("UPDATE #{old_clazz.table_name} SET migrated_date = now() where id = #{old_file.id}")
#        msg "Marked as migrated" 
#        puts "\n"
#        counter = counter.next
#    end
#    msg "Migrated #{counter} docs"
#    return counter != limit
#end
#
#
#module UserImageEnhancer
#    def self.included(base)
#        base.class_eval do
#            def file_name
#               filename
#            end
#            def file
#                image
#            end
#            # would've been much cleaner with aliasing, but I cant get past active record with it
#            #alias :file_name :filename
#            #alias :file :image
#        end
#   end
#end
#
#
#
#
#
#