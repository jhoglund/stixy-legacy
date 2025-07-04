class QuestionerController < Stixyboard
  helper "public"
  def bth
    unless params[:id] == "results"
      render_as_popup do
        if request.post?
          for i in params[:questions]
            Questioner.create(:name => i[0], :comment => i[1], :label => "bth", :group_id => session[:session_key]) unless i[1].empty?
          end
          flash[:message] = <<-msg
            <h1>Thank you for your help!</h1>
          	<p>Your answers will help us in our efforts to improve Stixy.</p>
          	<p>You may now continue to sing-in.</p>
          msg
          redirect_to :controller => "/public", :action => "signin", :popup => "true" and return
        end
        render :layout => "decorator-public" and return
      end
    else
      results do
        @label = "bth"
        @users = [158]
        @columns = [:date, :got_to_know, :how_to_use, :what_is_best, :what_to_get, :additional]
      end
    end
  end
  
  private
  
  def results
    @user = get_user
    @results = []
    @label="", @users=[], @columns=[]
    yield 
    Struct.new("Group", *@columns)
    if @user.authorized? || @users.include?(@user.id)
      Questioner.find_by_sql("SELECT DISTINCT group_id FROM questioners WHERE label='#{@label}'").each do |group|
        member = Struct::Group.new
        group = Questioner.find(:all, :conditions => ["label=? and group_id = ?", @label, group.group_id], :order => "created_at")
        member.date = group.first.created_at
        group.each do |row|
          member[row.name] = row
        end
        @results << member
      end
    end
    render :layout => false, :template => "questioner/#{@label}_results" and return
  end
end
