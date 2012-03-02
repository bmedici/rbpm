class StatusController < ApplicationController
  
  def workflow
    @root_steps = Step.roots
    
  end  
  
end
