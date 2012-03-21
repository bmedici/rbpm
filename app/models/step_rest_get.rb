#require 'open-uri'
#require 'net/http'
require 'rest_client'
require 'rexml/document'

class StepRestGet < Step

  def paramdef
    {
    :remote => { :description => "Remote host address and credentials", :format => :json },
    :parse_xml => { :description => "Extract fields from XML response", :format => :json },
    :parse_json => { :description => "Extract fields from JSON response", :format => :json },
    }
  end

  def color
    '#B7E3C0'
  end
  
  def run(current_job, current_action)
    # Init
    remote = self.pval(:remote)
    parse_xml = self.pval(:parse_xml)
    parse_json = self.pval(:parse_json)

    # Prepare the resource
    # Prepare the resource
    puts "        - working with url (#{remote['url']})"
    resource = RestClient::Resource.new remote['url'], :user => remote['user'], :password => remote['password']

    # Get the data
    puts "        - getting #{remote['url']}"
    response = resource.get
    puts "        - received (#{response.size}) bytes"
    
    # Parse as XML only if response_filter_xml is a hash
    self.parse_xml(response, parse_xml, current_job, current_action)

    # Parse as XML only if response_filter_xml is a hash
    self.parse_json(response, parse_json, current_job, current_action)
    
    # Finished
    return 0, body[0, 511]
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
    return :remote unless self.pval(:remote).is_a? Hash
    return false
  end
  
end
