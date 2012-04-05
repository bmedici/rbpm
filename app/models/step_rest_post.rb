require 'rest_client'
require 'rexml/document'

class StepRestPost < Step
  
  def paramdef
    {
    :postvars => { :description => "POST variables ($var for job's variables)", :format => :json },
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
    log "StepRestPost starting"
    return 21, "depends on the run context to gather variables, no valid current_job given" if current_job.nil?
    
    # Gather variables as mentionned in the configuration
    log "post_variables: evaluating values from variables"
    post_variables = {}
    param_post_variables.each do |field_name, expression|
      post_variables[field_name] = current_job.evaluate(expression)
      #get_var(from_variable_name.to_s)
    end
    
    # FIXME: force "formats"
    #post_variables['formats'] = {'f2' => 'out-f2.mpg', 'f3' => 'out-f3.mp4'}

    # Prepare the resource
    log "working with url (#{remote['url']})"
    resource = RestClient::Resource.new remote['url'], :user => remote['user'], :password => remote['password'], :open_timeout => RESTCLIENT_OPEN_TIMEOUT, :timeout => RESTCLIENT_TIMEOUT

    # Posting query
    log "posting with values: #{post_variables.to_json}"
    begin
      response = resource.post post_variables
      
    rescue RestClient::ResourceNotFound
      msg = "RestClient::ResourceNotFound"
      log msg
      return 31, msg
      
    rescue RestClient::RequestTimeout
      msg = "RestClient::RequestTimeout, open timeout = #{RESTCLIENT_OPEN_TIMEOUT} seconds"
      log msg
      return 32, msg
      
    rescue RestClient => exception
      msg = "Restclient failed: #{exception.to_json}"
      log msg
      return 30, msg


    end
    # OK, continue
    log "received (#{response.size}) bytes"
    
    

    # Parse as XML only if response_filter_xml is a hash
    self.parse_xml(response, parse_xml, current_job, current_action)

    # Parse as XML only if response_filter_xml is a hash
    self.parse_json(response, parse_json, current_job, current_action)
    
    # Finished
    log "StepRestPost ending"
    return 0, response
  end
  
  def validate_params?
    return :postvars unless self.pval(:postvars).is_a? Hash
    return :remote unless self.pval(:remote).is_a? Hash
    return false
  end
  
end
