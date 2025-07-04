module ActionController #:nodoc:
  module Caching
    module Fragments
      if RAILS_ENV == 'staging'
        def read_fragment(key, options = nil)
          return 
        end
        def write_fragment(key, content, options = nil)
          return 
        end
        
      end
    end
  end
end

# TMail and ActionMailer disabled for Ruby 2.7 compatibility
# require 'tmail' 

# class TMail::Mail

#   def priority= prio=Priority::MEDIUM
#     @priority = prio
#   end
  
#   def priority
#     @priority || Priority::MEDIUM
#   end
  
#   def status= state=Status::PENDING
#     @status = state
#   end
  
#   def status
#     @status || Status::PENDING
#   end
  
#   def cleanup_extras!
#     remove_instance_variable("@priority")
#     remove_instance_variable("@status")
#   end
  
# end

# ActionMailer disabled - commenting out extensions
if defined?(ActionMailer::Base)
class ActionMailer::Base
  adv_attr_accessor :priority
  adv_attr_accessor :status
  
  class << self
    alias :method_missing_without_enhancment :method_missing
    def method_missing(method_symbol, *parameters)
      if /^store_([_a-z]\w*)/ =~ method_symbol.id2name
        new($1, *parameters).store!
      else
        method_missing_without_enhancment(method_symbol, *parameters)
      end
    end
    
    def store! mail = @mail
      mail.destinations.each do |destination|
        Email.create!(:mail => mail, :to => destination, :from => mail.from.first, :priority => mail.priority, :status => mail.status)
      end
    end
    alias :store :store!
    
    def send_stored(status = Status::PENDING, batch = 300, order = "priority desc")
      while emails = Email.find(:all, :conditions => ["status = ?", status], :order => order, :limit => batch) do
        break if emails.empty?
        for stored_mail in emails
          begin
            ActionMailer::Base.deliver(stored_mail.mail)
            stored_mail.destroy
          rescue Net::SMTPFatalError => e
            stored_mail.destroy
          rescue Net::SMTPServerBusy, Net::SMTPUnknownError, Net::SMTPSyntaxError, TimeoutError => e
            stored_mail.last_send_attempt = Time.now.to_i
            stored_mail.save rescue nil
          end
        end
      end
    end
  end
  
  def store!(mail = @mail)
    self.class.store!(mail)
  end
  alias :store :store!
  
  def create_mail_with_enhancment
    mail = create_mail_without_enhancment
    mail.priority = priority
    mail.status = status
    return mail
  end
  alias_method_chain :create_mail, :enhancment
  
  private
  
  alias :perform_delivery_smtp_without_enhancment :perform_delivery_smtp
  def perform_delivery_smtp(mail)
    mail.cleanup_extras!
    perform_delivery_smtp_without_enhancment(mail)
  end

end
end # End ActionMailer conditional

class ActionController::AbstractRequest
  def post?
    method == :post or parameters["__method"] == "post"
  end
end

module ActionController
  class AbstractRequest
    # This is to allow Firefox 3 to work with Rails 1.2.x. It's not needed for Rails 2.x
    def content_type_with_enhancment
      @env['CONTENT_TYPE'] = @env['CONTENT_TYPE'].to_s.downcase.gsub("; charset=utf-8", "")
      content_type_without_enhancment
    end
    alias_method_chain :content_type, :enhancment
  end
end


module ActionController
  module Integration
    class Session
      def multipart_post(url, parameters, headers = {})
        boundary = "----------XnJLe9ZIbbGUYtzPQJ16u1"
        post url, multipart_body(parameters, boundary), headers.merge({"CONTENT_TYPE" => "multipart/form-data; boundary=#{boundary}"})
      end
      
      def multipart_requestify(params, first=true)
        returning p = {} do
          params.each do |key, value|
            k = first ? CGI.escape(key.to_s) : "[#{CGI.escape(key.to_s)}]"
            if Hash === value
              multipart_requestify(value, false).each do |subkey, subvalue|
                p[k + subkey] = subvalue
              end
            else
              p[k] = value
            end
          end
        end
      end

      def multipart_body(params, boundary)
        multipart_requestify(params).map do |key, value|
          if value.respond_to?(:original_filename)
            File.open(value.path) do |f|
              <<-EOF
--#{boundary}\r
Content-Disposition: form-data; name="#{key}"; filename="#{CGI.escape(value.original_filename)}"\r
Content-Type: #{value.content_type}\r
Content-Length: #{File.stat(value.path).size}\r
\r
#{f.read}\r
EOF
            end
          else
            <<-EOF
--#{boundary}\r
Content-Disposition: form-data; name="#{key}"\r
\r
#{value}\r
EOF
          end
        end.join("")+"--#{boundary}--\r"
      end
    end
  end
end

def test_link(name, options = {}, html_options = {}, *parameters_for_method_reference)
  html_options.merge!(:onclick => "Stixy.board.navigatePopup(event, href)") if @inside_popup and not html_options.delete(:popup)===false
  button = Stixy::Button.new(name, html_options)
  unless button.empty
    button.tag.content = link_to(button.body, options, button.tag.attributes.to_h, *parameters_for_method_reference)
    button.tag.to_s
  else
    link_to(name, options, html_options, *parameters_for_method_reference)
  end
end



module ActionView
  module Helpers
    module FormTagHelper
      def form_tag_with_popup(url_for_options = {}, options = {}, *parameters_for_url, &block)
        start = form_tag_without_popup(url_for_options, options, *parameters_for_url, &block)
        start.sub!(/(<form .*?>)/,'\1<input type="hidden" value="true" name="popup">') if @inside_popup
        return start
      end
      alias_method_chain :form_tag, :popup
    end
    
    module TagHelper
      def content_tag_with_enhancment(name, content_or_options_with_block = nil, options = nil, &block)
        html_options = (block_given? and content_or_options_with_block.is_a?(Hash)) ? content_or_options_with_block : options
        content = block_given? ? block.call : content_or_options_with_block
        button = Stixy::Button.new(content, html_options)
        unless button.empty
          if (browser?).is_old_ie
            button.title = content
            button.body << button.title
            button.content = content_tag_without_enhancment(name, button.body, button.attributes, &block)
            button.content
          else
            button.title = content_tag_without_enhancment(name, content, button.attributes, &block)
            button.body << button.title
            button.content = button.body
            button.content
          end    
        else 
          content_tag_without_enhancment(name, content, html_options)
        end
      end
      alias_method_chain :content_tag, :enhancment
    end
    module JavaScriptHelper
      def link_to_function_with_enhancment(name, *args, &block)
        html_options = args.last.is_a?(Hash) ? args.pop : {}
        html_options.merge!(:onmousedown => "Stixy.events.stop(event)", :onmouseover => "Stixy.events.stop(event)")
        click_event = args[0]||"";
        button = Stixy::Button.new(name, html_options)
        unless button.empty
          if (browser?).is_old_ie
            button.title = name
            button.body << name
            button.content = link_to_function_without_enhancment(button.body, click_event, button.attributes, &block)
            button.content
          else
            button.title = link_to_function_without_enhancment(name, click_event, button.attributes, &block)
            button.body << button.title
            button.content = button.body
            button.content
          end    
        else
          link_to_function_without_enhancment(name, click_event, html_options, &block)
        end
      end  
      alias_method_chain :link_to_function, :enhancment
    end
    module UrlHelper  
      def link_to_with_enhancment(name, options = {}, html_options = {}, *parameters_for_method_reference)
        url = case options
         when String
           options
         else
           self.url_for(options)
         end
        html_options.merge!(:onclick => "Stixy.board.navigatePopup(event, '#{url}')") if @inside_popup and not html_options.delete(:popup)===false
        button = Stixy::Button.new(name, html_options)
        unless button.empty
          if (browser?).is_old_ie
            button.title = name
            button.body << name
            button.content = link_to_without_enhancment(button.body, options, button.attributes, *parameters_for_method_reference)
            button.content
          else
            button.title = link_to_without_enhancment(name, options, button.attributes, *parameters_for_method_reference)
            button.body << button.title
            button.content = button.body
            button.content
          end    
        else
          link_to_without_enhancment(name, options, html_options, *parameters_for_method_reference)
        end
      end
      alias_method_chain :link_to, :enhancment
    end
    module AssetTagHelper
      private
      
      # If it's a resource and it still not created, remove it from the cached paths so it can be cached once it's been generated.
      # This should be done differantly. Instead of creating the resource files in a controller, they should be created in the
      # AssetTagHelper module. We would then have no need for this hack.
      def compute_public_path_with_enhancment source, dir, ext = nil, include_host = true
        cached_path = compute_public_path_without_enhancment source, dir, ext, include_host
        if is_resource?(source) and not File.exists?(File.join(RAILS_ROOT, 'public', source + ".#{ext}"))
          has_request = @controller.respond_to?(:request)
          cache_key =
            if has_request
              [ @controller.request.protocol,
                ActionController::Base.asset_host.to_s,
                @controller.request.relative_url_root,
                dir, source, ext, include_host ].join
            else
              [ ActionController::Base.asset_host.to_s,
                dir, source, ext, include_host ].join
            end
          ActionView::Base.computed_public_paths.delete(cache_key)
        end
        cached_path
      end
      alias_method_chain :compute_public_path, :enhancment
      
      # If the file doesn't exist yet (will be recreated in ResourcesController after requested), set the rails_asset_id
      # to the current timestamp, to prevent browsers from using old resource files.
      def rails_asset_id_with_enhancment(source)
        asset_id = rails_asset_id_without_enhancment(source)
        asset_id = Time.now.to_i if is_resource?(source) and asset_id.empty?
        asset_id
      end
      alias_method_chain :rails_asset_id, :enhancment
      
      def is_resource? source=""
        Regexp.new("^/resources/") =~ source
      end
      
    end
  end
end

module Icalendar
require 'icalendar'
 class Component < Icalendar::Base
   # Print this components properties
   def print_properties
     s = ""

     @properties.each do |key,val| 
       # Take out underscore for property names that conflicted
       # with built-in words.
       if key =~ /ip_.*/
         key = key[3..-1]
       end

       # Property name
       unless multiline_property?(key)
          prelude = "#{key.gsub(/_/, '-').upcase}" + 

          # Possible parameters
          print_parameters(val) 

          # Property value
          value = ":#{val.to_ical}" 
          escaped = prelude + value.gsub("\\", "\\\\").gsub("\n", "\\n").gsub(",", "\\,")#.gsub(";", "\\;")
          s << escaped.slice!(0, MAX_LINE_LENGTH) << "\r\n " while escaped.size > MAX_LINE_LENGTH
          s << escaped << "\r\n"
          s.gsub!(/ *$/, '')
        else 
          prelude = "#{key.gsub(/_/, '-').upcase}" 
           val.each do |v| 
              params = print_parameters(v)
              value = ":#{v.to_ical}"
              escaped = prelude + params + value.gsub("\\", "\\\\").gsub("\n", "\\n").gsub(",", "\\,")#.gsub(";", "\\;")
              s << escaped.slice!(0, MAX_LINE_LENGTH) << "\r\n " while escaped.size > MAX_LINE_LENGTH
              s << escaped << "\r\n"
              s.gsub!(/ *$/, '')
           end
        end
     end
     s
   end
 end # class Component
end

# Extensions to the _time_ obect.
class Time
  # Convert to _date_ object
  def to_date; Date.parse(self.to_s) end
  alias :to_d :to_date
  # Fallback method
  def to_time; self end
  alias :to_t :to_time
end

# Extensions to the _date_ obect.
class Date
  # Convert to _time_ object
  def to_time; Time.parse(self.to_s) end
  alias :to_t :to_time
  # Fallback method
  def to_date; self end
  alias :to_d :to_date
end

module ActiveSupport
  # A Time-like class that can represent a time in any time zone. Necessary because standard Ruby Time instances are 
  # limited to UTC and the system's ENV['TZ'] zone
  class TimeWithZone
    include Comparable
    attr_reader :time_zone
  
    def initialize(utc_time, time_zone, local_time = nil, period = nil)
      @utc, @time_zone, @time = utc_time, time_zone, local_time
      @period = @utc ? period : get_period_and_ensure_valid_local_time
    end
  
    # Returns a Time or DateTime instance that represents the time in time_zone
    def time
      @time ||= utc_to_local
    end

    # Returns a Time or DateTime instance that represents the time in UTC
    def utc
      @utc ||= local_to_utc
    end
    alias_method :comparable_time, :utc
    alias_method :getgm, :utc
    alias_method :getutc, :utc
    alias_method :gmtime, :utc
  
    # Returns the underlying TZInfo::TimezonePeriod
    def period
      @period ||= time_zone.period_for_utc(@utc)
    end

    # Returns the simultaneous time in Time.zone, or the specified zone
    def in_time_zone(new_zone = ::Time.zone)
      return self if time_zone == new_zone
      utc.in_time_zone(new_zone)
    end
  
    # Returns a Time.local() instance of the simultaneous time in your system's ENV['TZ'] zone
    def localtime
      utc.getlocal
    end
    alias_method :getlocal, :localtime
  
    def dst?
      period.dst?
    end
    alias_method :isdst, :dst?
  
    def utc?
      time_zone.name == 'UTC'
    end
    alias_method :gmt?, :utc?
  
    def utc_offset
      period.utc_total_offset
    end
    alias_method :gmt_offset, :utc_offset
    alias_method :gmtoff, :utc_offset
  
    def formatted_offset(colon = true, alternate_utc_string = nil)
      utc? && alternate_utc_string || utc_offset.to_utc_offset_s(colon)
    end
  
    # Time uses #zone to display the time zone abbreviation, so we're duck-typing it
    def zone
      period.abbreviation.to_s
    end
  
    def inspect
      "#{time.strftime('%a, %d %b %Y %H:%M:%S')} #{zone} #{formatted_offset}"
    end

    def xmlschema
      "#{time.strftime("%Y-%m-%dT%H:%M:%S")}#{formatted_offset(true, 'Z')}"
    end
    alias_method :iso8601, :xmlschema
  
    def to_json(options = nil)
      %("#{time.strftime("%Y/%m/%d %H:%M:%S")} #{formatted_offset(false)}")
    end
    
    def to_yaml(options = {})
      time.to_yaml(options).gsub('Z', formatted_offset(true, 'Z'))
    end
    
    def httpdate
      utc.httpdate
    end
  
    def rfc2822
      to_s(:rfc822)
    end
    alias_method :rfc822, :rfc2822
  
    # :db format outputs time in UTC; all others output time in local. Uses TimeWithZone's strftime, so %Z and %z work correctly
    def to_s(format = :default) 
      return utc.to_s(format) if format == :db
      if formatter = ::Time::DATE_FORMATS[format]
        formatter.respond_to?(:call) ? formatter.call(self).to_s : strftime(formatter)
      else
        "#{time.strftime("%Y-%m-%d %H:%M:%S")} #{formatted_offset(false, 'UTC')}" # mimicking Ruby 1.9 Time#to_s format
      end
    end
    
    # Replaces %Z and %z directives with #zone and #formatted_offset, respectively, before passing to 
    # Time#strftime, so that zone information is correct
    def strftime(format)
      format = format.gsub('%Z', zone).gsub('%z', formatted_offset(false))
      time.strftime(format)
    end
  
    # Use the time in UTC for comparisons
    def <=>(other)
      utc <=> other
    end
    
    def between?(min, max)
      utc.between?(min, max)
    end
    
    def eql?(other)
      utc == other
    end
    
    # If wrapped #time is a DateTime, use DateTime#since instead of #+
    # Otherwise, just pass on to #method_missing
    def +(other)
      time.acts_like?(:date) ? method_missing(:since, other) : method_missing(:+, other)
    end
    
    # If a time-like object is passed in, compare it with #utc
    # Else if wrapped #time is a DateTime, use DateTime#ago instead of #-
    # Otherwise, just pass on to method missing
    def -(other)
      if other.acts_like?(:time)
        utc - other
      else
        time.acts_like?(:date) ? method_missing(:ago, other) : method_missing(:-, other)
      end
    end
    
    %w(asctime day hour min mon sec usec wday yday year).each do |name|
      define_method(name) do
        time.__send__(name)
      end
    end
    alias_method :ctime, :asctime
    alias_method :mday, :day
    alias_method :month, :mon
    
    %w(sunday? monday? tuesday? wednesday? thursday? friday? saturday?).each do |name|
      define_method(name) do
        time.__send__(name)
      end
    end unless RUBY_VERSION < '1.9'
    
    def to_a
      [time.sec, time.min, time.hour, time.day, time.mon, time.year, time.wday, time.yday, dst?, zone]
    end
    
    def to_f
      utc.to_f
    end    
    
    def to_i
      utc.to_i
    end
    alias_method :hash, :to_i
    alias_method :tv_sec, :to_i
  
    # A TimeWithZone acts like a Time, so just return self
    def to_time
      self
    end
    
    def to_datetime
      utc.to_datetime.new_offset(Rational(utc_offset, 86_400))
    end
    
    # so that self acts_like?(:time)
    def acts_like_time?
      true
    end
  
    # Say we're a Time to thwart type checking
    def is_a?(klass)
      klass == ::Time || super
    end
    alias_method :kind_of?, :is_a?
  
    # Neuter freeze because freezing can cause problems with lazy loading of attributes
    def freeze
      self
    end

    def marshal_dump
      [utc, time_zone.name, time]
    end
    
    def marshal_load(variables)
      initialize(variables[0], ::TimeZone[variables[1]], variables[2])
    end
  
    # Ensure proxy class responds to all methods that underlying time instance responds to
    def respond_to?(sym)
      # consistently respond false to acts_like?(:date), regardless of whether #time is a Time or DateTime
      return false if sym.to_s == 'acts_like_date?'
      super || time.respond_to?(sym)
    end
  
    # Send the missing method to time instance, and wrap result in a new TimeWithZone with the existing time_zone
    def method_missing(sym, *args, &block)
      result = utc.__send__(sym, *args, &block)
      result = result.in_time_zone(time_zone) if result.acts_like?(:time)
      result
    end
    
    private      
      def get_period_and_ensure_valid_local_time
        # we don't want a Time.local instance enforcing its own DST rules as well, 
        # so transfer time values to a utc constructor if necessary
        @time = transfer_time_values_to_utc_constructor(@time) unless @time.utc?
        begin
          @time_zone.period_for_local(@time)
        rescue ::TZInfo::PeriodNotFound
          # time is in the "spring forward" hour gap, so we're moving the time forward one hour and trying again
          @time += 1.hour
          retry
        end
      end
      
      def transfer_time_values_to_utc_constructor(time)
        ::Time.utc_time(time.year, time.month, time.day, time.hour, time.min, time.sec, time.respond_to?(:usec) ? time.usec : 0)
      end
    
      # Replicating logic from TZInfo::Timezone#utc_to_local because we want to cache the period in an instance variable for reuse
      def utc_to_local
        ::TZInfo::TimeOrDateTime.wrap(utc) {|utc| period.to_local(utc)}
      end
      
      # Replicating logic from TZInfo::Timezone#local_to_utc because we want to cache the period in an instance variable for reuse
      def local_to_utc
        ::TZInfo::TimeOrDateTime.wrap(time) {|time| period.to_utc(time)}
      end
  end
end
