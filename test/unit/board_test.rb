require File.expand_path('../../test_helper', __FILE__)

class BoardTest < Test::Unit::TestCase
  fixtures :boards

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Board, boards(:first)
  end
end
