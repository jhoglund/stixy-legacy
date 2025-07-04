class Group < ActiveRecord::Base
  acts_as_taggable
	belongs_to :groupable, :polymorphic => true
	has_many :members, :as => :membershipable
	has_many :logs, :as => :loggable
end
