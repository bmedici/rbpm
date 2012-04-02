#require "json/ext"
class Step < ActiveRecord::Base
  COLORS = %w(#C6B299 #B8D0DD #DBBAE5)

  has_many :params, :dependent => :destroy, :order=>"name ASC"
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
  
  @logger = nil
  @prefix = ""
 
  def color
    #'#000000'
  end

  def shape
    :box
  end
  
  def paramdef
    {}
  end
  
  def log_to(logger, prefix)
    @logger = logger
    @prefix = prefix
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
  
  def log(msg="")
    @logger.info "#{@prefix} #{msg}" unless @logger.nil?
  end
  
  def type_field
    self.type
  end
  def type_field=(type)
    self.type=type
  end

  def is_numeric?(s)
      !!Float(s) rescue false
  end
  
  
  def parse_xml(data, filters, current_job, current_action)
    return unless filters.is_a? Hash

    log "parse_xml: parsing xml data to grab variables"
    xml = REXML::Document.new(data) rescue nil
    return if xml.nil?
    
    filters.each do |variable, xpath|
      log " - grab (#{variable}) with (#{xpath})"
      match = REXML::XPath.first(xml, xpath)
      unless match.nil?
        current_job.set_var(variable, match.to_s, self, current_action)
        log "   matched (#{match})"
      end
    end
  end

  def parse_json(data, mapping, current_job, current_action)
    return unless mapping.is_a? Hash
    
    log "parse_json: parsing json data to grab variables"
    json = JSON::parse(response) rescue nil
    return if json.nil?

    mapping.each do |variable, json_field|
      log " - grab (#{variable}) from (#{json_field})"
      match = json[json_field]
      unless match.nil?
        current_job.set_var(variable, match.to_s, self, current_action)
        log "   matched (#{match})"
      end
    end
  end
  
end