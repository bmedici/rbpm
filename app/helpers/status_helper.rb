require 'base64'
module StatusHelper
  
  def job_status_image(job)
    # Prepare graph
    graph = GraphMap.new
    graph.prepare(true)

    # Initialize with job information
    graph.tag_with_job_status(job)
    
    # Last action registered
    last_action = job.actions.order('id DESC').first
    return if last_action.nil?
    last_step_id = last_action.step_id
    return if last_step_id.nil?
    
    graph.map_recurse_around(last_step_id, 2)

    # Generate output
    image_data = graph.output_to_string(:png)
    
    # And then, link!
    return tag :img, :src => inline_image_src("image/png", image_data)
  end
  
  # def step_context(step)
  #   # Prepare graph
  #   graph = GraphMap.new
  #   graph.prepare(true)
  # 
  #   # Initialize with job information
  #   graph.tag_with_job_status(job)
  # 
  #   # Recurse
  #   graph.map_recurse(job.step_id)
  # 
  #   # Generate output
  #   image_data = graph.output_to_string(:png)
  #   
  #   # And then, link!
  #   return  tag :img, :src => inline_image_src("image/png", image_data), :width => 450
  # end

  def inline_image_src(content_type, data)
    #base64_data = escape_javascript(Base64.encode64(data))
    base64_data = Base64.encode64(data)
    return "data:#{content_type};base64,#{base64_data}"
  end
  
end