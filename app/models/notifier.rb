class Notifier < ActionMailer::Base
	helper Admin::NewsletterHelper

  def template_mail arguments
    mail_logger do
      args = get_arguments(arguments, { :from => "admin@stixy.com" })
      recipients args[:to] if args[:to]
      cc args[:cc] if args[:cc]
      bcc args[:bcc]
      from args[:from] 
      headers["reply-to"] = args[:reply] || args[:from]
      subject args[:subject]
      if args[:html] == true
        content_type    "multipart/alternative"
        part  :content_type => "text/plain", :charset => "utf-8", :body => render_message("mail.text.plain.rhtml", :content => args[:content])
        part "multipart/related" do |p|
          p.part  :content_type => 'text/html', :charset => "utf-8", :body => render_message("mail.text.html.rhtml", :content => args[:content])
          p.inline_attachment :content_type => "image/png", :body => File.read("#{RAILS_ROOT}/public/images/main_template/mt_guest_signature_white_bg.png"),:cid => '<mt_guest_signature>'
          p.inline_attachment :content_type => "image/gif", :body => File.read("#{RAILS_ROOT}/public/images/main_template/mt_guest_bg_pattern.gif"),        :cid => '<mt_guest_bg_pattern>'
        end
      else
        body render_message("mail.text.plain.rhtml", :content => args[:content])
      end
    end
  end
  
  def invite(invite, send_user, reminder=nil)
    address = get_address(invite.accepted_user.email)
    recipients address
    from  "#{invite.inviter_user.display_name}  <invitation@stixy.com>"
    mail_logger(from, recipients, "Invitation#{reminder ? ' (reminder)' : ''}") do
      # Email header info MUST be added here
      headers["Reply-To"] = invite.inviter_user.email
      subject((reminder ? "A reminder that you are invited to join the Stixyboard \"#{invite.board.title}\"" : "Join the Stixyboard \"#{invite.board.title}\"")) 
      #unless reminder
      #  content_type    "multipart/alternative"
      #  part  :content_type => "text/plain", :charset => "utf-8",
      #        :body => render_message("invite.text.plain.rhtml", :invite => invite, :reminder => reminder)
      #  part "multipart/related" do |p|
      #    p.part  :content_type => 'text/html', :charset => "utf-8",
      #            :body => render_message("invite.text.html.rhtml", :invite => invite, :reminder => reminder)
      #    p.inline_attachment :content_type => "image/png", :body => File.read("#{RAILS_ROOT}/public/images/main_template/mt_guest_signature_white_bg.png"),:cid => '<mt_guest_signature>'
      #    p.inline_attachment :content_type => "image/gif", :body => File.read("#{RAILS_ROOT}/public/images/main_template/mt_guest_bg_pattern.gif"),        :cid => '<mt_guest_bg_pattern>'
      #  end
      #else
        body render_message("invite.text.plain.rhtml", :invite => invite, :reminder => reminder)
      #end
    end
  end
  
  def reset(user, new_passwd)
    mail_logger do
      address = get_address(user.login)
      recipients address
      from  "Stixy Member Services <memberservices@stixy.com>"
      subject "Your new password"
      body render_message("reset.text.plain.rhtml", :user => user, :password => new_passwd)
      #content_type    'multipart/alternative'
      #
      #part  :content_type => 'text/plain', :charset => "utf-8",
      #      :body => render_message("reset.text.plain.rhtml", :user => user, :password => new_passwd)
      #
      #part 'multipart/related' do |p|
      #  p.part  :content_type => 'text/html', :charset => "utf-8",
      #          :body => render_message("reset.text.html.rhtml", :user => user, :password => new_passwd)
      #  p.inline_attachment :content_type => "image/png", :body => File.read("#{RAILS_ROOT}/public/images/main_template/mt_guest_signature_white_bg.png"),:cid => '<mt_guest_signature>'
      #  p.inline_attachment :content_type => "image/gif", :body => File.read("#{RAILS_ROOT}/public/images/main_template/mt_guest_bg_pattern.gif"),        :cid => '<mt_guest_bg_pattern>'
      #end
    end
  end
  
  def notify_board_update(sender, reciever, board)
    mail_logger do
      address = get_address(reciever.login)
      recipients address
      from  "#{sender.display_name}  <member@stixy.com>"
      headers["Reply-To"] = sender.email
      subject "[Stixy] Board has been updated"
      content_type    'multipart/alternative'

      part  :content_type => 'text/plain', :charset => "utf-8",
            :body => render_message("board_update.text.plain.rhtml", :sender => sender, :reciever => reciever, :board => board)

      part 'multipart/related' do |p|
        p.part  :content_type => 'text/html', :charset => "utf-8",
                :body => render_message("board_update.text.html.rhtml", :sender => sender, :reciever => reciever, :board => board)
        p.inline_attachment :content_type => "image/png", :body => File.read("#{RAILS_ROOT}/public/images/main_template/mt_guest_signature_white_bg.png"),:cid => '<mt_guest_signature>'
        p.inline_attachment :content_type => "image/gif", :body => File.read("#{RAILS_ROOT}/public/images/main_template/mt_guest_bg_pattern.gif"),        :cid => '<mt_guest_bg_pattern>'
      end
    end
  end
  

	# Send newsletter
	#
  def newsletter (arguments)
    mail_logger do
      args = get_arguments(arguments, { :from => "Stixy Newsletter <newsletter@stixy.com>" })
      recipients !args[:to].blank? ? get_address(args[:to]) : args[:from]
      cc args[:cc] if args[:cc]
      bcc args[:bcc]
      from args[:from] 
      status Status::DEACTIVATED
  	  priority Priority::LOW
  		headers["reply-to"] = args[:reply] || args[:from]
      subject "[Stixy] #{args[:subject] }"
      if args[:html] == true
        content_type    "multipart/alternative"
        part  :content_type => "text/plain", :charset => "utf-8", :body => render_message("newsletter.text.plain.rhtml", :content => args[:content])
        part "multipart/related" do |p|
          p.part  :content_type => 'text/html', :charset => "utf-8", :body => render_message("newsletter.text.html.rhtml", :content => args[:content])
          #p.inline_attachment :content_type => "image/png", :body => File.read("#{RAILS_ROOT}/public/images/main_template/mt_guest_signature_white_bg.png"),:cid => '<mt_guest_signature>'
          #p.inline_attachment :content_type => "image/gif", :body => File.read("#{RAILS_ROOT}/public/images/main_template/mt_guest_bg_pattern.gif"),        :cid => '<mt_guest_bg_pattern>'
        end
      else
        body render_message("newsletter.text.plain.rhtml", :content => args[:content])
      end
    end
  end


	## Send board notification
	#
  def board_notification (arguments, board, sender)
    args = get_arguments(arguments, {:html => false})
    recipients get_address(args[:to]) if args[:to]
    mail_logger(args[:from], recipients, 'Board Notification') do
      cc args[:cc] if args[:cc]
      bcc args[:bcc]
      from args[:from]
      headers["reply-to"] = args[:reply] || args[:from]
      subject "[Stixy] Stixyboard notification"
      if args[:html] == true
        content_type    "multipart/alternative"
        part  :content_type => "text/plain", :charset => "utf-8", :body => render_message("board_notification.text.plain.rhtml", :content => args[:content], :board => board, :sender => sender)
        part "multipart/related" do |p|
          p.part  :content_type => 'text/html', :charset => "utf-8", :body => render_message("board_notification.text.html.rhtml", :content => args[:content], :board => board, :sender => sender)
          p.inline_attachment :content_type => "image/png", :body => File.read("#{RAILS_ROOT}/public/images/main_template/mt_guest_signature_white_bg.png"),:cid => '<mt_guest_signature>'
          p.inline_attachment :content_type => "image/gif", :body => File.read("#{RAILS_ROOT}/public/images/main_template/mt_guest_bg_pattern.gif"),        :cid => '<mt_guest_bg_pattern>'
        end
      else
        body render_message("board_notification.text.plain.rhtml", :content => args[:content], :board => board, :sender => sender)
      end
    end
  end


  #Send mail to new user with activation code
   def signup_notification(user)
     mail_logger do
      setup_email(user)
      @subject     = 'Please activate your new account'
      @body[:url]  = "http://www.stixy.com/activate/#{user.activation_code}"
    end
  end
  
  #Welcome mail to new user after activated account
  def activation(user)
    mail_logger do
      setup_email(user)
      @subject     = 'Welcome to Stixy!'
      @body[:url]  = "http://www.stixy.com/"
    end
  end
  
  def welcome_mail user
    recipients get_address(user.login)
    from "Stixy Team <no-reply@stixy.com>" 
    mail_logger(from, recipients, 'Welcome') do
      #priority Priority::LOW
      headers["reply-to"] = "no-reply@stixy.com"
      subject "Welcome to Stixy!"
      content_type    "multipart/alternative"
      part  :content_type => "text/plain", :charset => "utf-8", :body => render_message("welcome.text.plain.rhtml", :content => "")
      part "multipart/related" do |p|
        p.part  :content_type => 'text/html', :charset => "utf-8", :body => render_message("welcome.text.html.rhtml", :content => "")
        p.inline_attachment :content_type => "image/png", :body => File.read("#{RAILS_ROOT}/public/images/main_template/mt_guest_signature_white_bg.png"),:cid => '<mt_guest_signature>'
        p.inline_attachment :content_type => "image/gif", :body => File.read("#{RAILS_ROOT}/public/images/main_template/mt_guest_bg_pattern.gif"),        :cid => '<mt_guest_bg_pattern>'
        p.inline_attachment :content_type => "image/gif", :body => File.read("#{RAILS_ROOT}/public/images/welcome_letter/welcome_01.gif"),                :cid => '<welcome_01>'
        p.inline_attachment :content_type => "image/gif", :body => File.read("#{RAILS_ROOT}/public/images/welcome_letter/welcome_02.gif"),                :cid => '<welcome_02>'
        p.inline_attachment :content_type => "image/gif", :body => File.read("#{RAILS_ROOT}/public/images/welcome_letter/welcome_03.gif"),                :cid => '<welcome_03>'
        p.inline_attachment :content_type => "image/gif", :body => File.read("#{RAILS_ROOT}/public/images/welcome_letter/welcome_04.gif"),                :cid => '<welcome_04>'
        p.inline_attachment :content_type => "image/gif", :body => File.read("#{RAILS_ROOT}/public/images/welcome_letter/new_stixyboard.gif"),            :cid => '<new_stixyboard>'
        p.inline_attachment :content_type => "image/gif", :body => File.read("#{RAILS_ROOT}/public/images/welcome_letter/share.gif"),                     :cid => '<share>'
      end
      ''
    end
  end
  
  #Bug report from a user to the Stixy Team
  def bug_report(bug)
     @recipients  = "bug@stixy.com"
     @from        = "#{bug.first_name} #{bug.last_name} <#{bug.email}>"
     mail_logger(@from, @recipients, 'Bug report') do
       @sent_on     = Time.now
       @subject     = 'Bug report!'
       @content_type = 'text/html'
       @body[:bug]  = bug
     end
  end
  
  #Feedback report from a user to the Stixy Team
  def feedback_report(feedback)
     @recipients  = "feedback@stixy.com"
     @from        = "#{feedback.first_name} #{feedback.last_name} <#{feedback.email}>"
     mail_logger(@from, @recipients, 'Feedback') do
       @sent_on     = Time.now
       @subject     = 'Feedback report!'
       @content_type = 'text/html'
       @body[:feedback]  = feedback
     end
  end
  
  protected
    def mail_logger from='', to='', type=''
      begin
        mail = yield
        MAIL_LOGGER.info "\n------------------------------------\nFrom: #{from}\nTo: #{to}\nType: #{type}\n\n#{mail}\n------------------------------------"
      rescue Exception => e 
        HoptoadNotifier.notify(
          :error_class   => "Mail Error",
          :error_message => "Mail Error: #{e.message}",
          :backtrace => e.backtrace,
          :parameters    => "From: #{from}\nTo: #{to}\nType: #{type}\n\n#{mail}"
        )
      end
    end
    
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "Stixy Team <signup@stixy.com>"
      @sent_on     = Time.now
      @body[:user] = user
    end
    
    # In development mode, send to dev_address instead of the address(s) past as the argument
    def get_address address="no_address@stixy.com"
      dev_address = "hoglundj@gmail.com"
      return (RAILS_ENV == "development") ? dev_address : address
    end
    
    def get_arguments arguments={}, custom_arguments={}
      return { 
        :html => true, 
        :to => "", 
        :cc => nil, 
        :bcc => nil, 
        :from => nil,
        :subject => "", 
        :reply => nil, 
        :content => "" 
      }.merge!(custom_arguments).merge!(arguments)
    end
    
end
