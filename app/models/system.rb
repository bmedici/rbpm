class System < ActiveRecord::Base
  
  #scope recently_updated_first, order('updated_at - NOW')
  
  def update_status!
    puts "querying #{self.monitor_url}"
    return if self.monitor_url.blank?
    
    # Return cached data is updated less dans XXX seconds ago
    data_age = Time.now - self.updated_at
    
    if data_age < MONITOR_MIN_UPDATE_PERIOD.to_i
      status = self.status
      status[:cached] = true
      return status 
    end
    #@system.update_status!
    

    # Query for data
    resource = RestClient::Resource.new self.monitor_url
    
    begin
      response = resource.get
    rescue RestClient::ResourceNotFound => exception
      return {:failed => true}
    end
    puts " - received (#{response.size}) bytes"
    
    # Parse JSON response
    self.update_attributes(:status_json => response)
    #self.status_json = response
    return self.status
  end
  
  def status
    # Parse JSON response
    return JSON::parse(self.status_json) rescue {}
  end
  
  def status_pretty
    return JSON.pretty_generate(self.status)
  end
  
  def query2
    return {
      "timestamp" => Time.now,
      "cpu_count" => "4",
      "loadavg" => 1.07275390625,
      "cpu_desc" => "Intel x86_64",
      :dummy => true
    }
  end

  def load_percent
    data = self.status
    
    cpu_count = data['cpu_count'].to_i
    return nil if cpu_count.zero?
    percent = 100*(data['loadavg'].to_f / cpu_count)
    return "#{percent.round}%"
  end
    
end
