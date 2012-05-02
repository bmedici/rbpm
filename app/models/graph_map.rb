require 'graphviz'
class GraphMap
  
  def initialize
    #@step_skip = []
    @step_attributes = {}
    @link_attributes = {}
    @step_history = []
    @link_history = []
    
    @steps = []
    @links = []
    
  end
  
  def prepare(with_timestamp = false)
    # Build new graph
    @g = GraphViz::new("G", :rankdir => "LR", :margin => "0,0", :path => GRAPHVIZ_BINPATH, :splines => "lines")
    
    # set global node options
    #@g.node[:color]    = "#ddaa66"
    @g.graph[:bgcolor]    = 'transparent'
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

  # def prefetch!
  #   Link.all.each do |thing|
  #     @links[thing.id] = thing
  #   end
  #   Step.includes(:links).all.each do |thing|
  #     @steps[thing.id] = thing
  #   end
  # end
  # def find_step(id)
  #   @steps[id]
  # end
  # def find_link(id)
  #   @links[id]
  # end
  
  
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
  
  def step_attributes(id, data)
    @step_attributes[id] = data
  end
  
  def link_attributes(id, data)
    @link_attributes[id] = data
  end
    
  def highlight_step(step)
    self.step_attributes(step.id, {
      :border_color => COLOR_CURRENT,
      :pen_width => 3,
      })
  end
  
  def highlight_link(link)
    self.link_attributes(link.id, {
      :border_color => COLOR_CURRENT,
      :pen_width => 3,
      })
  end
  
  def output_to_file(format, target)
    @g.output( format => target )
  end
  
  def output_to_string(format)
    #return @g.output( :png => nil )
    return @g.output( format => String).html_safe
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
    # Default values
    pen_width = 1
    border_color = COLOR_DEFAULT
    link_color = link.color
    pen_width = link.penwidth

    # Build labels
    label = []
    label << "k#{link.id.to_s} #{link.type.to_s}"
    label << link.label.to_s

    # Use object is attributes given
    attributes = @link_attributes[link.id]
    if (attributes.is_a? Hash) && !(attributes.empty?)
      # Pen width ?
      pen_width = attributes[:pen_width] unless attributes[:pen_width].nil?
      
      # Border color ?
      link_color = attributes[:border_color] unless attributes[:border_color].nil?
      
      # Any errors to draw ?
      label << "ERROR  #{attributes[:errno]}" unless attributes[:errno].to_i.zero?
    end
    
    # Generate HREF for this step
    href = Rails.application.routes.url_helpers.edit_link_path(link)
  
    # Add a link between the current step and the newly created step
    link_node =  @g.add_edge(from, to, :label => label.join("\n"), :color => link_color, :penwidth => pen_width, :URL => href)

    # Add it to the history and return
    @link_history[link.id] = link_node
    return link_node
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
    
    # Use object is attributes given
    attributes = @step_attributes[step.id]
    if (attributes.is_a? Hash) && !(attributes.empty?)
      # Pen width ?
      pen_width = attributes[:pen_width] unless attributes[:pen_width].nil?
      
      # Border color ?
      border_color = attributes[:border_color] unless attributes[:border_color].nil?
      
      # Any errors to draw ?
      label << "ERROR  #{attributes[:errno]}" unless attributes[:errno].to_i.zero?
    end
    
    # Generate HREF for this step
    href = Rails.application.routes.url_helpers.edit_step_path(step)
  
    # Add a new node to the graph
    shape = step.shape unless step.shape.nil?
    step_node = @g.add_node(label.join("\n"), :color => border_color, :fillcolor => step_color, :penwidth => pen_width, :shape => shape, :URL => href )
    
    # Add it to the history and return
    @step_history[step.id] = step_node
    return step_node
  end
    
  def map_recurse(step_id, go_backward = false, depth = nil)
    # Do nothing with this iteration if step already in the cache
    return @step_history[step_id] unless @step_history[step_id].nil?

    # Read this step
    step = Step.includes(:links, :ancestors).find(step_id)
    #step = self.find_step(step_id)

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

      # If I'm a LinkFork link, just recurse one step more (force depth = 0)
      depth = 0 if link.type == 'LinkFork'

      # Browse the next step, only if not already in the cache
      node = self.map_recurse(edge_id, go_backward, depth)
      
      # Link it to the current one
      if @link_history[link.id].nil? and !node.nil?
        self.map_add_link(link, current_step_node, node)
      end
    end
    
    # Return now if we don't have to go backward
    return current_step_node unless go_backward
    
    # Do the same job for every ANCESTOR link
    step.ancestor_links.each do |link|
      # Skip if this link is weird and pointing nowhere, or has already been parsed
      edge_id = link.step_id
      next if edge_id.nil?

      # If I'm a LinkFork link, just recurse one step more (force depth = 0)
      depth = 0 if link.type == 'LinkFork'
      
      # Browse the ancestor step, only if not linked through
      node = self.map_recurse(edge_id, go_backward, depth)

      # Handle the ancestor step and link it to the current one
      # Do nothing with this iteration if step already in the cache
      if @link_history[link.id].nil? and !node.nil?
        self.map_add_link(link, node, current_step_node)
      end
    end
    
    # Return current node
    return current_step_node
  end
  
end