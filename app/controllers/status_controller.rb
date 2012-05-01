require "sys/cpu"
include Sys

class StatusController < ApplicationController
  
  def dashboard
    # Connect queue
    bs = Q.new

    # Prepare system
    @systems = System.order(:label)
    
    # Collect queued job IDs
    @queued_jobs_ids = bs.fetch_queued_jobs.map{ |j| j.ybody[:id] }
    
    # Prepare jobs
    @jobs_running = Job.locked.order('id DESC').all
    @jobs_failed = Job.failed.order('id DESC')
    @jobs_queued = Job.find(@queued_jobs_ids)
    #@jobs_queued = @jobs_failed

    # Prepare workers
    @workers_list = bs.list_workers
    @workers_stats = bs.stats
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

    render :partial => 'workers'
  end  

  def ajax_jobs
    # Connect queue
    bs = Q.new

    # Collect queued job IDs
    @queued_job_ids = bs.fetch_queued_jobs.map{|j| j.ybody[:id] }

    # Prepare jobs
    @jobs_running = Job.locked.order('id DESC').all
    @jobs_failed = Job.failed.order('id DESC')
    @jobs_queued = Job.find(@queued_jobs_ids)

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
  
  
end