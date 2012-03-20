class StepsController < ApplicationController

  def index
    @steps = Step.includes(:links, :nexts, :ancestors).order(:label)
    #@steps = Step..all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @steps }
    end
  end

  def show
    @step = Step.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @step }
    end
  end

  def new
    @step = Step.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @step }
    end
  end

  def edit
    @step = Step.includes(:params).find(params[:id])
  end

  def create
    @step = Step.new(params[:step])

    respond_to do |format|
      if @step.save
        format.html { redirect_to steps_path, :notice => 'Step was successfully created.' }
        format.json { render :json => @step, :status => :created, :location => @step }
      else
        format.html { render :action => "new" }
        format.json { render :json => @step.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @step = Step.find(params[:id])
    #@step.becomes(Step)

    respond_to do |format|
      if @step.update_attributes(params[:step])
        #format.html { render :action => "edit" }
        format.html { render :action => "edit" }
        #format.html { redirect_to edit_step_path(@step), :notice => 'Step was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @step.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @step = Step.find(params[:id])
    @step.destroy

    respond_to do |format|
      format.html { redirect_to steps_url }
      format.json { head :ok }
    end
  end
end
