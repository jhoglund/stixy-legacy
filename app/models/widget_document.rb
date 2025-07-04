class WidgetDocument < WidgetInstance
  has_many  :documents, :through => :library_documents_widget_instances, :dependent => :destroy
  has_many  :library_documents_widget_instances, :foreign_key => "widget_instance_id", :dependent => :destroy
  belongs_to :widget
  
  def initialize p=nil
    super(p)
    self.widget_id = 3
  end
  
  def self.get(board_id, status=Status::ACTIVE)
    find(:all, :conditions => "widget_name = 'WidgetDocument' and board_id = #{board_id} and status = #{status}", :include => [:widget, :documents, :library_documents_widget_instances])
  end  
  
  def file= param
    if(param[:document_id] && (param[:document_id]!="0"))
      self.library_documents_widget_instances(true).each{|w| w.destroy }
      self.library_documents_widget_instances.create!(:document => DocumentFile.find(param[:document_id]))
    end
  end
  alias :document= :file=
  
  def document
    documents.first
  end
  alias :file :document
  
  def instance_attributes *att
    super(*att)
  end
  
  def copy *args
    widget = clone
    widget.save!
    documents.each do |doc|
      cloned_document = doc.copy
      widget.library_documents_widget_instances.create(:widget_instance_id => widget.id, :library_document_id => cloned_document.id)
    end
    return widget
  end
  
  private

end
