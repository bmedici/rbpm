class SystemsController < ApplicationController
  # GET /systems
  # GET /systems.json
  def index
    @systems = System.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @systems }
    end
  end

  # GET /systems/1
  # GET /systems/1.json
  def show
    @system = System.find(params[:id])
    
    respond_to do |format|
      
      # When building plain HTML, just use the cached status
      format.html {
        @status = @system.status
        }
      
      # When building an ajax response, update the status before sending any reply
      format.json {
        status = @system.update_status!
        
        # Chekc if we really got a valid reply
        if status.empty?
          render :json => @system.errors, :status => :unprocessable_entity and return 
        end
        
        # Format the reply
        lines= []
        
        lines << @system.status['cpu_type'].to_s unless @system.status['cpu_type'].blank?

        details = []
        details << "up #{@system.status['uptime']}" unless @system.status['uptime'].blank?
        details << "#{@system.status['ipaddress']}" unless @system.status['ipaddress'].blank?
        lines << details.join(', ')

        details = []
        details << "#{@system.status['cpu_count']} CPUs" unless @system.status['cpu_count'].blank?
        details << "load #{@system.status['loadavg'].round(2)}" unless @system.status['loadavg'].blank?
        lines << details.join(', ')

        if status = @system.update_status!
          render :json => {
            :percent => @system.extract_load_percent(status),
            :details => lines.join("<br>"),
            :timestamp => status['timestamp']
            }
        end
        }
    end
  end

  # GET /systems/new
  # GET /systems/new.json
  def new
    @system = System.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @system }
    end
  end

  # GET /systems/1/edit
  def edit
    @system = System.find(params[:id])
  end

  # POST /systems
  # POST /systems.json
  def create
    @system = System.new(params[:system])

    respond_to do |format|
      if @system.save
        format.html { redirect_to @system, :notice => 'System was successfully created.' }
        format.json { render :json => @system, :status => :created, :location => @system }
      else
        format.html { render :action => "new" }
        format.json { render :json => @system.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /systems/1  # PUT /systems/1.json
  def update
    @system = System.find(params[:id])

    respond_to do |format|
      if @system.update_attributes(params[:system])
        format.html { redirect_to @system, :notice => 'System was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @system.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update_status
    @system = System.find(params[:id])
    
    if @system.update_status!
      @system.save!
      redirect_to @system, :notice => 'Status data was successfully updated'
    else
      redirect_to @system, :error => 'Status data was bot updated'
    end
  end

  # DELETE /systems/1
  # DELETE /systems/1.json
  def destroy
    @system = System.find(params[:id])
    @system.destroy

    respond_to do |format|
      format.html { redirect_to systems_url }
      format.json { head :ok }
    end
  end
end
