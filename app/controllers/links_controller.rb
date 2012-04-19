class LinksController < ApplicationController
  before_filter :options_for_steps, :only => [:new, :edit, :index, :update, :create]

  def index
    @links = Link.includes(:next, :step => :params).order('id DESC', :step_id, :next_id)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @links }
    end
  end

  def show
    @link = Link.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @link }
    end
  end

  def new
    @link = Link.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @link }
    end
  end

  def edit
    @link = Link.includes(:step).find(params[:id])
    link_base_step = @link.step

    # Prepare graph
    graph = GraphMap.new
    graph.prepare(false)
    
    # Highlight the current step and recurse around base step
    graph.highlight_link(@link)
    graph.map_recurse_around(link_base_step.id, 2)

    # Generate output to the browser
    @image_data = graph.output_to_string(:png)
    @image_map = graph.output_to_string(:cmapx)
  end

  def create
    @link = Link.new(params[:link])

    respond_to do |format|
      if @link.save
        format.html { redirect_to links_url, :notice => 'Link was successfully created.' }
        format.json { render :json => @link, :status => :created, :location => @link }
      else
        format.html { render :action => "new" }
        format.json { render :json => @link.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @link = Link.find(params[:id])

    respond_to do |format|
      if @link.update_attributes(params[:link])
        #format.html { render :action => "edit" }
        format.html { redirect_to edit_link_url(@link), :notice => 'Link was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @link.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @link = Link.find(params[:id])
    @link.destroy

    respond_to do |format|
      format.html { redirect_to links_url }
      format.json { head :ok }
    end
  end

private

  def options_for_steps
    #@steps = Step.find(:all, :order =>  'label ASC').collect {|j| [ "#{j.label} (#{j.id})", j.id ] }
    @steps = Step.find(:all, :order =>  'id ASC').collect {|j| [ "s#{j.id} - #{j.label}", j.id ] }
  end

end
