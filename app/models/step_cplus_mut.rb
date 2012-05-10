require 'socket'

class StepCplusMut < Step
  
  def paramdef
    {
    #:vars => { :description => "Values (or variable references) fed into the request template", :format => :json },
    :base_posix => { :description => "Base of the POSIX path to be replaced by a local drive letter in Windows", :format => :text, :lines => 2 },
    :base_windows => { :description => "Local drive letter in Windows replacing the POSIX path", :format => :text, :lines => 2 },
    :source_file => { :description => "Source file to be encoded, POSIX format (use #source in the template)", :format => :text, :lines => 2 },
    :target_dir => { :description => "Target directory receiving output files (use #target in the template)", :format => :text, :lines => 2 },

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
    log "StepCplusMut start"
    #vars = self.pval(:vars)
    base_posix = self.pval(:base_posix)
    base_windows = self.pval(:base_windows)
    source_file = self.pval(:source_file)
    target_dir = self.pval(:target_dir)

    request_template = self.pval(:request_template)
    timeout = self.pval(:timeout).to_i
    host = self.pval(:host)
    port = self.pval(:port)
    
    # Evaluate vriables
    evaluated_posix = current_job.evaluate(base_posix)
    evaluated_windows = current_job.evaluate(base_windows)
    evaluated_source = current_job.evaluate(source_file)
    evaluated_target = current_job.evaluate(target_dir)

    # Compute windows paths
    windows_source = unix_path_to_windows(evaluated_source, evaluated_posix, evaluated_windows)
    windows_target = unix_path_to_windows(evaluated_target, evaluated_posix, evaluated_windows)
    log "source_file: (#{source_file}) > (#{evaluated_source}) > (#{windows_source})"
    log "target_dir: (#{target_dir}) > (#{evaluated_target}) > (#{windows_target})"


    # Prepare template
    request = request_template.clone

    # Build windows paths and set #source and #target into the template body
    request.gsub!('#source', windows_source)
    request.gsub!('#target', windows_target)
    
    # Replace job variables into the template body
    job_vars = current_job.get_vars
    job_vars.each do |name, value|
      pattern = "$#{name.to_s}"
      request.gsub!(pattern, value.to_s)
    end
    
    # Store the query for debugging purposes
    current_job.set_var(:debug_mut_request, request)
    
    
    # Begin transaction
    response = []
    begin
      # Connect to remote host
      log "connecting to [#{host}:#{port}]"
      s = TCPSocket.open(host, port)
      s.setsockopt(Socket::SOL_SOCKET, Socket::SO_RCVTIMEO, timeout)
    
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
    log "StepCplusMut end"
    return 0, response.join("\n")
  end
  
  def validate_params?
    return :base_posix if self.pval(:base_posix).blank?
    return :base_windows if self.pval(:base_windows).blank?
    return :source_file if self.pval(:source_file).blank?
    return :target_dir if self.pval(:target_dir).blank?

    return :request_template if self.pval(:request_template).blank?
    return :host if self.pval(:host).blank?
    return :port unless is_numeric? self.pval(:port)
    return false
  end
  
  protected
  
  def unix_path_to_windows(path, unix_path, local_drive)
    return path.gsub(/^#{unix_path}/, local_drive).gsub("/","\\").gsub("\\\\","\\")
  end
  
end