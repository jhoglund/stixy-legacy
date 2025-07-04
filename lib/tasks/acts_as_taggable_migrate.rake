#ENV['RAILS_ENV'] ||= 'development'
#Rails::Initializer.run do |config|
#    config.plugins = ['acts_as_taggable']
#end
#
#namespace :aat do
#  desc 'migrate tags'
#  task :migrate do
#    Board.find(:all).each do |b|
#      user_id = b.keywords.first.created_by_id rescue 1
#      b.tag_with(b.keywords.collect{|k| k.tag}.join(", "), user_id) 
#    end
#  end
#end