require File.dirname(__FILE__) + '/../test_helper'

#require 'message'

class MessageTest < Test::Unit::TestCase
  fixtures :messages, :users, :switchboards

	def test_create_read_update_delete

		# create a brand new message
		message1 = Message.new(:text => 'Test Message from unittest')

		# save it
		assert message1.save

		# read it back
		message2 = Message.find(message1.id)

		# compare the texts
		assert_equal message1.text, message2.text

		# change the text
		message2.text = 'Some new message'

		# save the changes
		assert message2.save

		# the message gets killeds
		assert message2.destroy
	end

end
