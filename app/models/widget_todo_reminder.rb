class WidgetTodoReminder < ActionMailer::Base
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::SanitizeHelper

  def self.testar
    Time.now
  end
  
  def self.notify
    time = Time.now + 300
    reminders = UserNotification.pending(time)
    # ActiveRecord::Base.logger.debug("#{reminders.size} in set #{Time.now}.")
    begin
      reminders.each do |reminder|
        widget = WidgetTodo.find(reminder.widget_instance_id)
        ActiveRecord::Base.silence do
          self.deliver_notifier_mail(widget, reminder)
        end
        # ActiveRecord::Base.logger.debug("Reminder for widget #{widget.id} was sent to #{reminder.user.email} on #{Time.now}.")
      end
      UserNotification.deactivate(time)
      logger.info("#{reminders.size} reminder(s) was successfully sent on #{Time.now}.") if reminders.size > 0
    rescue => msg
      logger.error("Error: #{msg}")
    end
  end
  
  def notifier_mail(widget, reminder)
    subj = widget.comment.empty? ? "" : ": #{truncate(strip_tags(widget.comment).gsub("&nbsp;", " ").gsub(/\s+/," "), 50)}"
    address = (RAILS_ENV == "development") ? "hoglundj@gmail.com" : reminder.user.email
    recipients address
    from  "Todo Reminder <reminder@stixy.com>"
    subject "[Stixy] Reminder#{ subj }"
    #priority Priority::HIGH
    body render_message("widget_todo.text.plain.rhtml", :widget => widget, :reminder => reminder)
    # content_type    'multipart/alternative'
    # 
    # part  :content_type => 'text/plain', :charset => "utf-8",
    #       :body => render_message("widget_todo.text.plain.rhtml", :widget => widget, :reminder => reminder)
    # 
    # part 'multipart/related' do |p|
    #   p.part  :content_type => 'text/html', :charset => "utf-8",
    #           :body => render_message("widget_todo.text.html.rhtml", :widget => widget, :reminder => reminder)
    #   p.inline_attachment :content_type => "image/gif", :body => File.read("#{RAILS_ROOT}/public/images/main_template/mt_guest_bg_pattern.gif"),        :cid => '<mt_guest_bg_pattern>'
    #   p.inline_attachment :content_type => "image/png", :body => File.read("#{RAILS_ROOT}/public/images/main_template/mt_guest_signature_white_bg.png"),:cid => '<mt_guest_signature>'
    # end
  end
  
  
end
  
