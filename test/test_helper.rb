ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require "test_exemplars"
include ExemplarBuilder

class Test::Unit::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  self.use_transactional_fixtures = false

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false
  # Add more helper methods to be used by all tests here...
  
  # used for functional tests
  def signin_as person
    u = users(person)
    @request.session[:user_id] = u.id
    return u
  end
  
    module TestingDSL
      attr_reader :person

      def logs_in_as(person)
        signin(users(person).login)
      end
      
      def signin(login, password="password")
        post "public/signin", :user => {:login => login, :pwd => password}, :popup => true
        assert_not_nil(session[:user_id])
      end
      
      def signout
        get "public/signout"
        #is_redirected_to "/"
      end
      
      def is_redirected_to action
        assert_response :redirect
        follow_redirect!
        assert_response :success
        assert_template action.to_s
      end
          
      def goes_to_login
        get "/signin?popup=true"
        assert_response :success
        assert_template "public/signin"
      end

      def goes_to_signup
        get "/signup?popup=true"
        assert_response :success
        assert_template "public/signup"
      end

      def signs_up_with(options)
        post "/signup?popup=true", options
        assert_response :redirect
        follow_redirect!
        assert_response :success
        assert_template "start"
      end
      
      def end_session
        reset!
      end
            
      def update_widget(body, time_offset=1164653468944)
        post "/widgets/default/update", widget_data_body(body, time_offset), {"Content-Type" => "text/xml", "X-Requested-With" => "XMLHttpRequest"}
      end
      
      def widget_data_body(data={:board_1 => {:temp_1 => {:widget_id => 1, :top => 100, :left => 100, :text => {:value => "<br>"}}}}, time_offset=1164653468944)
        return "<body>
            <time>#{time_offset}</time>
            <boards>#{data.to_xml.gsub(/<\/?hash>/,"")}</boards>
          </body>"
      end
      
      def assert_xml_tag(xml, conditions)
        doc = HTML::Document.new(xml)
        assert doc.find(conditions), 
          "expected tag, but no tag found matching #{conditions.inspect} in:\n#{xml.inspect}"
      end
      
      def assert_no_xml_tag(xml, conditions)
        doc = HTML::Document.new(xml)
        assert !doc.find(conditions), 
          "expected no tag, but found tag matching #{conditions.inspect} in:\n#{xml.inspect}"
      end
      
    end

    def new_session
      open_session do |sess|
        sess.extend(TestingDSL)
        yield sess if block_given?
      end
    end
    
 #   def signin_as(login, password)
 #     new_session do |sess|
 #       sess.goes_to_login
 #       sess.logs_in_as(login, password)
 #       yield sess if block_given?
 #     end
 #   end
    
    def new_session_as(person=nil)
      new_session do |sess|
        sess.goes_to_login
        sess.logs_in_as(person) if person and not person==:guest
        yield sess if block_given?
      end
    end
    
    def fake_upload file, upload_id, session_id
      file.upload_id = upload_id
      file.session_id = session_id
      file.save
    end

end

# Bug fix for Integration test and file upload. See bug http://dev.rubyonrails.org/ticket/4635
#class StringIO
#  def read
#    self.to_s
#  end
#end

#class SessionModel
#  def user_id= *arguments
#  end
#  def self.delete_all *arguments
#  end
#end
  
#class ActionController::TestSession
#  @@temp_session_id = nil
#  def session_id
#    return @@temp_session_id
#  end
#  def session_id= id
#    @@temp_session_id = id
#  end
#end

#class CGI::Session
#  @@temp_session_id = nil
#  def session_id
#    return @@temp_session_id
#  end
#  def session_id= id
#    @@temp_session_id = id
#  end
#end

