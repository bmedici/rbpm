require 'graphviz'
class GraphMap
  
  def initialize
    #@step_skip = []
    @step_attributes = {}
    @step_history = []
  end
  
  def prepare(with_timestamp = false)
    # Build new graph
    @g = GraphViz::new("G", :rankdir => "LR", :margin => "0,0", :path => GRAPHVIZ_BINPATH, :splines => "lines")
    
    # set global node options
    #@g.node[:color]    = "#ddaa66"
    #@g.graph[:ratio]    = 1
    #@g.graph[:size]    = '3x5'
    
    @g.node[:color]    = "#AAAAAA"
    @g.node[:style]    = "filled"
    @g.node[:shape]    = "box"
    @g.node[:penwidth] = "0.75"
    @g.node[:fontname] = "Trebuchet MS"
    @g.node[:fontsize] = "8.5"
    @g.node[:fillcolor]= "#ffeecc"
    @g.node[:fontcolor]= "#775500"
    @g.node[:margin]   = "0.05"

    # set global edge options
    @g.edge[:color]    = "#BBBBBB"
    @g.edge[:weight]   = "1"
    @g.edge[:fontsize] = "8"
    @g.edge[:fontcolor]= "#999999"
    @g.edge[:fontname] = "Verdana"
    @g.edge[:decorate]      = false
    @g.edge[:dir]      = "forward"
    @g.edge[:arrowsize]= "0.75"    
    
    # Timestamp
    @g.add_node(Time.now.to_s(:db), :shape => :plaintext, :fillcolor => '#FFFFFF') if (with_timestamp)
  end
  
  def tag_with_job_status(job)
    # Find all run actions associated to this run
    all_job_actions_sorted_by_id = job.actions.order('id ASC')
    
    # Browse actions and sort by status
    # FIXME: the latest action on a specific step overrides the data for the same previous instance of this step
    all_job_actions_sorted_by_id.each do |action|
      if action.errno.to_i >0
        border_color = COLOR_FAILED
      elsif action.completed_at.nil?
        border_color = COLOR_RUNNING
      else
        border_color = COLOR_COMPLETED
      end

      # Set attributes for thiss step
      self.step_attributes(action.step_id, {
        :border_color => border_color,
        :errno => action.errno,
        })
    end
  end
    
  def tag_with_step(step)
    self.step_attributes(step.id, {
      :border_color => COLOR_CURRENT,
      })
  end
  
  def output_to_file(format, target)
    @g.output( format => target )
  end
  
  def output_to_string(format)
    #return @g.output( :png => nil )
    Rails.logger.info @g.output( :imap => String)
    return @g.output( format => String).html_safe
  end
  
  def step_attributes(step_id, data)
    @step_attributes[step_id] = data
  end
  
  def render
    # Generate output to temp file
    tempfile = Tempfile::open( File.basename(__FILE__) )
    @g.output( :svg => tempfile.path )
    #@g.output( :png => tempfile.path )
    
    # Send the generated file
    send_file(tempfile.path ,
                :filename      =>  tempfile.path,
                #:type          =>  'image/png',
                :type          =>  'image/svg+xml',
                :disposition  =>  'inline')
    
    # And finally, remove it
    File.unlink(tempfile.path)
  end

  def map_recurse_forward(step_id)
    return self.map_recurse(step_id.to_i, false, nil)
  end
  
  def map_recurse_around(step_id, radius)
    return self.map_recurse(step_id.to_i, true, radius)
  end
  
  protected

  def map_add_link(link, from, to)
    # Add a link between the current step and the newly created step
    label1 = "k#{link.id.to_s} #{link.type.to_s}"
    label2 = link.label.to_s
    return @g.add_edge(from, to, :label => "#{label1}\n#{label2}", :color => link.color, :penwidth => link.penwidth)
  end

  def map_add_step(step)
    # Default values
    pen_width = 1
    border_color = COLOR_DEFAULT
    step_color = step.color

    # Build labels
    label = []
    label << "s#{step.id.to_s} #{step.type.to_s}"
    label << step.label.to_s
    
    # Tweak node is attributes given
    attributes = @step_attributes[step.id]
    if (attributes.is_a? Hash) && !(attributes.empty?)
      # If any attribute, double border
      pen_width = 2
      
      # Border color
      border_color = attributes[:border_color] unless attributes[:border_color].nil?
      
      # Any errors ?
      #href = @step_attributes[step.id][:href]
      label << "ERROR  #{attributes[:errno]}" unless attributes[:errno].to_i.zero?
      
      # If stealth, thin border and no color
      # TODO
      #step_color = "#FFFFFF"
      #pen_width = 1
    end
    
    # Generate HREF for this step
    href = Rails.application.routes.url_helpers.step_path(step)
  
    # Add a new node to the graph
    shape = step.shape unless step.shape.nil?
    step_node = @g.add_node(label.join("\n"), :color => border_color, :fillcolor => step_color, :penwidth => pen_width, :shape => shape, :URL => href )
    
    # Add it to the history
    @step_history[step.id] = step_node
    return step_node
  end
    
  def map_recurse(step_id, go_backward = false, depth = nil)
    # Do nothing with this iteration if link already in the cache
    Rails.logger.info "STEP ID: #{step_id}"
    Rails.logger.info "STEP CLASS: #{step_id.class.to_s}"
    return nil unless @step_history[step_id].nil?

    # Read this step
    step = Step.includes(:links, :ancestors).find(step_id)

    # Render current step
    current_step_node = self.map_add_step(step)

    # If we reached depth, stop recursing into links
    unless depth.nil?
      depth -=1
      return current_step_node if depth < 0
    end
    
    # Do the same job for every NEXT link
    step.links.each do |link|
      # Skip if this link is weird and pointing nowhere OR if the pointed step has already been explored
      edge_id = link.next_id
      next if edge_id.nil?

      # If I'm a LinkFork link, don't recurse further (force depth = 1)
      depth = 0 if link.type == 'LinkFork'

      # Browse the next step, only if not already in the cache
      node = self.map_recurse(edge_id, go_backward, depth)
      
      # Link it to the current one
      self.map_add_link(link, current_step_node, node) unless node.nil?
    end
    
    # Return now if we don't have to go backward
    return current_step_node unless go_backward
    
    # Do the same job for every ANCESTOR link
    step.ancestor_links.each do |link|
      # Skip if this link is weird and pointing nowhere, or has already been parsed
      edge_id = link.step_id
      next if edge_id.nil?

      # If I'm a LinkFork link, don't recurse further (force depth = 1)
      depth = 0 if link.type == 'LinkFork'
      
      # Browse the ancestor step, only if not already in the cache
      node = self.map_recurse(edge_id, go_backward, depth)

      # Handle the ancestor step and link it to the current one
      self.map_add_link(link, node, current_step_node) unless node.nil?
    end
    
    # Return current node
    return current_step_node
  end
  
end