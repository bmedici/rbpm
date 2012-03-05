require 'rest_client'
require 'rexml/document'

class StepHttpPost < Step

  def color
    '#B7E3C0'
  end
  
  def shape
    :note
  end
  
  def run(current_run, current_action)
    # Check for run context
    puts "        - StepWatchfolder starting"
    return 21, "depends on the run context to gather variables, no valid current_run given" if current_run.nil?
    
    # Gather variables as mentionned in the configuration
    param_post_variables = params['post_variables']
    if param_post_variables.is_a? Hash
      puts "        - post_variables set: preparing post valued from variables "
      post_variables = {}
      param_post_variables.each do |field_name, from_variable_name|
        post_variables[field_name] = current_run.get_var(from_variable_name.to_s)
      end
    end

    # Prepare the resource
    puts "        - working with url (#{self.params['url']})"
    resource = RestClient::Resource.new self.params['url'], :user => self.params['user'], :password => self.params['password']

    # Posting query
    puts "        - posting with values (#{post_variables.to_json})"
    response = resource.post post_variables
    puts "        - received (#{response.size}) bytes"

    # Parse as XML only if grab_with_xpath is a hash
    param_grab_with_xpath = params['grab_with_xpath']
    if param_grab_with_xpath.is_a? Hash
      puts "        - grab_with_xpath set: parsing xml data to grab new variables"
      fields = {}
    
      # Parse XML data
      xml = REXML::Document.new(response)

      # Try to match every field
      param_grab_with_xpath.each do |variable, xpath|
        puts "        - grab (#{variable}) with (#{xpath})"
        match = REXML::XPath.first(xml, xpath)
      
        unless match.nil?
          #var = self.vars.find_or_create_by_name(variable, :value => match.to_s, :run => run, :action => action)
          current_run.set_var(variable, match.to_s, self, current_action)
          #var = self.vars.find_or_create_by_name_and_run_id(variable, current_run.id, :value => match.to_s, :action => current_action)
          puts "          matched (#{match})"
        end
      end
    
    end
    

    # Finished
    puts "        - StepHttpPost ending"
    return 0, response
  end
  
  #private
  
  def validate_params?
    return 11 if (self.params['url'] =~ URI::regexp).nil?
    #return 12 if self.params['user'].blank?
    #return 13 if self.params['password'].blank?
    return false
  end
  
end
