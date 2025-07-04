class Board < ActiveRecord::Base
  class EmptyFilter < StandardError; end
  acts_as_taggable
  # --------------------------
  # Assosiations
  # --------------------------
  
	has_many :messages, :as => :messageable
  has_many :invites, :conditions => "invites.status = 2", :dependent => :destroy  # invitation mapping
  has_many :widget_instances, :order => "zindex", :dependent => :destroy # widget instances that has been placed on this board
  has_many :widget_types, :class_name => "WidgetInstance", :select => "distinct widget_name" # widget instances that has been placed on this board
  belongs_to :creator, :class_name => "User", :foreign_key => "created_by_id" # Creator mapping
  belongs_to :updater, :class_name => "User", :foreign_key => "updated_by_id" # Updater mapping
  has_and_belongs_to_many :keywords, :order => "tag" # keywords mapping
  has_many :boardusers, :conditions => "boardusers.status = 1", :dependent => :destroy
  has_many :users, 
    :conditions => "users.status = 1", 
    :order => "first_name, last_name", 
    :through => :boardusers, :include => "personal_image" # shared by users mapping

  cattr_accessor :is_new
  attr_accessor :cashed_widgets, :tagged
  
  EXAMPLE_BOARDS_ID = %w{272 394 395 396}
  
  def save_scroll attributes={}
    self.class.record_timestamps = false
    self.update_attributes(attributes)
    self.class.record_timestamps = true
  end
  
  def created_by
    self.creator || User.new(:first_name => "N/A")
  end
  
  def updated_by
    self.updater || User.new(:first_name => "N/A")
  end
  
  def created_by= user
    self.creator = user
  end
  
  def updated_by= user
    self.updater = user
  end
  
  def self.is_example? id
    EXAMPLE_BOARDS_ID.include? id
  end    
  
  def widgets status=Status::ACTIVE
    return self.cashed_widgets if self.cashed_widgets
    cw=[]
    widget_types.each do |t|
      cw.concat(Object.const_get(t.widget_name).get(id,status))
    end
    self.cashed_widgets = cw.sort{|a,b| a.zindex.to_i <=> b.zindex.to_i}
    return self.cashed_widgets
  end
  
  # --------------------------
  # Class Methods
  # --------------------------
  
  def self.find_for_list limit = nil, offset = nil, order = "boards.updated_on", filters=nil
    find(:all, { :limit => limit, :offset => offset, :order => order }.merge(filter_conditions(filters)))
  end
  
  def self.count_for_list(filters=nil)
    count(filter_conditions(filters))
  end
    
  # --------------------------
  # Public Methods
  # --------------------------
  
  def display_name
    return title unless title.empty?
    untitle_str = "Untitled "
    untitle_str << "(##{id})" unless id.nil?
    return untitle_str
  end
  
  def document_title
    return "Stixy: " << display_name
  end
  
  
  def editable?
    editable.to_i == 1
  end
  
  def visible?
    visible.to_i == 1
  end
  
  def protected?
    pwd_protected.to_i == 1
  end
  
  # gets human readable status of this record ( disabled or active)
  def status_name
    Status::STATUS_NAMES[self.status]
  end
  
  # returns true if this record is active
  def active?
    self.status == Status::ACTIVE
  end
  
  def shared_with current_user=User.new
    users.select{|u| u != current_user}
  end
  
  def invited_users
    invites.collect{|i| i.accepted_user}.compact
  end
  
   # need a setter to if using 'keywords_str' as forma parameter.
   # does nothing but majes active record happy. 
   # alternative is to chomp param['keywords_str'] before saving
   def keywords_str=(val)
   end

   # same as above
   def contact
   end
  
  
  def copy(users=true)
    board = clone
    board.updated_on = Time.now
    board.created_on = board.updated_on
    widgets.each do |widget|
      new_widget = widget.copy
      new_widget.board = board
      new_widget.save
    end
    keywords.each do |keyword|
      board.keywords << keyword
    end
    board.save
    boardusers.each do |user|
      u = user.clone
      u.board_id = board.id
      u.save!
    end unless users == false
    return board
  end 

  protected
    
  # FIX for Rails 2.1 that doesn't allow mysql db taxt/blob columns to not allow null and have empty string as default
  # http://pennysmalls.com/2008/06/03/rails-210-breakage/ bullet 4
  def before_save
    self.description = "" if self.description.nil?
  end
  
  
  def self.filter_conditions filters=nil
    return {} if filters.nil? or filters.empty?
    tag_ids = find_by_sql("SELECT taggable_id FROM taggings, tags " +
      "WHERE tags.id=taggings.tag_id AND taggings.taggable_type = '#{acts_as_taggable_options[:taggable_type]}' " +
      "AND #{sanitize_sql_hash_for_conditions('tags.name' => filters)} " + 
      "GROUP BY taggable_id HAVING count(tags.id) >= #{filters.length}").collect{|r| r.taggable_id.to_i }
    raise EmptyFilter if tag_ids.empty?
    tagged_board_ids = (find(:all, :select => "boards.id").collect{|r| r.id } & tag_ids).join(",")
    raise EmptyFilter if tagged_board_ids.empty?
    {:conditions => "boards.id in (#{tagged_board_ids})"} 
  end

end
