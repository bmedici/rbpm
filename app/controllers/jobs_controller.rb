class JobsController < ApplicationController
  # GET /jobs
  # GET /jobs.json
  def index
    #@jobs = Job.order('id DESC').includes(:actions)
    @jobs = Job.includes(:step).order('id DESC')

    # Fetch real beanstalk queued IDs
    bs = Q.new
    @bs_jobs_ids = bs.fetch_queued_jobs_ids

    # Parse db jobs with bs job status
    @bs_job_status = {}
    begin
      @jobs.all.each do |job|
        logger.info "job (#{job.id})"
        @bs_job_status[job.id] = bs.job_stats(job.bsid)
      end
    rescue Beanstalk::NotFoundError
    end

    # Close connection to bs
    bs.close

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @jobs }
    end
  end

  # GET /jobs/1
  # GET /jobs/1.json
  def show
    @job = Job.find(params[:id])

    @all_actions = @job.actions.order('actions.id ASC')
    @vars = @job.vars.order(:name)
    @running_actions = @job.actions.order('actions.id ASC').where('completed_at IS NULL').order(:id)

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @job }
    end
  end

  def edit
    @job = Job.find(params[:id])
  end

  def push
    @job = Job.new()
    @job.creator = "admin.push"
    @job.step_id = params[:id]

    respond_to do |format|
      if @job.save

        # begin
        #   @job.push_to_beanstalk("jobs#push")
        # rescue Beanstalk::NotConnected
        #    redirect_to workflows_path, :notice => 'Could not connect to beanstalk server'
        #    return
        # end

        # Push this job onto the queue, and update job's bsid
        bs = Q.new
        bsid = bs.push_job(@job, JOB_PRIORITY_PUSHED)
        bs.close
        @job.update_attributes(:bsid => bsid)

        #format.html { redirect_to jobs_path, :notice => 'Job was successfully created.' }
        format.html { redirect_to @job, :notice => 'Job was successfully created.' }
        format.json { render :json => @job, :status => :created, :location => @job }
      else
        format.html { render :action => "new" }
        format.json { render :json => @job.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @job = Job.find(params[:id])

    respond_to do |format|
      if @job.update_attributes(params[:Job])
        format.html { redirect_to @job, :notice => 'Job was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @job.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /jobs/1
  # DELETE /jobs/1.json
  def destroy
    @job = Job.find(params[:id])
    
    # Remove from BS
    bs = Q.new
    bs.pop_job(@job)
    bs.close
    
    # Remove from database
    @job.destroy

    respond_to do |format|
      format.html { redirect_to jobs_url }
      format.json { head :ok }
    end
  end
  
  def reset
    # Reset data for this job
    @job = Job.find(params[:id])
    @job.reset!

    # Push this job onto the queue, and update job's bsid
    bs = Q.new
    bsid = bs.push_job(@job, 50)
    @job.update_attributes(:bsid => bsid)

    #redirect_to jobs_path, :notice => 'Job was successfully reset'
    redirect_to job_path(@job), :notice => 'Job was successfully reset'
  end
  
  def cleanup_successful
    job_ids = Job.successful.map(&:id)
    
    # Batch-delete their vars and actions
    Var.delete_all(:job_id => job_ids)
    Action.delete_all(:job_id => job_ids)
    
    redirect_to jobs_path, :notice => "Successful jobs have been cleaned up (total: #{job_ids.count} jobs)"
  end
  
  def reset_failed
    jobs = Job.failed
    jobs.each do |job|
      # Reset data for this job
      job.reset!

      # Push this job onto the queue, and update job's bsid
      bs = Q.new
      bsid = bs.push_job(job, 50)
      job.update_attributes(:bsid => bsid)
    end
    redirect_to jobs_path, :notice => "Failed jobs have been reset (total: #{jobs.count} jobs)"
  end
  
end