

class WorkersController < ApplicationController
  # GET /workers
  # GET /workers.json
  def index
    bs = Q.new
    @workers_list = bs.list_workers
    bs.close

    respond_to do |format|
      format.html # index.html.erb
      format.json {
        render :json => @workers_list
        }
      
    end
  end

  def spawn
    # Application basedir
    app_dir = File.expand_path(File.join(File.dirname(__FILE__), '..'))

    # Daemon options
    daemon_options = {
      :app_name => 'RBPM-euh',
      :dir_mode   => :normal,
      :dir        => File.join(app_dir, 'tmp', 'pids'),
      :backtrace  => true,
      :monitor  => true,
      :ontop => false 
    }

    # Start daemon processes
    spawed_app = Daemons.call(daemon_options) do
  
      # Initialize Rails default logger
      #pid = Process.pid
      logfile_rails = File.join('/tmp/', 'rails.log')
      Rails.logger = ActiveSupport::BufferedLogger.new(logfile_rails)
      #Rails.logger.info "PID [#{pid}]: starting new worker process"

      # loop do 
      #   Rails.logger.info "inside!"
      #   sleep(2)
      # end
      sleep(30)

    end

    # Prepare response
    render :text => spawed_app.to_json
    #render :json => spawed_app.to_json
  end

  # GET /workers/1
  # GET /workers/1.json
  def show
    @worker = Worker.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @worker }
    end
  end

  # GET /workers/new
  # GET /workers/new.json
  def new
    @worker = Worker.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @worker }
    end
  end

  # GET /workers/1/edit
  def edit
    @worker = Worker.find(params[:id])
  end

  # POST /workers
  # POST /workers.json
  def create
    @worker = Worker.new(params[:worker])

    respond_to do |format|
      if @worker.save
        format.html { redirect_to @worker, :notice => 'Worker was successfully created.' }
        format.json { render :json => @worker, :status => :created, :location => @worker }
      else
        format.html { render :action => "new" }
        format.json { render :json => @worker.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /workers/1
  # PUT /workers/1.json
  def update
    @worker = Worker.find(params[:id])

    respond_to do |format|
      if @worker.update_attributes(params[:worker])
        format.html { redirect_to @worker, :notice => 'Worker was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @worker.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /workers/1
  # DELETE /workers/1.json
  def destroy
    @worker = Worker.find(params[:id])
    @worker.destroy

    respond_to do |format|
      format.html { redirect_to workers_url }
      format.json { head :ok }
    end
  end
end
