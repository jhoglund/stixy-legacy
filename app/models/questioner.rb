class Questioner < ActiveRecord::Base
  def before_create
    self.user_login ||= ''
  end
end
