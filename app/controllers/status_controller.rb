require "sys/cpu"
include Sys

class StatusController < ApplicationController
  
  def dashboard
    # Prepare system
    @systems = System.order(:label)

    # Connect queue
    bs = Q.new
    
    # Prepare jobs
    self.prepare_jobs(bs)
    #@jobs_queued = @jobs_failed

    # Prepare workers
    @workers_list = bs.list_workers
    @workers_stats = bs.stats

    # Close connection to the queue and process layout
    bs.close
  end  
  
  def ajax_workers
    # Connect queue
    bs = Q.new

    # Prepare workers
    @workers_list = bs.list_workers
    @workers_stats = bs.stats

    # Collect queued job IDs
    #@queued_jobs = bs.fetch_queued_jobs.map{|j| "j#{j.ybody[:id]}" }
    @queued_jobs_ids = bs.fetch_queued_jobs.map{ |j| j.ybody[:id] }

    # Close connection to the queue and process layout
    bs.close
    render :partial => 'workers'
  end  

  def ajax_jobs
    # Connect queue
    bs = Q.new
    
    # Prepare jobs
    self.prepare_jobs(bs)

    # Close connection to the queue and process layout
    bs.close
    render :partial => 'jobs'
  end  

  def ajax_system
    @system = System.find(params[:id])
    @system.update_status!
    render :partial => 'system', :locals => {:system => @system}
  end  
  
  def monitor
    Facter.loadfacts  
    cpu_type = Facter.processor0 rescue '' + Facter.sp_cpu_type rescue ''
    
    # Build data response
    @json = {
      :hostname => `hostname`.chomp,
      :timestamp => Time.now.to_f,
      :loadavg => CPU.load_avg.first,
      :ipaddress => Facter.ipaddress,
      :uptime => Facter.uptime,
      :os => "#{Facter.operatingsystem} #{Facter.operatingsystemrelease}",
      :cpu_type => cpu_type,
      :architecture => "#{Facter.architecture} #{Facter.virtual}",
      :cpu_count => Facter.processorcount
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
    @root_steps = Step.roots.includes(:links => :next).order('steps.id DESC')
  end  
  
  def editor
    @root_step = Step.roots.order('steps.id DESC').first
  end  
  
  protected
  
  def prepare_jobs(bs)
    # Simple queries
    @jobs_running = Job.locked.order('id DESC').all
    @jobs_failed = Job.failed.order('id DESC')
    #@jobs_runnable = Job.runnable(@queued_jobs_ids)
    #@db_jobs_ids = @jobs_runnable.map(&:id) 

    # Collect queued job IDs in beanstalk
    @bs_jobs_ids = bs.fetch_queued_jobs_ids


    @jobs_queued = Job.failsafe_find_in(@bs_jobs_ids)


    # Find oprhan jobs
    @db_jobs_ids = @jobs_queued.map(&:id) 
    @missing_in_db = @bs_jobs_ids - @db_jobs_ids
    #@missing_in_bs = @db_jobs_ids - @bs_jobs_ids
    #@missing_in_db = @queued_jobs_ids
  end
  
end