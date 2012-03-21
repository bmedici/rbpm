#require "json/ext"
class Step < ActiveRecord::Base
  COLORS = %w(#C6B299 #B8D0DD #DBBAE5)

  has_many :params, :dependent => :destroy
  has_many :vars, :dependent => :destroy
  has_many :links  
  has_many :nexts, :through => :links
  has_many :ancestor_links, :class_name => "Link", :foreign_key => "next_id"  
  has_many :ancestors, :through => :ancestor_links, :source => :step  
  has_many :jobs
  has_many :actions
  
  scope :roots, where(:type => StepStart)
  after_find  :init_missing_params!
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

  def self.select_options
    sublclasses.map{ |c| c.to_s }.sort
  end

  def run(current_job, current_action)
    puts "        - Step.run ERROR: CANNOT RUN STEP BASE CLASS DIRECTLY"
    raise StepFailedBaseClassCalled
  end
  
  def validate_params?
    return false
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
  
  def type_field
    self.type
  end
  def type_field=(type)
    self.type=type
  end

  def is_numeric?(s)
      !!Float(s) rescue false
  end
  
end