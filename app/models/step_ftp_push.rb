require 'net/ftp'

class StepFtpPush < Step
  
  def paramdef
    {
    :local_path => { :description => "Local path of the file to upload", :format => :text, :lines => 2  },
    :remote_host => { :description => "", :format => :text, :lines => 1 },
    :remote_port => { :description => "", :format => :text, :lines => 1 },
    :remote_user => { :description => "", :format => :text, :lines => 1 },
    :remote_pass => { :description => "", :format => :text, :lines => 1 },
    :remote_dir => { :description => "*", :format => :text, :lines => 2 },
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
    local_path = self.pval(:local_path)
    remote_host = self.pval(:remote_host)
    remote_port = self.pval(:remote_port)
    remote_user = self.pval(:remote_user)
    remote_pass = self.pval(:remote_pass)
    remote_dir = self.pval(:remote_dir)
    
    # Check for run context
    log "StepFtpPush starting"
    
    # Check for locla path presence
    local_path_evaluated = current_job.evaluate(local_path)
    return 21, "source file not found (#{local_path}) > (#{local_path_evaluated})" unless File.exists? local_path_evaluated
    
    # Evaluate some fields
    evaluated_host = current_job.evaluate(remote_host)
    log "evaluated host: #{evaluated_host}"

    evaluated_remote_dir = current_job.evaluate(remote_dir)
    log "evaluated remote_dir: #{evaluated_remote_dir}"

    # Prepare FTP session
    log "preparing ftp session to [#{remote_user}@#{evaluated_host}:#{remote_port}/#{remote_dir}]"
    ftp = Net::FTP.new
    ftp.passive = true

    # Start FTP session
    begin

      log "connecting"
      ftp.connect(evaluated_host)

      log "logging in"
      ftp.login(remote_user, remote_pass)

      log "chdir to [#{evaluated_remote_dir}]"
      ftp.chdir evaluated_remote_dir unless evaluated_remote_dir.blank?
    
      # Uploading file
      log "uploading file [#{local_path_evaluated}]"
      ftp.putbinaryfile(local_path_evaluated, remotefile = File.basename(local_path_evaluated))
    
    rescue Errno::ECONNREFUSED
      msg = "ECONNREFUSED: connection refused"
      log msg
      return 31, msg
    
    rescue Net::FTPPermError
      msg = "Net::FTPPermError: invalid credentials"
      log msg
      return 32, msg
    
    end
    
    # Finished
    log "disconnecting"
    ftp.quit
    
    log "StepFtpPush ending"
    return 0, "uploaded file [#{remotefile}]"
  end
  
  def validate_params?
    return :local_path if self.pval(:local_path).blank?
    return :remote_host if self.pval(:remote_host).blank?
    return :remote_port unless is_numeric? self.pval(:remote_port)
    return :remote_user if self.pval(:remote_user).blank?
    return :remote_pass if self.pval(:remote_pass).blank?
    #return :remote_dir if self.pval(:remote_dir).blank?
    return false
  end
  
end
