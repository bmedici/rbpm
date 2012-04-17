class StepsController < ApplicationController

  def index
    @steps = Step.includes(:links, :nexts, :ancestors, :params).order('id DESC')
    #@steps = Step..all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @steps }
    end
  end

  def show
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

    # Prepare the local map
    step = Step.find(params[:id])

    # Prepare graph
    graph = GraphMap.new
    graph.prepare(false)
    graph.tag_with_step(step)
    graph.map_recurse_around(step.id, 2)

    # Generate output to the browser
    @image_data = graph.output_to_string(:png)
    @image_map = graph.output_to_string(:cmapx)

  end

  def create
    @step = Step.new(params[:step])

    respond_to do |format|
      if @step.save
        format.html { redirect_to (edit_step_path(@step)), :notice => 'Step was successfully created.' }
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
        format.html { redirect_to (edit_step_path(@step)) }
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
