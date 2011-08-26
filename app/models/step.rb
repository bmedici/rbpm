class Step < ActiveRecord::Base
  #has_many :next_links, :class_name => 'Link', :foreign_key => :from_id
  #has_many :children, :class_name => 'Step', :through => :next_links
  has_many :links  
  has_many :nexts, :through => :links
  #, :source => :step
  has_many :inverse_links, :class_name => "Link", :foreign_key => "next_id"  
  has_many :previouses, :through => :inverse_links, :source => :step  
end
