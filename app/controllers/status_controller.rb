require "sys/cpu"
include Sys

class StatusController < ApplicationController
  
  def dashboard
    @jobs_running = Job.locked.order('id DESC').all
    @jobs_runnable = Job.runnable.order('id DESC')
    @jobs_failed = Job.failed.order('id DESC')
    @systems = System.all
    
    @workers = Worker.all
  end  
  
  def monitor
    # Build data response
    @json = {
      :timestamp => Time.now.to_f,
      :loadavg => CPU.load_avg.first,
      :cpu_desc => "#{CPU.model} #{CPU.architecture}"  ,
      :cpu_count => CPU.num_cpu.to_s,
      :timestamp => Time.now.to_f
    }

    # Send reply
    respond_to do |format|
      format.html
      format.json {
        render :json => @json
        }
    end
  end  
  
  def workflows
    @root_steps = Step.roots.order('steps.id DESC')
  end  
  
  def editor
    @root_step = Step.roots.order('steps.id DESC').first
  end  
  
end
