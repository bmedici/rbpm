class JobsController < ApplicationController
  # GET /jobs
  # GET /jobs.json
  def index
    #@jobs = Job.order('id DESC').includes(:actions)
    @jobs = Job.order('id DESC')

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

  # GET /jobs/new
  # GET /jobs/new.json
  # def new
  #   @job = Job.new
  # 
  #   respond_to do |format|
  #     format.html # new.html.erb
  #     format.json { render :json => @job }
  #   end
  # end

  # GET /jobs/1/edit
  def edit
    @job = Job.find(params[:id])
  end

  # def create
  #   @job = Job.new(params[:job])
  #   @job.creator = "manual.admin"
  # 
  #   respond_to do |format|
  #     if @job.save
  #       format.html { redirect_to @job, :notice => 'Job was successfully created.' }
  #       format.json { render :json => @job, :status => :created, :location => @job }
  #     else
  #       format.html { render :action => "new" }
  #       format.json { render :json => @job.errors, :status => :unprocessable_entity }
  #     end
  #   end
  # end

  def push
    @job = Job.new()
    @job.creator = "manual.push"
    @job.step_id = params[:id]

    respond_to do |format|
      if @job.save

        begin
          @job.push_to_beanstalk("jobs#push")
        rescue Beanstalk::NotConnected
           redirect_to workflows_path, :notice => 'Could not connect to beanstalk server'
           return
        end

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
    @job.destroy

    respond_to do |format|
      format.html { redirect_to jobs_url }
      format.json { head :ok }
    end
  end
  
  def reset
    @job = Job.find(params[:id])
    @job.vars.destroy_all
    @job.actions.destroy_all
    @job.init_vars_from_context!
    @job.update_attributes(:completed_at => nil, :errno => 0, :errmsg => '', :worker => nil)
    
    begin
      @job.push_to_beanstalk("jobs#reset")
    rescue Beanstalk::NotConnected
       redirect_to jobs_path, :notice => 'Could not connect to beanstalk server'
       return
    end
      
    #render :text => 'done'
    redirect_to @job, :notice => 'Job was successfully reset'
  end
  
end
