class Admin::NewsletterController < Admin::AdminApplicationController
  require 'resolv'
  include StixyRenderMethods
  
  def index
    list
    render :action => 'list'
  end


  def list
		@newsletters = Newsletter.find(:all)
  end

	def show
		user = User.find(:first, :order => ["id DESC"])
		@top_id = user.id
		@newsletter = Newsletter.find(params[:id])
		@content = @newsletter.body
		@html_preview = render_to_string(:template => "notifier/newsletter.text.html.rhtml", :layout => false)
		@text_preview = render_to_string(:template => "notifier/newsletter.text.plain.rhtml", :layout => false)
	end
	
	def ajax_preview
	  @newsletter = Newsletter.new(params[:newsletter])
		@content = @newsletter.body || ""
		#html = with_images({:mt_guest_signature => "http://#{SERVER}/images/main_template/mt_guest_signature.png", :mt_guest_bg_pattern => "http://#{SERVER}/images/main_template/mt_guest_bg_pattern.gif"}) do 
    #  render_to_string(:template => "notifier/newsletter.text.html.rhtml", :layout => false)
    #end
    html = render_to_string(:template => "notifier/newsletter.text.html.rhtml", :layout => false)
    text = "<pre>" + render_to_string(:template => "notifier/newsletter.text.plain.rhtml", :layout => false) + "</pre>"
	  render :json => { :html_preview => html, :text_preview => text }.to_json
  end

  def create
		if !params[:id].nil?
			@newsletter = Newsletter.find(params[:id])
		end
		if request.post?
	    @newsletter = Newsletter.new(params[:newsletter])
			@newsletter.user_id = current_user.id
			if @newsletter.save 
		    redirect_to("/admin/newsletter/show/#{@newsletter.id}")
	    	flash[:notice] = "Newsletter added."
			end
		end
  end


	def edit
		@newsletter = Newsletter.find(params[:id])
		if request.post?
			@newsletter.user_id = current_user.id
  		if @newsletter.update_attributes(params[:newsletter])
  			flash.now[:notice] = "Saved"
		    redirect_to("/admin/newsletter/show/#{@newsletter.id}")
  		end
  	end
	end


	def destroy
		newsletter = Newsletter.find(params[:id])
		if newsletter.destroy
	    redirect_to('/admin/newsletter/list')
		end
	end


#	def send_newsletter
#		# The newsletter
#		newsletter = Newsletter.find(params[:id])
#		## If testmail to myself for test or to all active users that wants newsletter
#		#
#		if !params[:to].nil?
#			if params[:to] == "me"
#				args = {
#					:to => current_user.email,
#					:subject => newsletter.subject,
#					:content => newsletter.body
#				}
#				# Send newsletter
#				Notifier.deliver_newsletter(args)
#				flash[:notice] = "Newsletter sent"
#		## If newsletter to all users
#		#
#			elsif params[:to] == "users"
#				if request.post? && !params[:range][:from].empty? && !params[:range][:to].empty?
#					@users = User.find(:all, :conditions => ["status = 1 AND receive_newsletter = 1 AND id >= ? AND id <= ?", params[:range][:from], params[:range][:to]])
#					# Collect all emails
#					emails = []
#					for user in @users
#							emails << user.email.to_s + ", "
#					end
#					## Devide up the emails into nice pieces = step
#					#
#					# Vars
#					step = 500							# Step size, number of bcc at one time
#					size = emails.size 			# Total number of newsletters
#					t = size / step					# Number of times to loop
#					rest = size % step 			# The rest of the emails
#					i = 0 									# Index variable
#					bcc = [] 								# Mail array
#					# Loop through all emails
#					t.times do
#						bcc << emails.slice(i, step)
#						i += step
#					end
#					# Add the rest of the emails
#					if rest != "0"
#						bcc << emails.slice(i, rest)
#					end
#					## Deliver mails
#					for emails in bcc
#						args = {
#								:bcc => emails.to_s.chomp(", ") ,
#								:subject => newsletter.subject,
#								:content => newsletter.body
#						}
#          Notifier.deliver_newsletter(args) 
#					end
#					flash[:notice] = "Newsletter sent"
#				else
#					flash[:error] = "Something wen't wrong"
#				end
#			end
#		end
#    redirect_to('/admin/newsletter/list')
#		
#	end

def send_newsletter
  # The newsletter
	newsletter = Newsletter.find(params[:id])
	## If testmail to myself for test or to all active users that wants newsletter
	#
	if !params[:to].nil?
		if params[:to] == "me"
			args = {
				:to => current_user.email,
				:subject => newsletter.subject,
				:content => newsletter.body
			}
			# Send newsletter
			Notifier.store_newsletter(args)
			flash[:notice] = "Newsletter sent"
	## If newsletter to all users
		elsif params[:to] == "users"
			if request.post? && !params[:range][:from].empty? && !params[:range][:to].empty?
				@users = User.find(:all, :conditions => ["status = 1 AND receive_newsletter = 1 AND id >= ? AND id <= ?", params[:range][:from], params[:range][:to]])
				ActiveRecord::Base.silence {
				  mail = Notifier.create_newsletter(:subject => newsletter.subject, :content => newsletter.body) 
  				for user in @users
  				  mail.to = user.email
  				  Notifier.store(mail)
  				end
			  }
				flash[:notice] = "Newsletter sent"
			else
				flash[:error] = "Something went wrong"
			end
		end
	end
  redirect_to('/admin/newsletter/list')
end

private 

def with_images options
  string = yield 
  options.each do |key, value|
    string.gsub!(Regexp.new("cid:#{key.to_s}"), value)
  end
  return string
end


end



