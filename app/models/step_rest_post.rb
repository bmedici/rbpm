require 'rest_client'
require 'rexml/document'

class StepRestPost < Step
  
  def paramdef
    {
    :postvars => { :description => "POST variables", :format => :json },
    :remote => { :description => "Remote host address and credentials", :format => :json },
    :parse_xml => { :description => "Extract fields from XML response", :format => :json },
    :parse_json => { :description => "Extract fields from JSON response", :format => :json },
    }
  end

  def color
    '#B7E3C0'
  end
  
  def shape
    :note
  end
  
  def run(current_job, current_action)
    # Init
    param_post_variables = self.pval(:postvars)
    remote = self.pval(:remote)
    parse_xml = self.pval(:parse_xml)
    parse_json = self.pval(:parse_json)
    
    # Check for run context
    puts "        - StepWatchfolder starting"
    return 21, "depends on the run context to gather variables, no valid current_job given" if current_job.nil?
    
    # Gather variables as mentionned in the configuration
    puts "        - post_variables set: preparing post valued from variables "
    post_variables = {}
    param_post_variables.each do |field_name, from_variable_name|
      post_variables[field_name] = current_job.get_var(from_variable_name.to_s)
    end

    # Prepare the resource
    puts "        - working with url (#{remote['url']})"
    resource = RestClient::Resource.new remote['url'], :user => remote['user'], :password => remote['password']

    # Posting query
    puts "        - posting with values (#{post_variables.to_json})"
    response = resource.post post_variables
    puts "        - received (#{response.size}) bytes"

    # Parse as XML only if response_filter_xml is a hash
    self.parse_xml(response, parse_xml, current_job, current_action)

    # Parse as XML only if response_filter_xml is a hash
    self.parse_json(response, parse_json, current_job, current_action)
    
    # Finished
    puts "        - StepHttpPost ending"
    return 0, response
  end
  
  def parse_xml(data, filters, current_job, current_action)
    return unless filters.is_a? Hash

    puts "        - parse_xml: parsing xml data to grab variables"
    xml = REXML::Document.new(data) rescue nil
    return if xml.nil?
    
    filters.each do |variable, xpath|
      puts "        - grab (#{variable}) with (#{xpath})"
      match = REXML::XPath.first(xml, xpath)
      unless match.nil?
        current_job.set_var(variable, match.to_s, self, current_action)
        puts "          matched (#{match})"
      end
    end
  end

  def parse_json(data, mapping, current_job, current_action)
    return unless mapping.is_a? Hash
    
    puts "        - parse_json: parsing json data to grab variables"
    json = JSON::parse(response) rescue nil
    return if json.nil?

    mapping.each do |variable, json_field|
      puts "        - grab (#{variable}) from (#{json_field})"
      match = json[json_field]
      unless match.nil?
        current_job.set_var(variable, match.to_s, self, current_action)
        puts "          matched (#{match})"
      end
    end
  end
  
  def validate_params?
    return 11 unless self.pval(:postvars).is_a? Hash
    return 12 unless self.pval(:remote).is_a? Hash
    return false
  end
  
end
