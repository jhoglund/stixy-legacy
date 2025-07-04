module ActionMailer
  
  module PartContainer

    # Add an inline attachment to a multipart message. 
    def inline_attachment(params, &block)
      params = { :content_type => params } if String === params
      params = { :disposition => "attachment",
                 :transfer_encoding => "base64" }.merge(params)
      params[:headers] ||= {}
      params[:headers]['Content-ID'] = params[:cid]
      part(params, &block)
    end

  end
  
end
