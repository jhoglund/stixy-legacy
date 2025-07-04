class  Priority < ActiveRecord::Base
 	belongs_to :priorable, :polymorphic => true

  # mapping arrays for enums
  PRIORITY_NAMES = %w{LOW MEDIUM HIGH}
  
  # priority values enum
  LOW, MEDIUM, HIGH = 0, 1, 2
  
end
