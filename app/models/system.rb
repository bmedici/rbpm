class System < ActiveRecord::Base
  
  def query
    puts "querying #{self.monitor_url}"
    return if self.monitor_url.blank?

    # Query for data
    resource = RestClient::Resource.new self.monitor_url
    
    begin
      response = resource.get
    rescue RestClient::ResourceNotFound => exception
      return {:failed => true}
    end
    puts " - received (#{response.size}) bytes"
    
    # Parse JSON response
    return JSON::parse(response)
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

  def extract_load_percent(data)
    cpu_count = data['cpu_count'].to_i
    return nil if cpu_count.zero?
    percent = 100*(data['loadavg'].to_f / cpu_count)
    return "#{percent.round}%"
  end
    
end
