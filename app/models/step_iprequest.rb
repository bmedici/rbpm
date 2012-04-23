require 'socket'

class StepIprequest < Step
  
  def paramdef
    {
    #:vars => { :description => "Values (or variable references) fed into the request template", :format => :json },
    :request_template => { :description => "Body of the request template", :format => :xml, :lines => 25 },
    :timeout => { :description => "Maximum seconds to wait for the synchronous process to finish", :format => :text, :lines => 1  },
    :host => { :description => "TCP hostname to connect", :format => :text, :lines => 1  },
    :port => { :description => "TCP port to connect", :format => :text, :lines => 1  },
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
    log "StepIprequest start"
    #vars = self.pval(:vars)
    request_template = self.pval(:request_template)
    timeout = self.pval(:timeout)
    host = self.pval(:host)
    port = self.pval(:port)
    
    # Template path
    #template_path = File.join(Rails.root, 'app', 'views', "iprequest_#{template_name}.xml")
    
    # Replace values into the template body
    #log "posting with values: #{post_variables.to_json}"
    request = request_template
    
    job_vars = current_job.get_vars_hash
    job_vars.each do |name, value|
    #self.vars.each do |name, value|
      pattern = "$#{name.to_s}"
      #real_value = current_job.evaluate(value)
      request.gsub!(pattern, value.to_s)
    end

    response = []
    begin
      # Connect to remote host
      s = TCPSocket.open(host, port)
    
      # Send the request + empty line to terminate
      s.puts(request)
      s.puts("")
    
      # Wait for the response
      while line = s.gets
        response << line.strip!
      end

    rescue Errno::ECONNREFUSED
      msg = "ECONNREFUSED: connection refused by remote host"
      log msg
      return 31, msg

    rescue Errno::ECONNRESET
      msg = "ECONNRESET: connection closed by remote host"
      log msg
      return 32, msg

    end
    
    # Then close the socket if it's not already closed
   # s.close

    # Finalize
    log "StepIprequest end"
    return 0, response.join("\n")
    
  end
  
  def validate_params?
    #return :vars unless self.pval(:vars).is_a? Hash
    #return :media_title if self.pval(:media_title).blank?
    return :request_template if self.pval(:request_template).blank?
    #return :timeout unless is_numeric? self.pval(:timeout)
    return :host if self.pval(:host).blank?
    return :port unless is_numeric? self.pval(:port)
    return false
  end
  
end