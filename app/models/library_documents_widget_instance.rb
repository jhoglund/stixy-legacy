class LibraryDocumentsWidgetInstance < ActiveRecord::Base
  belongs_to :widget_instance
  belongs_to :document, :class_name => "DocumentFile", :foreign_key => "library_document_id"
end