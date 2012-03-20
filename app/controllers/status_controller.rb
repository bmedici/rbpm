class StatusController < ApplicationController
  
  def workflow
    @root_steps = Step.roots.order('steps.id DESC')
  end  
  
  def editor
    @root_step = Step.roots.order('steps.id DESC').first
  end  
  
end
