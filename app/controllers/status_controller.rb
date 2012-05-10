require "sys/cpu"
include Sys

class StatusController < ApplicationController
  
  def dashboard
    # Prepare system
    @systems = System.order(:label)

    # Prepare jobs, workers
    bs = Q.new
    self.prepare_jobs(bs)
    self.prepare_workers(bs)

    # Close connection to the queue and process layout
    bs.close
  end  
  
  def ajax_workers
    # Prepare workers
    bs = Q.new
    self.prepare_workers(bs)

    # Collect queued job IDs
    @queued_jobs_ids = bs.fetch_queued_jobs.map{ |j| j.ybody[:id] }

    # Close connection to the queue and process layout
    bs.close
    render :partial => 'workers'
  end  

  def ajax_jobs
    # Prepare jobs
    bs = Q.new
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
    # Collect queued job IDs in beanstalk
    @bs_jobs_ids = bs.fetch_queued_jobs_ids

    # Read jobs locked
    @jobs_locked = Job.locked.includes(:step).order('id DESC')

    # Read jobs failed
    jobs_failed = Job.failed.includes(:step).order('id DESC')
    @jobs_failed_count = jobs_failed.count
    @jobs_failed_limited = jobs_failed.limit(DASHBOARD_JOBS_LIMIT)
    
    # Read jobs queued
    jobs_queued = Job.failsafe_find_in(@bs_jobs_ids)
    @jobs_queued_count = jobs_queued.count
    @jobs_queued_limited = jobs_queued.limit(DASHBOARD_JOBS_LIMIT)

    # Find oprhan jobs
    @db_jobs_ids = jobs_queued.map(&:id) 
    @missing_in_db = @bs_jobs_ids - @db_jobs_ids
  end
  
  def prepare_workers(bs)
    @workers_list = bs.list_workers
    @workers_stats = bs.stats
    
    # Resolve jobs locked by one of these workers
    @workers_jobs = Job.where(:worker => @workers_list).group_by{ |j| j.worker }
  end
  
end