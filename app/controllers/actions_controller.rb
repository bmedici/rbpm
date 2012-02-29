class ActionsController < ApplicationController
  # GET /actions
  # GET /actions.json
  def index
    @actions = Action.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @actions }
    end
  end

  # GET /actions/1
  # GET /actions/1.json
  def show
    @action = Action.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @action }
    end
  end

  # GET /actions/new
  # GET /actions/new.json
  def new
    @action = Action.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @action }
    end
  end

  # GET /actions/1/edit
  def edit
    @action = Action.find(params[:id])
  end

  # POST /actions
  # POST /actions.json
  def create
    @action = Action.new(params[:action])

    respond_to do |format|
      if @action.save
        format.html { redirect_to @action, :notice => 'Action was successfully created.' }
        format.json { render :json => @action, :status => :created, :location => @action }
      else
        format.html { render :action => "new" }
        format.json { render :json => @action.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /actions/1
  # PUT /actions/1.json
  def update
    @action = Action.find(params[:id])

    respond_to do |format|
      if @action.update_attributes(params[:action])
        format.html { redirect_to @action, :notice => 'Action was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @action.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /actions/1
  # DELETE /actions/1.json
  def destroy
    @action = Action.find(params[:id])
    @action.destroy

    respond_to do |format|
      format.html { redirect_to actions_url }
      format.json { head :ok }
    end
  end
end
