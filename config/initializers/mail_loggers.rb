mail_log_file = File.open(RAILS_ROOT + "/log/mail.log",'w')
mail_log_file.sync = true
MAIL_LOGGER = MailLogger.new(mail_log_file)
