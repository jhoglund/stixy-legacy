class JavascriptLogger < Logger
  def format_message(severity, timestamp, progname, msg)
    "#{timestamp.to_formatted_s(:db)} #{severity} #{msg}\n" 
  end 
  def server msg
    info "SERVER " + msg
  end
  def client msg
    info "CLIENT " + msg
  end
end