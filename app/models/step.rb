class Step < ActiveRecord::Base
  COLORS = %w(#FFF4E3 #B8D0DD #DBBAE5)
  
  attr_accessible :type, :label, :description, :params

  def color
    '#EEEEEE'
  end

  def shape
    :box
  end
  
  #has_many :next_links, :class_name => 'Link', :foreign_key => :from_id
  #has_many :children, :class_name => 'Step', :through => :next_links
  has_many :links  
  has_many :nexts, :through => :links
  has_many :inverse_links, :class_name => "Link", :foreign_key => "next_id"  
  has_many :previouses, :through => :inverse_links, :source => :step  
  has_many :jobs
  has_many :actions
  has_many :started_runs, :class_name => 'Run'
  
  def self.select_options
    sublclasses.map{ |c| c.to_s }.sort
  end

  def run
    puts "        - Step.run ERROR: CANNOT RUN STEP BASE CLASS DIRECTLY"
  end
  
  protected 

  def is_numeric?(s)
      !!Float(s) rescue false
  end
  
end