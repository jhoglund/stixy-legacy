require File.dirname(__FILE__) + '/../test_helper'

class BugTest < Test::Unit::TestCase
  fixtures :bugs
  
  def test_fing_bugs
    assert_equal 1, Bug.find(:all).size
  end

  def test_create_valid_bug_report
    bug = Bug.new
    bug.user_id = 2
    bug.first_name = "Jonas"
    bug.last_name = "Höglund"
    bug.email = "jonas@stixy.com"
    bug.browser = "Firefox 2.0.0.12"
    bug.platform = "Mac OS X"
    bug.user_agent = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; sv-SE; rv:1.8.1.12) Gecko/20080201 Firefox/2.0.0.12"
    bug.description = "This is a bug report"
    assert bug.save
  end
  
  def test_create_invalid_bug_report
    bug = Bug.new
    bug.user_id = 2
    bug.first_name = "Jonas"
    #bug.last_name = "Höglund"
    bug.email = "jonasstixy.com"
    bug.browser = "Firefox 2.0.0.12"
    bug.platform = "Mac OS X"
    bug.user_agent = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X; sv-SE; rv:1.8.1.12) Gecko/20080201 Firefox/2.0.0.12"
    bug.description = "This is a bug report"
    assert !bug.save
  end
  
end
