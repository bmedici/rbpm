#require "json/ext"
class Step < ActiveRecord::Base
  COLORS = %w(#C6B299 #B8D0DD #DBBAE5)

  has_many :params, :dependent => :destroy
  has_many :vars, :dependent => :destroy
  #has_many :attributes, :class_name => 'Attribute', :primary_key => 'type', :foreign_key => 'type'
  
  #serialize :params, JSON
  after_find  :init_missing_params!
  
  #attr_accessible :type, :label, :descriptionn, :params
  accepts_nested_attributes_for :params, :allow_destroy => true
  
 
  def color
    #'#000000'
  end

  def shape
    :box
  end
  
  def paramdef
    {}
  end
  
  def pval(name, formatted = nil)
    # Read the param
    p = self.params.find_by_name(name.to_s)
    return nil if p.nil?
    
    # If param is a JSON hash, parse it
    param_format = self.pdef(name)[:format]
    case param_format
    when :ruby
    when :yaml
      parsed = YAML::parse(p.value) rescue nil
      return parsed
    when :json
      parsed = JSON::parse(p.value) rescue nil
      if formatted
        return JSON.pretty_generate(parsed)
      else
        return parsed
      end
    else
      return p.value
    end
    
  end
  

  def pdef(name)
    return self.paramdef[name.to_sym]
  end
  
  #has_many :next_links, :class_name => 'Link', :foreign_key => :from_id
  #has_many :children, :class_name => 'Step', :through => :next_links
  has_many :links  
  has_many :nexts, :through => :links
  has_many :ancestor_links, :class_name => "Link", :foreign_key => "next_id"  
  has_many :ancestors, :through => :ancestor_links, :source => :step  
  has_many :jobs
  has_many :actions
  
  
  # Steps where no link are pointing TO them
  #scope :roots, joins('LEFT OUTER JOIN links ON links.next_id = steps.id').where(:links => {:step_id => nil}).order(:id)
  scope :roots, where(:type => StepStart)
  
  def self.select_options
    sublclasses.map{ |c| c.to_s }.sort
  end

  def run(current_job, current_action)
    puts "        - Step.run ERROR: CANNOT RUN STEP BASE CLASS DIRECTLY"
  end
  
  def validate_params?
    return !(self.params.is_a? Hash)
  end

  def pretty_json
    self.params_json
  end
  
  
  def init_missing_params!
    missing_params = self.paramdef.keys - self.params.map { |p| p.name.to_sym }
    missing_params.each do |param_name|
      self.params.create(:name => param_name, :value => '')
    end
  end

  protected 

  def params_yaml    
    self.params.to_yaml
  end
  def params_json
    #self.params ||= {}
    JSON.pretty_generate(self.params_old)
  end
  def params_yaml=(text)    
    # self.params = YAML::parse(text)
  end
  def params_json=(text)  
    # parsed = JSON::parse(text) rescue nil
    # if (parsed.nil?)
    #   errors.add :step, "malformed json data"  
    # else
    #     self.params = parsed
    # end
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