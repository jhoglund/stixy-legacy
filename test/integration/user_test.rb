require "#{File.dirname(__FILE__)}/../test_helper"

class UserTest < ActionController::IntegrationTest
  fixtures :users, :boards, :boardusers, :invites, :user_notifications

  # Replace this with your real tests.
  def test_deactivate_user
		# Set session for user Jonas
		jonas_session = new_session_as :jonas
		jonas = User.find_by_login("jonas@stixy.com")
		adam = User.find_by_login("adam@stixy.com")

		# Create new board
		board = Board.new(:status => 1)
		board.save
		jonas.boards << board

		# Create new invite
		invite = Invite.new(:board_id => board.id, :status => 1)
		invite.save
		jonas.invitations << invite

		# Create new user notification
		user_notification = UserNotification.new(:user_id => jonas.id, :time => Time.now, :widget_instance_id => 1, :status => 1)
		jonas.user_notifications << user_notification

		# Create new contact if jonas has no contacts
#		if jonas.contacts.size <= 1
#			jonas.contacts << adam
#		end


		## Start sizes
		# Number of boards where user is alone
		all_boards = jonas.boards
		jonas_start_boards_size = 0
		for board in all_boards
			if board.users.size <= 1
				jonas_start_boards_size += 1
			end
		end
		jonas_start_boardusers_size = jonas.boardusers.size
		jonas_start_invitations_size = jonas.invitations.size
		jonas_start_usernotifications_size = jonas.user_notifications.size
#		jonas_start_contacts_size = ActiveRecord::Base.find_by_sql(["SELECT * FROM users_contacts WHERE status = ? AND (user_id = ? OR contact_id = ?)", Status::ACTIVE, jonas.id, jonas.id]).size

#		assert_equal(1, jonas_start_contacts_size)




		# Render Settings
    jonas_session.get "/setting/index/"
		jonas_session.assert_response :success
		jonas_session.assert_template "index"

		# Post to deactivate account function
		jonas_session.post("/setting/deactivate_user_account")



		# Check signout
		assert_nil(jonas_session.session[:user_id])

		# Check that user.status is canceled
		assert_equal(Status::CANCELED, User.find_by_login("jonas@stixy.com").status)

		# Check that boards where user is alone is canceled
		jonas_canceled_boards_size = Board.find_by_sql(["SELECT * FROM boards, boardusers WHERE user_id = ? AND boards.status = ? AND boardusers.board_id = boards.id", jonas.id, Status::CANCELED]).size
		assert_equal(jonas_start_boards_size, jonas_canceled_boards_size)

		# Check that boardusers for jonas is canceled
		jonas_canceled_boardusers_size = Boarduser.find(:all, :conditions => ["user_id = ? AND status = ?", jonas.id, Status::CANCELED ]).size
		assert_equal(jonas_start_boardusers_size, jonas_canceled_boardusers_size)


		# Check that user hasn't got any active boards or boardusers
		jonas.reload
		assert_equal(0, jonas.boards.size)
		assert_equal(0, jonas.boardusers.size)


		# Check that users invitations are canceled
		jonas_canceled_invitations_size = jonas.invitations.find(:all, :conditions => ["status = ?", Status::CANCELED]).size
		assert_equal(jonas_start_invitations_size, jonas_canceled_invitations_size)

		# Check that users usernotifications are canceled
		jonas_canceled_usernotifications_size = jonas.user_notifications.find(:all, :conditions => ["status = ?", Status::CANCELED]).size
		assert_equal(jonas_start_usernotifications_size, jonas_canceled_usernotifications_size)


  end

end
