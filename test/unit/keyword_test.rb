require File.dirname(__FILE__) + '/../test_helper'

class KeywordTest < Test::Unit::TestCase
  fixtures :keywords

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Keyword, keywords(:first)
  end
end
