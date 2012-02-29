class Step < ActiveRecord::Base
  COLORS = %w(#B8D0DD #DBBAE5)

  def color
    '#EEEEEE'
  end
  
  #has_many :next_links, :class_name => 'Link', :foreign_key => :from_id
  #has_many :children, :class_name => 'Step', :through => :next_links
  has_many :links  
  has_many :nexts, :through => :links
  #, :source => :step
  has_many :inverse_links, :class_name => "Link", :foreign_key => "next_id"  
  has_many :previouses, :through => :inverse_links, :source => :step  
  
  has_many :jobs
  has_many :actions
  
  def self.select_options
    descendants.map{ |c| c.to_s }.sort
  end

  def follow
    # Init
    puts "==== follow (#{self.id}) #{self.label}"

    # Run root step
    puts "  == running this step"
    self.run

    # Loop through next links and follow them
    puts "  == following (#{self.nexts.size}) child steps"
    self.nexts.each do |nextone|
      # Init
      puts "  == linked step (#{nextone.id}) #{nextone.label}"

      # Evaluate conditions if any

      # Recurse to this sub-step
      nextone.follow
    end

    # Finished
    puts "==== follow end (#{self.id}) #{follow.label}"
  end

  protected 

  def run
    puts "== Step.run ERROR: CANNOT RUN STEP BASE CLASS DIRECTLY"
  end
  
  def is_numeric?(s)
      !!Float(s) rescue false
  end
  
end