class Link < ActiveRecord::Base
  #has_one :from, :class_name => 'Step'
  #has_one :to, :class_name => :step
  belongs_to :step  
  belongs_to :next, :class_name => 'Step'  

  serialize :params, JSON
  after_initialize  :init_params
  
  attr_accessible :type, :label, :params_yaml, :params_json, :step_id, :next_id
  #, :params_yaml, :params_json
  
  scope :forks, where(:type => LinkFork)
  scope :noforks, where('type != "LinkFork"')

  scope :blocking, where(:type => ["LinkBlocker", "LinkFork"])
  scope :nonblocking, where('type NOT IN ("LinkBlocker", "LinkFork")')

  def color
    '#999999'
  end
  def penwidth
    1
  end

  def pretty_json
#return self.params.to_json
    self.params_json
  end

  protected

  def init_params    
    self.params = {} if self.params.nil? 
    #self.attributes[:params] = {} if self.attributes[:params].blank? 
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

end
