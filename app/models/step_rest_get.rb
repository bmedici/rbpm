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
    log "working with url (#{remote['url']})"
    resource = RestClient::Resource.new remote['url'], :user => remote['user'], :password => remote['password']

    # Get the data
    log "getting #{remote['url']}"
    response = resource.get
    log "received (#{response.size}) bytes"
    
    # Parse as XML only if response_filter_xml is a hash
    self.parse_xml(response, parse_xml, current_job, current_action)

    # Parse as XML only if response_filter_xml is a hash
    self.parse_json(response, parse_json, current_job, current_action)
    
    # Finished
    return 0, body[0, 511]
  end

  def validate_params?
    return :remote unless self.pval(:remote).is_a? Hash
    return false
  end
  
end
