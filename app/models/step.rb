#require "json/ext"
class Step < ActiveRecord::Base
  COLORS = %w(#FFF4E3 #B8D0DD #DBBAE5)

  has_many :vars, :dependent => :destroy
  
  serialize :params, JSON
  #before_save :json_serialize  
  #after_save  :json_deserialize
  #after_find  :init_params
  #after_create  :init_params
  after_initialize  :init_params
  
  attr_accessible :type, :label, :description, :params_yaml, :params_json

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
  
  
  # Steps where no link are pointing TO them
  #scope :roots, joins('LEFT OUTER JOIN links ON links.next_id = steps.id').where(:links => {:step_id => nil}).order(:id)
  scope :roots, where(:type => StepStart).order(:id)
  
  
  def self.select_options
    sublclasses.map{ |c| c.to_s }.sort
  end

  def run(current_run, current_action)
    puts "        - Step.run ERROR: CANNOT RUN STEP BASE CLASS DIRECTLY"
  end
  
  def validate_params?
    return !(self.params.is_a? Hash)
  end

  protected 

  def init_params    
    self.params = {} if self.params.nil? 
    #self.attributes[:params] = {} if self.attributes[:params].blank? 
  end

  def params_yaml    
    self.params.to_yaml
  end
  def params_json
    #self.params ||= {}
    JSON.pretty_generate(self.params)
  end
  def params_yaml=(text)    
    self.params = YAML::parse(text)
  end
  def params_json=(text)  
    parsed = JSON::parse(text) rescue nil
    if (parsed.nil?)
      errors.add :step, "malformed json data"  
    else
        self.params = parsed
    end
  end
  
  
  # 
  # def json_serialize    
  #   self.attributes[:params] = self.params.to_json
  # end
  # 
  # def json_deserialize
  #   self.attributes[:params] = {}.to_json
  #   self.params = JSON.parse(self.attributes[:params])
  # end

  def is_numeric?(s)
      !!Float(s) rescue false
  end
  
end