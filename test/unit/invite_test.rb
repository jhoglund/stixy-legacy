require File.dirname(__FILE__) + '/../test_helper'

class InviteTest < Test::Unit::TestCase
  fixtures :invites, :users

  def test_invite
    assert_kind_of Invite, invites(:invite_adam_to_existing_board)
  end
  
  def test_find_all_pending
    assert_equal 6, Invite.find_pending.size
  end
  
  def test_find_pending_by_one_date
    assert_equal 1, Invite.find_pending(-4.day.from_now).size
  end
  
  def test_find_pending_by_three_date
    assert_equal 3, Invite.find_pending(-4.day.from_now,-8.day.from_now,-12.day.from_now).size
  end
  
end
