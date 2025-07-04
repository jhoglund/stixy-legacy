require File.dirname(__FILE__) + '/../../test_helper'
require 'widgets/default_controller'

# Re-raise errors caught by the controller.
class Widgets::DefaultController; def rescue_action(e) raise e end; end

class Widgets::DefaultControllerTest < Test::Unit::TestCase
  fixtures :users, :boards, :boardusers, :roles, :roles_users, :widgets, :widget_instances, :user_notifications
  def setup
    @controller = Widgets::DefaultController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_note
    @request.env['HTTP_X_REQUESTED_WITH'] = 'XMLHttpRequest'
    zindex_less = WidgetInstance.reset_zindex(1000,"1169467557832")
    post(:update, {:body => {"time"=>"1169467557832", :boards => {"board_#{boards(:first).id}" => {"temp_12345" => {
      :widget_id => "1", 
      :text => {:value => "Test av text"}, 
      :style => {"background_color", "red"},
      :left => 111,
      :top => 222,
      :width => 333,
      :height => 444,
      :shadow => 1,
      :zindex => 1000
    }}}}}, :user_id => users(:jonas).id)
    zindex_more = WidgetInstance.reset_zindex(1000,"1169467557832")
    
    assert_equal 1, assigns(:boards).size
    note = boards(:first).widgets.last
    assert_equal note.class, WidgetNote
    assert_equal note.text, "<sx:moz-editor-block-spacer><div></div></sx:moz-editor-block-spacer><sx:moz-editor-cursor-spacer></sx:moz-editor-cursor-spacer>
    Test av text" 
    assert_equal note.styles.detect{|style| style.attr == "background_color"}.value, "red"
    assert_equal note.left, 111
    assert_equal note.top, 222
    assert_equal note.width, 333
    assert_equal note.height, 444
    assert_equal note.shadow, 1
    assert_equal note.status, Status::ACTIVE
    # This breaks if test is run as rake task, since db:dump will cast the type of the zindex column from double to float.
    #assert_equal true, (note.zindex > zindex_less)
    #assert_equal true, (note.zindex < zindex_more)
   
    post(:update, {:body => {"time"=>"1169467557832", :boards => {"board_#{boards(:first).id}" => { "widget_#{note.id}" => {
      :widget_id => "1", 
      :text => {:value => "Test av updated text"}, 
      :style => {"background_color", "green"},
      :left => 110,
      :top => 220,
      :width => 330,
      :height => 440,
      :shadow => 0,
      :zindex => 2000
    }}}}}, "X-Requested-With" => "XMLHttpRequest", :user_id => users(:jonas).id)
    
    assert_equal 1, assigns(:boards).size
    note = WidgetNote.find(note.id)
    assert_equal note.class, WidgetNote
    assert_equal note.text, "<sx:moz-editor-block-spacer><div></div></sx:moz-editor-block-spacer><sx:moz-editor-cursor-spacer></sx:moz-editor-cursor-spacer>
    Test av updated text" 
    assert_equal note.styles.detect{|style| style.attr == "background_color"}.value, "green"
    assert_equal note.left, 110
    assert_equal note.top, 220
    assert_equal note.width, 330
    assert_equal note.height, 440
    assert_equal note.shadow, 0
    assert_equal note.status, Status::ACTIVE
    
    assert_equal 4, Board.find(boards(:first).id).widgets.size
    assert_not_nil boards(:first).widget_instances.find_by_id(note.id, :conditions => ['status = ?', Status::ACTIVE])
    assert_nil boards(:first).widget_instances.find_by_id(note.id, :conditions => ['status = ?', Status::DISABLED])
    post(:update, {:body => {"time"=>"1169467557832", :boards => {"board_#{boards(:first).id}" => { "widget_#{note.id}" => { "widget_id" => 1, "remove" => "true" }}}}}, "X-Requested-With" => "XMLHttpRequest", :user_id => users(:jonas).id)
    assert_not_nil boards(:first).widget_instances.find_by_id(note.id, :conditions => ['status = ?', Status::DISABLED])
    assert_nil boards(:first).widget_instances.find_by_id(note.id, :conditions => ['status = ?', Status::ACTIVE])
    assert_equal 3, Board.find(boards(:first).id).widgets.size
  end
  
  def test_todo
    @request.env['HTTP_X_REQUESTED_WITH'] = 'XMLHttpRequest'
    post(:update, {:body => {"time"=>"1169467557832", :boards => {"board_#{boards(:first).id}" => {"temp_12345" => {
      :widget_id => "4", 
      :comment => {:value => "Test av comment"}, 
      :left => 111,
      :top => 222,
      :width => 333,
      :height => 444,
      :shadow => 1,
      :zindex => 1000,
      :time => "January 10 2007 11:45 AM",
      :reminder => { 
				:remind_at => "6.00",
				:remind_users => {0 => 0, users(:jonas).id => 0, users(:adam).id => 1, users(:maria).id => 0 }
			}
    }}}}}, "X-Requested-With" => "XMLHttpRequest", :user_id => users(:jonas).id)
    assert_equal 1, assigns(:boards).size
    todo = Board.find(boards(:first).id).widgets.last
    assert_equal todo.class, WidgetTodo
    assert_equal todo.comment, "<sx:moz-editor-block-spacer><div></div></sx:moz-editor-block-spacer><sx:moz-editor-cursor-spacer></sx:moz-editor-cursor-spacer>
    Test av comment" 
    assert_equal todo.time, users(:jonas).reset_time(Time.parse("January 10 2007 11:45 AM UTC"))
    assert_equal todo.left, 111
    assert_equal todo.top, 222
    assert_equal todo.width, 333
    assert_equal todo.height, 444
    assert_equal todo.shadow, 1
    assert_equal todo.status, Status::ACTIVE
    
    reminders = UserNotification.find_all_by_widget_instance_id(todo.id)
    assert_equal 1, reminders.size
    assert_equal users(:adam).id, reminders.first.user_id
    assert_equal users(:jonas).reset_time(Time.parse("January 10 2007 5:45 AM UTC")), reminders.first.time
    
    post(:update, {:body => {"time"=>"1169467557832", :boards => {"board_#{boards(:first).id}" => {"widget_#{todo.id}" => {
      :widget_id => "4", 
      :comment => {:value => "Test av comment again"}, 
      :time => "January 10 2007 8:45 AM",
      :reminder => { 
				:remind_at => "1.00",
				:remind_users => {0 => 0, users(:jonas).id => 1, users(:adam).id => 1, users(:maria).id => 0 }
			}
    }}}}}, "X-Requested-With" => "XMLHttpRequest", :user_id => users(:jonas).id)
    
    todo = Board.find(boards(:first).id).widgets.last
    assert_equal todo.comment, "<sx:moz-editor-block-spacer><div></div></sx:moz-editor-block-spacer><sx:moz-editor-cursor-spacer></sx:moz-editor-cursor-spacer>
    Test av comment again" 
    assert_equal todo.time, users(:jonas).reset_time(Time.parse("January 10 2007 8:45 AM UTC"))
    
    reminders = UserNotification.find_all_by_widget_instance_id(todo.id)
    assert_equal 2, reminders.size
    assert_equal users(:jonas).reset_time(Time.parse("January 10 2007 7:45 AM UTC")), reminders.first.time
    
    post(:update, {:body => {"time"=>"1169467557832", :boards => {"board_#{boards(:first).id}" => {"widget_#{todo.id}" => {
      :widget_id => "4", 
      :comment => {:value => "Test av comment again"}, 
      :time => "January 10 2007 8:45 AM",
      :reminder => { 
				:remind_at => "1.00",
				:remind_users => {0 => 0, users(:jonas).id => 0, users(:adam).id => 0, users(:maria).id => 0 }
			}
    }}}}}, "X-Requested-With" => "XMLHttpRequest", :user_id => users(:jonas).id)
    
    todo = Board.find(boards(:first).id).widgets.last
    
    reminders = UserNotification.find_all_by_widget_instance_id(todo.id)
    assert_equal 0, reminders.size
        
    post(:update, {:body => {"time"=>"1169467557832", :boards => {"board_#{boards(:first).id}" => {"widget_#{todo.id}" => {
      :widget_id => "4", 
      :comment => {:value => "Test av comment again"}, 
      :time => "January 10 2007 8:45 AM",
      :reminder => { 
				:remind_at => "0.25",
				:remind_users => {0 => 0, users(:jonas).id => 1, users(:adam).id => 1, users(:maria).id => 0 }
			}
    }}}}}, "X-Requested-With" => "XMLHttpRequest", :user_id => users(:adam).id)
    
    todo = WidgetTodo.find_by_board_id_and_id(boards(:first).id,todo.id)
    assert_equal todo.time, users(:adam).reset_time(Time.parse("January 10 2007 8:45 AM UTC"))
    
    reminders = UserNotification.find_all_by_widget_instance_id(todo.id)
    assert_equal 2, reminders.size
    #assert_equal users(:adam).reset_time(Time.parse("January 10 2007 7:45 AM")), reminders.first.time
    
  end
end
