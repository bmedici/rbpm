require 'rest_client'
require 'rexml/document'

class StepRest < Step
  
  def paramdef
    {
    :postvars => { :description => "POST variables ($var for job's variables)", :format => :json },
    :parse_xml => { :description => "Extract fields from XML response", :format => :json },
    :parse_json => { :description => "Extract fields from JSON response", :format => :json },
    :method => { :description => "HTTP method to use (currently: get, post)", :format => :list, :list => [:get, :post], :lines => 1 },

    :url => { :description => "Remote URL to query", :format => :text, :lines => 3  },
    :user => { :description => "User to authenticate", :format => :text, :lines => 1  },
    :pass => { :description => "Password for this user", :format => :text, :lines => 1  },
    :open_timeout => { :description => "Seconds to wait to establish the connexion", :format => :text, :lines => 1  },
    :req_timeout => { :description => "Seconds to wait for the complete transaction to complete", :format => :text, :lines => 1  },

    #:remote => { :description => "Remote host address and credentials", :format => :json },
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
    parse_xml = self.pval(:parse_xml)
    parse_json = self.pval(:parse_json)
    param_url = self.pval(:url)
    param_user = self.pval(:user)
    param_pass = self.pval(:pass)
    open_timeout = self.pval(:open_timeout).to_i
    req_timeout = self.pval(:req_timeout).to_i
    method = self.pval(:method).to_s

    # Check for run context
    log "StepRestPost starting"
    return 21, "depends on the run context to gather variables, no valid current_job given" if current_job.nil?

    # Initialize defaults
    open_timeout = RESTCLIENT_OPEN_TIMEOUT if open_timeout.zero?
    req_timeout = RESTCLIENT_REQ_TIMEOUT if req_timeout.zero?
    
    # Evaluate post variables when needed
    post_variables = {}

    case method
    when 'post'
    when 'put'
      # Check that we do have params
      return 22, "we have to post variables, but 'postvars' is not a hash" unless (param_post_variables.is_a? Hash)

      # Evaluate variables
      param_post_variables.each do |field_name, expression|
        post_variables[field_name] = current_job.evaluate(expression)
      end
      log "evaluated post_variables: #{post_variables.to_json}"
    end

    # Evaluate URL
    final_url = current_job.evaluate(param_url)
    log "evaluated final_url: #{final_url}"
    
    # Preparing RestClient resource
    log "creating connection, open_timeout: #{open_timeout}, req_timeout: #{req_timeout}"
    resource = RestClient::Resource.new final_url, :user => param_user, :password => param_pass, :open_timeout => open_timeout, :timeout => req_timeout

    # Posting query
    begin
      
      case method
      when 'get'
        log "starting GET request"
        response = resource.get
      when 'post'
        log "starting POST request"
        response = resource.post post_variables
      else
        return 39, "method not implemented (#{method})"
      end
      log "request ok"
      
    rescue RestClient::ResourceNotFound
      msg = "RestClient::ResourceNotFound"
      log msg
      return 31, msg
      
    rescue RestClient::RequestTimeout
      msg = "RestClient::RequestTimeout, open timeout = #{open_timeout} seconds"
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
    #return :postvars unless self.pval(:postvars).is_a? Hash
    #return :remote unless self.pval(:remote).is_a? Hash
    return :method if self.pval(:method).blank?
    return :url if self.pval(:url).blank?
    return :user if self.pval(:user).blank?
    return :pass if self.pval(:pass).blank?
    return false
  end
  
end