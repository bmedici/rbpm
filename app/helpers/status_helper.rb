require 'base64'
module StatusHelper
  
  def job_status_image(job)
    # Prepare graph
    graph = GraphMap.new
    graph.prepare(true)

    # Initialize with job information
    graph.tag_with_job_status(job)

    # Recurse
    graph.map_recurse(job.step_id)

    # Generate output
    image_data = graph.output_to_string(:png)
    
    # And then, link!
    return  tag :img, :src => inline_image_src("image/png", image_data), :width => 450
  end
  

  def inline_image_src(content_type, data)
    #base64_data = escape_javascript(Base64.encode64(data))
    base64_data = Base64.encode64(data)
    return "data:#{content_type};base64,#{base64_data}"
  end
  
end