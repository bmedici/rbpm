class GraphController < ApplicationController
  
  @step_attributes
  @step_history

  def initialize
    @step_attributes = {}
    @step_history = []
    @step_skip = []
  end
  
  def map
    # Prepare graph
    graph = GraphMap.new
    graph.prepare(false)

    # Recurse
    graph.map_recurse(params[:id])

    # Generate output to the browser
    image_data = graph.output_to_string(:svg)
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
    send_data(image_data,
      #:type          =>  'image/png',
      :type          =>  'image/svg+xml',
      :disposition  =>  'inline')
  end

  def job
    # Fin the current run
    job = Job.find(params[:id])

    # Prepare graph
    graph = GraphMap.new
    graph.prepare(true)

    # Initialize with job information
    graph.tag_with_job_status(job)

    # Recurse
    graph.map_recurse(job.step_id)

    # Generate output to the browser
    image_data = graph.output_to_string(:svg)
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
    send_data(image_data, 
      #:type          =>  'image/png',
      :type          =>  'image/svg+xml',
      :disposition  =>  'inline')
  end

  protected

end