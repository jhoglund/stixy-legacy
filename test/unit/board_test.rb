require File.dirname(__FILE__) + '/../test_helper'

class BoardTest < Test::Unit::TestCase
  fixtures :boards

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Board, boards(:first)
  end
end
