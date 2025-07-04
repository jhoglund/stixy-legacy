class FeedbackController < Stixyboard

  @@default_layout = "decorator-popup"
  layout :choose_layout
  
  def index
    if request.post?
      @feedback = Feedback.new(params[:feedback])
      @feedback.user_agent = request.env["HTTP_USER_AGENT"]
      @feedback.user_id = current_user.id if logged_in?
      if @feedback.save
        #Send the report to the Stixy Team
        Notifier.deliver_feedback_report(@feedback)
        flash[:notice] = "Thanks for your help to make Stixy better!"
      else
        @browser_info = Stixy::UserAgent.new(request.env["HTTP_USER_AGENT"])
      end
    else
      @browser_info = Stixy::UserAgent.new(request.env["HTTP_USER_AGENT"])
      @feedback = Feedback.new(
        :first_name => current_user.first_name,
        :last_name => current_user.last_name,
        :email => current_user.email
      )
    end
    render_as_popup do
      render :layout => "decorator-public" and return
    end
  end
  
  def report_a_bug
    if request.post?
      @bug = Bug.new(params[:bug])
      @bug.user_agent = request.env["HTTP_USER_AGENT"]
      @bug.user_id = current_user.id if logged_in?
      if @bug.save
        #Send the report to the Stixy Team
        Notifier.deliver_bug_report(@bug)
        flash[:notice] = "Thanks for your help to make Stixy better!"
      else
        @browser_info = Stixy::UserAgent.new(request.env["HTTP_USER_AGENT"])
      end
    else
      @browser_info = Stixy::UserAgent.new(request.env["HTTP_USER_AGENT"])
      @bug = Bug.new(
        :first_name => current_user.first_name,
        :last_name => current_user.last_name,
        :email => current_user.email
      )
    end
    render_as_popup do
      render :layout => "decorator-public" and return
    end
  end  
  
end
