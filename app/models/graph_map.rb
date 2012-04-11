require 'graphviz'
class GraphMap
  
  def initialize
    @step_skip = []
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
        :errno => action.errno
        })
    end
  end
  
  def output_to_file(format, target)
    @g.output( format => target )
  end
  
  def output_to_string(format)
    #return @g.output( :png => nil )
    return @g.output( format => String)
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
  
  def map_recurse(step_id)
    # Default values
    pen_width = nil
    border_color = nil
    
    # Read this step
    step = Step.includes(:links).find(step_id)
    label1 = "s#{step.id.to_s} #{step.type.to_s}"
    label2 = step.label.to_s
    
    # Ensure attributes for my step are defined if not set at the object-level
    @step_attributes[step.id] ||= {}
    
    # Add a colored border if status given
    unless @step_attributes[step.id].empty?
      border_color = @step_attributes[step.id][:border_color] ||= COLOR_DEFAULT
      pen_width = 2
      label1 = "s#{step.id.to_s}: err #{@step_attributes[step.id][:errno]}" unless @step_attributes[step.id][:errno].to_i.zero?
    end
  
    # Add a new node to the graph
    fill_color = step.color
    shape = step.shape unless step.shape.nil?
    current_step_node = @g.add_node("#{label1}\n#{label2}", :color => border_color, :fillcolor => fill_color, :penwidth => pen_width, :shape => shape )

    # Return current node and ignore following links if :ignore_links is set
    return current_step_node if @step_skip[step.id]
    
    # Do the same job for every child of this node
    step.links.each do |next_link|
      # Skip if this link is weird and pointing nowhere
      next if next_link.next_id.nil?

      # Skip if this node has already been added
      next if @step_history.include? next_link.id

      # Add this step to the step history
      @step_history << next_link.id
      @step_history.uniq!
      
      # If I'm a LinkFork link, don't recurse further
      if next_link.type == 'LinkFork'
        @step_skip[next_link.next_id] = true
      end

      # Handle the next step
      next_step_node = self.map_recurse(next_link.next_id)

      # Add a link between the current step and the newly created step
      label1 = "k#{next_link.id.to_s} #{next_link.type.to_s}"
      label2 = next_link.label.to_s
      label = "#{label1}\n#{label2}"
      link_color = next_link.color
      penwidth = next_link.penwidth
      @g.add_edge(current_step_node, next_step_node, :label => "#{label1}\n#{label2}", :color => link_color, :penwidth => penwidth)
    end
    
    # Return current node
    return current_step_node
  end

  
end