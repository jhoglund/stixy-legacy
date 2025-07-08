require File.expand_path('../../test_helper', __FILE__)

class KeywordTest < Test::Unit::TestCase
  fixtures :keywords

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Keyword, keywords(:first)
  end
end
