#require 'open-uri'
#require 'net/http'
require 'rest_client'
require 'rexml/document'

class StepGeturl < Step

  def color
    '#C6B299'
  end
  
  def run(current_run, current_action)
    #url = params[:url]
    # Prepare connection
    #uri = URI(params)
    puts "        - getting #{self.params['url']}"
    resource = RestClient::Resource.new self.params['url'], :user => self.params['user'], :password => self.params['password']

    # Get the data
    body = resource.get
    puts "        - received (#{body.size}) bytes"
    
    # Parse the XML response
    xml_grab = params['grab']
    
    # Parse as XML only if GRAB is a hash
    if xml_grab.is_a? Hash
    
      # Parse XML data
      xml = REXML::Document.new(body)

      # Try to match every field
      fields = {}

      # Identify filters
      xml_grab.each do |variable, xpath|
        puts "        - grab (#{variable}) with (#{xpath})"
        match = REXML::XPath.first(xml, xpath)
      
        unless match.nil?
          #var = self.vars.find_or_create_by_name(variable, :value => match.to_s, :run => run, :action => action)
          var = self.vars.find_or_create_by_name_and_run_id(variable, current_run.id, :value => match.to_s, :action => current_action)
          puts "          matched (#{match}) to variable (v#{var.id})"
        end
      end
    
    end
    

    # Finished
    return 0, body[0, 511]
  end
  
  #private
  
  def validate_params?
    return 11 if (self.params['url'] =~ URI::regexp).nil?
    #return 12 if self.params['user'].blank?
    #return 13 if self.params['password'].blank?
    return false
  end
  
end
