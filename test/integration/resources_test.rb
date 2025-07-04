require "#{File.dirname(__FILE__)}/../test_helper"
require "#{RAILS_ROOT}/app/controllers/resources_controller"

class ResourcesTest < ActionController::IntegrationTest
  fixtures :users, :roles, :roles_users
  ResourcesController.const_set(:RESOURCE_CACHING, true) unless ResourcesController.const_defined?(:RESOURCE_CACHING)
  
  
  def setup
    @user = new_session_as(:jonas)
  end
  
  def teardown
    self.class.cleanup
  end
  
  def test_resource_created
    @user.assert !File.exists?("#{RAILS_ROOT}/public/resources")
    @user.get "/resources/default/firefox.js"
    @user.assert File.exists?("#{RAILS_ROOT}/public/resources/default/firefox.js")
    @user.assert !File.exists?("#{RAILS_ROOT}/public/resources/default/safari.css")
    @user.get "/resources/default/safari.css"
    @user.assert File.exists?("#{RAILS_ROOT}/public/resources/default/safari.css")
  end
  
  def test_resource_link
    @user.get "/signin?popup=true"
    @user.assert_select "script[src^=?]", "/resources/default/other.js"
    @user.assert_select "link[href^=?]", "/resources/default/other.css"
    @user.assert_select "link[href^=?]", "/resources/public/other.css"
  end
  
  def test_resource_link_and_create
    @user.get "/resources/default/other.js"
    timestamp = File.mtime("#{RAILS_ROOT}/public/resources/default/other.js").to_i.to_s
    @user.get "/signin?popup=true"
    @user.assert_select "script[src=?]", "/resources/default/other.js?#{timestamp}"
  end
  
  def test_resource_new_timestamp
    @user.get "/resources/default/other.js"
    @user.assert File.exists?("#{RAILS_ROOT}/public/resources/default/other.js")
    first_timestamp = File.mtime("#{RAILS_ROOT}/public/resources/default/other.js").to_i.to_s
    first_timestamp = File.mtime("#{RAILS_ROOT}/public/resources/default/other.js").to_i.to_s
    @user.get "/signin?popup=true"
    @user.assert_select "script[src=?]", "/resources/default/other.js?#{first_timestamp}"
    self.class.cleanup
    sleep 1
    @user.assert !File.exists?("#{RAILS_ROOT}/public/resources")
    @user.get "/resources/default/other.js"
    second_timestamp = File.mtime("#{RAILS_ROOT}/public/resources/default/other.js").to_i.to_s
    @user.get "/signin?popup=true"
    @user.assert_not_equal first_timestamp, second_timestamp
    @user.assert_select "script[src=?]", "/resources/default/other.js?#{second_timestamp}"
  end
  
  protected
  
  def self.cleanup
    ResourcesController.clear_all
  end
  cleanup

end
