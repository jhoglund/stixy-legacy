class BoardFilter < ActiveRecord::Base
  belongs_to :user
  
  def self.set filters
    clear_filters
    add filters
  end
  
  def self.add filters
    a=[]
    filters.each do |f|
      a.push(create(:filter => f))
    end
    return a
  end
  
  def self.remove filters 
    a=[]
    filters.each do |f|
      if k = find_by_filter(f)
        a.push(k.destroy)
      end
    end
    return a
  end
  
  def self.filters
    find(:all, :order => "id asc").collect{|f| f.filter }
  end
  
  def self.filter_list
    filters.join(", ")
  end
  
  def self.filter_list_as_text
    filters.collect{|w| '<q>' << w << '</q>' }.join(", ").sub(/,(?!.*,)/," and")
  end
  
  def self.get_names
    find(:all, :select => "filter").collect{|f| f.filter }
  end
  
  def self.clear_filters
    destroy_all
    return nil
  end
  
    
end