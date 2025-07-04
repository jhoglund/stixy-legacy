class ResourcesController < ApplicationController
  after_filter :set_header
  
  def log
    if params[:body]
      line = params[:body][:lineNumber]
      message = params[:body][:message]
      label = params[:body][:label]
      errorclass = "JS#{session[:browser][:type].capitalize}#{params[:body][:name]}"
      eval("class #{errorclass} < StandardError; end")
      begin
        raise eval(errorclass).new("#{(line.class==String) ? "(#{line})" : ""} #{(label.class==String) ? "#{label.titlecase}: #{message}" : message}")
      rescue => e
        data = exception_to_data(e)
        data[:backtrace] = ''
        data.merge(
          :error_class => e, 
          :error_message => e
        )
        HoptoadNotifier.notify(data)
      end
    end
    render :inline => "true", :status => 200
  end
  
  
  # This should be done differantly. Instead of creating the resource files in the controller, they should be created in the
  # AssetTagHelper module. 
  # In addition to the code below, there is some enhancements done to the AssetTagHelper in the lib/stixy_extensions.rb file.
  def generate
    build("#{RAILS_ROOT}/public/#{(params[:mime]=="css" ? "stylesheets" : "javascripts" )}/",params[:mime]) do |dir, str|
      if(params[:type]=="default")
        dir << "default"
        dir << "widgets"
        str << ";\n Stixy.browser = '#{params[:browser]}';" if params[:mime]=="js"
        str << "\n Stixy.ENV = '#{ENV['RAILS_ENV']}';" if params[:mime]=="js"
      else
        dir << params[:type]
      end
    end
  end
  
  # --------------------------
  # Protected Methods
  # --------------------------
  
  protected  
  
  private
  
  def exception_to_data exception #:nodoc:
    data = {
      :api_key       => HoptoadNotifier.configuration.api_key,
      :error_class   => exception.class.name,
      :error_message => "#{exception.class.name}: #{exception.message}",
      :backtrace     => exception.backtrace,
      :environment   => ENV.to_hash
    }

    if self.respond_to? :request
      data[:request] = {
        :params      => request.parameters.to_hash,
        :rails_root  => File.expand_path(RAILS_ROOT),
        :url         => "#{request.protocol}#{request.host}#{request.request_uri}"
      }
      data[:environment].merge!(request.env.to_hash)
    end

    if self.respond_to? :session
      data[:session] = {
        :key         => session.instance_variable_get("@session_id"),
        :data        => session.respond_to?(:to_hash) ?
                          session.to_hash :
                          session.instance_variable_get("@data")
      }
    end

    data
  end
  
  
  def set_header
    headers["Content-Type"] = params[:mime]=="css" ? "text/css" : "application/x-javascript" 
  end
  
  def build root="", ext=""
    dir = []
    str = ""
    yield dir, str
    tmp_file = ""
    tmp_file << "var STIXY_FILE_GENERATED_AT = '#{ Time.now }';\n" if params[:mime] == "js"
    tmp_file << "/* STIXY_FILE_GENERATED_AT: #{ Time.now } */\n\n" if params[:mime] == "css"
    tmp_file << "var STIXY_ENV = '#{ENV["RAILS_ENV"]}';\n" if params[:mime] == "js"
    all = []
    all << File.join(root, "start")
    all.concat(dir.collect {|directory| File.join(root, "all", directory) })
    all.concat(dir.collect {|directory| File.join(root, params[:browser].gsub("_","/"), directory) })  if params[:browser]
    all << File.join(root, "end")
    all.each do |c|
      Dir.glob(File.join(c, "**", "*." << ext)).sort_by { |x| x.split("/").last.split("_")[0].to_i }.each do |file|
        tmp_file << File.read(file) << "\n\n"
      end
    end
    tmp_file << str unless str.empty?
    rendered_file = render :content_type => ext, :inline =>  tmp_file
    if RESOURCE_CACHING==true
      dir_path = File.join(RAILS_ROOT,"public","resources",params[:type])
      dir_path = File.join(dir_path,params[:version]) if params[:version]
      archive_path = File.join(RAILS_ROOT,"shared","resource_archive",params[:type])
      FileUtils.mkdir_p(dir_path)
      FileUtils.mkdir_p(archive_path)
      full_path = File.join(dir_path,"#{params[:browser]}.#{params[:mime]}")
      full_archive_path = File.join(archive_path,"#{params[:browser]}_#{Time.now.to_i.to_s}.#{params[:mime]}")
      File.open(full_path, "wb+") { |f| f.write(rendered_file) }
      FileUtils.cp(full_path, full_archive_path)
    end
    rendered_file
  end
  
  def self.clear_all
    FileUtils.rm_rf("#{RAILS_ROOT}/public/resources")
    ActionView::Base.computed_public_paths.delete_if{|key,value|
      /^\/resources\// =~ value
    }
  end
    
end
