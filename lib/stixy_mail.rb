module StixyMail
  
  class Base < ActionMailer::Base
    adv_attr_accessor :priority
    
    def deliver!(mail = @mail)
      mail.destinations.each do |destination|
        Email.create!(:mail => mail, :to => destination, :from => mail.from.first, :priority => mail.priority)
      end
    end
 
    def create_mail_with_enhancment
      mail = create_mail_without_enhancment
      mail.priority = priority
      return mail
    end
    alias_method_chain :create_mail, :enhancment
  end
    
end