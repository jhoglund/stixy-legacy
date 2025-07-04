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
      widget = find(widget_id)
      Boarduser.find_by_board_id_and_user_id(widget.board_id, user_id)
      widget
    rescue
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
    self.status = Status::DISABLED
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
  
  
  # --------------------------
  # Protected Methods
  # --------------------------
  protected

  def before_create
    self.created_by = updated_by
  end

end
