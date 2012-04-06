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
    @link = Link.find(params[:id])
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
        format.html { render :action => "edit" }
        #format.html { redirect_to links_url, :notice => 'Link was successfully updated.' }
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
