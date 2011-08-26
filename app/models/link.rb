class Link < ActiveRecord::Base
  #has_one :from, :class_name => 'Step'
  #has_one :to, :class_name => :step
  belongs_to :step  
  belongs_to :next, :class_name => 'Step'  
end
