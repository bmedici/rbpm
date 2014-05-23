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

  def follow
    # Find the step we're working on
    @step = Step.includes(:params).find(params[:id])
    
    # Create a new next-step
    @next_step = @step.nexts.create
    
    redirect_to edit_step_path(@next_step), :notice => 'Step was successfully created.'
  end

  def new
    @step = Step.new
    
    unless params[:start].blank?
      @step.type = StepStart
    end

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @step }
    end
  end

  def edit
    @step = Step.includes(:params).find(params[:id])

    # Initialize missing params is not present
    @step.init_missing_params!

    # Prepare graph
    graph = ProcessGraph.new

    # Highlight the current step and recurse around it
    graph.map_recurse_around(@step.id, 2)

    # Mark current node active
    graph.node_add_class(@step.id, 'active')

    # @graph_nodes[@step.id] ||= {}
    # @graph_nodes[@step.id][:style] ||= ""
    # @graph_nodes[@step.id][:style] << " active"

    # @graph_nodes = graph.get_nodes
    # @graph_edges = graph.get_edges
    @graph_nodes = graph.get_nodes.values
    @graph_edges = graph.get_edges.values

  end

  def update
    @step = Step.find(params[:id])
    #@step.becomes(Step)

    respond_to do |format|
      if @step.update_attributes(params[:step])
        #format.html { render :action => "edit" }
        format.html { redirect_to edit_step_path(@step) }
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
    if @step.destroy
      flash[:success] = 'Step was successfully deleted'
      redirect_to :action => "index"
    else
      flash[:error]= 'Failed to delete step'
      redirect_to edit_step_path(@step)
    end
  end
end
