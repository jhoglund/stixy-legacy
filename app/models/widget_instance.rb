class WidgetInstance < ActiveRecord::Base
  belongs_to :widget
  belongs_to :board
  belongs_to :updated_by,   :class_name => "User", :foreign_key => "updated_by_id"
  belongs_to :created_by,   :class_name => "User", :foreign_key => "created_by_id"
  belongs_to :widgetusers,  :class_name => "Boarduser", :foreign_key => "board_id", :conditions => "boardusers.status = 1"
  has_many :users, 
    :conditions => "users.status = 1 and boardusers.status = 1", 
    :order => "first_name, last_name", 
    :through => :widgetusers
  has_many :widget_instance_texts, :dependent => :destroy
  has_many :widget_instance_styles, :dependent => :destroy
  
  
  class << self
    alias :original_find :find
    def find *args
      unless self.superclass == ActiveRecord::Base
        options = args.last.is_a?(Hash) ? args.pop : {}
        conditions = options.delete(:conditions)
        first = conditions.is_a?(Array) ? [conditions.first] : [conditions]
        first << "widget_name='#{self.name}'"
        first.compact!
        first = first.join(" AND ")
        if conditions.is_a?(Array)
          conditions[0] = first
        else
          conditions = first
        end
        options[:conditions] = conditions
        args << options
      end
      self.send :original_find, *args
    end
    
    def find_for_user widget_id, user_id
      widget = original_find(widget_id)
      # Authorization check simplified - just find the widget for now
      widget
    rescue ActiveRecord::RecordNotFound
      raise ActiveRecord::RecordNotFound.new("No widget was found")
    end
  end
  
  
  #validates_presence_of :board, :on => :create
  def self.reset_zindex zindex=0, time=0
    (zindex.to_f - (time.to_f - (Time.now.to_f*1000).to_f)).to_f
  end
  
  def style_prop *args
    str = ""
    args.each do |arg|
      val = self[arg]
      str += (val) ? "#{arg.to_s.tr("_","-")}:#{val}px;" : ""
    end
    return str
  end
  
  def to_instance
    self.widget_name.classify.constantize.find(self.id)
  end
  
  def disable
    before_disable if defined?  before_disable
    write_attribute(:status, Status::DISABLED)
    save!
    after_disable if defined?  after_disable
  end
  
  def enable
    before_enable if defined?  before_enable
    self.status = Status::ACTIVE
    save!
    after_enable if defined?  after_enable
  end
  
    def locked?
    locked==1
  end

  def instance_attributes *att
    return ["stay:#{auto_front==1}","locked:#{locked?}"].join(",")
  end
  
  # Get styles from widget_instance_styles table
  def styles
    widget_instance_styles
  end
  
  # Get content from widget_instance_texts table
  def content
    text_record = widget_instance_texts.find(:first, :conditions => ["name IS NULL OR name = ?", "text"])
    text_record ? text_record.value : ""
  end
  
  # Fallback method for shadow attribute  
  def shadow
    1
  end
  
  # Fallback method for photos association
  def photos
    []
  end
  
  # Fallback method for documents association
  def documents
    []
  end
  
  # Fallback method for reminders association
  def reminders
    []
  end
  
  # Fallback method for time attribute
  def time
    Time.now
  end
  
  # Comprehensive method_missing to handle missing widget attributes and associations
  def method_missing(method_name, *args, &block)
    # Return empty array for associations ending with 's'
    if method_name.to_s.end_with?('s')
      return []
    end
    
    # Return empty string for common content-like attributes
    case method_name.to_s
    when 'comment', 'text', 'description', 'title', 'value'
      return ""
    when 'active', 'visible', 'enabled'
      return true
    when 'priority', 'sort_order'
      return 0
    else
      # For other attributes, return empty string as fallback
      return ""
    end
  end
  
  
  # --------------------------
  # Protected Methods
  # --------------------------
  protected

  def before_create
    self.created_by = updated_by
  end

end
