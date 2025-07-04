class DataWidgets < ActiveRecord::Migration
  def self.up
    Widget.create(:name => "Note")
    Widget.create(:name => "Photo")
    Widget.create(:name => "Document")
    Widget.create(:name => "Activity")
    #
    #[ {:instance_data => { :top => 100, :left => 100, :width => 200, :height => 250}, :text => { :value => "This is a test text" }, :style => { :attribute => "background_color", :value => "rgb(255,153,0)" }, :type => "Note", :title => "Board with content"},
    #  {:instance_data => { :top => 200, :left => 400, :width => 180, :height => 150}, :text => { :value => "And this is yet an other test text" }, :type => "Note", :title => "Board with content"}
    #].each do |data|
    #  b = Board.find_by_title(data[:title])
    #  w = Widget.find_by_name(data[:type]).widget_instances.create(data[:instance_data].merge({:created_by => b.users.find(:all).last,:updated_by => b.users.find(:first)}))
    #  w.content = data[:text] if data[:text]
    #  w.styles.create(data[:style]) if data[:style]
    #  b.widget_instances << w
    #end
	end
end