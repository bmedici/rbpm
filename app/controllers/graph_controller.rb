require 'graphviz'
COLOR_COMPLETED = '#44BB44'
COLOR_FAILED = '#FF0000'
COLOR_RUNNING = '#ff7000'
COLOR_DEFAULT = '#BBBBBB'

class GraphController < ApplicationController

  def map
    # Graph all this
    g = map_prepare    
    self.map_sub_graph_recurse(g, params[:id], nil)

    # And send it back to the browser
    map_render(g)
  end

  def run
    # Fin the current run
    run = Run.find(params[:id])
    
    all_run_actions_sorted_by_id = run.actions.order('id ASC')
    
    # Browse actions and sort by status
    # FIXME: the latest action on a specific step overrides the data for the same previous instance of this step
    step_attributes = []
    all_run_actions_sorted_by_id.each do |action|
      if action.retcode.to_i >0
        border_color = COLOR_FAILED
      elsif action.completed_at.nil?
        border_color = COLOR_RUNNING
      else
        border_color = COLOR_COMPLETED
      end
      step_attributes[action.step_id] = {
        :border_color => border_color,
        :retcode => action.retcode
        }
    end
    
    # Graph all this
    g = map_prepare    
    self.map_sub_graph_recurse(g, run.start_step_id, step_attributes)

    # And send it back to the browser
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
    map_render(g)
  end

protected
  
  def map_graph_all(step_attributes = nil)
  #   # Build new graph
  #   g = GraphViz::new("G", :rankdir => "LR", :margin => "0,0", :path => GRAPHVIZ_BINPATH)
  #   
  #   # set global node options
  #   #g.node[:color]    = "#ddaa66"
  #   g.node[:color]    = "#AAAAAA"
  #   g.node[:style]    = "filled"
  #   g.node[:shape]    = "box"
  #   g.node[:penwidth] = "1"
  #   g.node[:fontname] = "Trebuchet MS"
  #   g.node[:fontsize] = "9"
  #   g.node[:fillcolor]= "#ffeecc"
  #   g.node[:fontcolor]= "#775500"
  #   g.node[:margin]   = "0.1"
  # 
  #   # set global edge options
  #   g.edge[:color]    = "#BBBBBB"
  #   g.edge[:weight]   = "1"
  #   g.edge[:fontsize] = "8"
  #   g.edge[:fontcolor]= "#999999"
  #   g.edge[:fontname] = "Verdana"
  #   g.edge[:dir]      = "forward"
  #   g.edge[:arrowsize]= "0.8"    
  #   
  #   # Timestamp
  #   g.add_node(Time.now.to_s)
  #   
  #   # Transpose all steps as nodes
  #   step_node = []
  #   Step.all.each do |step|
  #     # Default values
  #     pen_width = nil
  #     border_color = nil
  #     label1 = "s#{step.id.to_s}"
  #     label2 = step.label.to_s
  #     
  #     # Add a colored border if status given
  #     unless step_attributes.nil?
  #       attributes = step_attributes[step.id]
  #       unless attributes.nil?
  #         border_color = attributes[:border_color] ||= COLOR_DEFAULT
  #         pen_width = 2
  #         label1 = "s#{step.id.to_s}: err #{attributes[:retcode]}" unless attributes[:retcode].to_i.zero?
  #       end
  #     end
  #     
  #     # Get fill color from object class
  #     fill_color = step.color
  #     shape = step.shape unless step.shape.nil?
  #     
  #     # Add a new node to the graph
  #     label = "#{label1}\n#{label2}"
  #     step_node[step.id] = g.add_node(label, :color => border_color, :fillcolor => fill_color, :penwidth => pen_width, :shape => shape )
  #     #:shape => :box
  #   end
  #   
  #   # Transpose all links as edges
  #   Link.all.each do |link|
  #     node_origin = step_node[link.step_id]
  #     node_target = step_node[link.next_id]
  #     g.add_edge(node_origin, node_target, :label => link.label.to_s)
  #   end
  # 
  #   # Fetch all links with corresponding steps
  #   steps = Step.all
  #   
  #   # Generate output to temp file
  #   tempfile = Tempfile::open( File.basename(__FILE__) )
  #   g.output( :png => tempfile.path )
  #   
  #   # Send the generated file
  #   send_file(tempfile.path ,
  #               :filename      =>  tempfile.path,
  #               :type          =>  'image/png',
  #               :disposition  =>  'inline')
  #   
  #   # And finally, remove it
  #   File.unlink(tempfile.path)
  end

  def map_sub_graph_recurse(g, step_id, step_attributes, step_history = [])
    # Default values
    pen_width = nil
    border_color = nil
    step_history ||= []
    
    # Read this step
    step = Step.includes(:links).find(step_id)
    label1 = "s#{step.id.to_s}"
    label2 = step.label.to_s
    
    # Add a colored border if status given
    unless step_attributes.nil?
      attributes = step_attributes[step.id]
      unless attributes.nil?
        border_color = attributes[:border_color] ||= COLOR_DEFAULT
        pen_width = 2
        label1 = "s#{step.id.to_s}: err #{attributes[:retcode]}" unless attributes[:retcode].to_i.zero?
      end
    end
    
    # Add a new node to the graph
    fill_color = step.color
    shape = step.shape unless step.shape.nil?
    label = "#{label1}\n#{label2}"
    current_step_node = g.add_node(label, :color => border_color, :fillcolor => fill_color, :penwidth => pen_width, :shape => shape )
    
    # Do the same job for every child of this node
    step.links.each do |next_link|
      # Skip if this node has already been added
      next if step_history.include? next_link.id

      # Add this step to the step history
      step_history << next_link.id
      step_history.uniq!

      # Handle the next step
      next_step_node = map_sub_graph_recurse(g, next_link.next_id, step_attributes, step_history)

      # Add a link between the current step and the newly created step
      g.add_edge(current_step_node, next_step_node, :label => next_link.label.to_s)
    end
    
    # Return current node
    return current_step_node
  end
  
  def map_prepare
    # Build new graph
    g = GraphViz::new("G", :rankdir => "LR", :margin => "0,0", :path => GRAPHVIZ_BINPATH)
    
    # set global node options
    #g.node[:color]    = "#ddaa66"
    g.node[:color]    = "#AAAAAA"
    g.node[:style]    = "filled"
    g.node[:shape]    = "box"
    g.node[:penwidth] = "1"
    g.node[:fontname] = "Trebuchet MS"
    g.node[:fontsize] = "9"
    g.node[:fillcolor]= "#ffeecc"
    g.node[:fontcolor]= "#775500"
    g.node[:margin]   = "0.1"

    # set global edge options
    g.edge[:color]    = "#BBBBBB"
    g.edge[:weight]   = "1"
    g.edge[:fontsize] = "8"
    g.edge[:fontcolor]= "#999999"
    g.edge[:fontname] = "Verdana"
    g.edge[:dir]      = "forward"
    g.edge[:arrowsize]= "0.8"    
    
    # Timestamp
    g.add_node(Time.now.to_s(:db), :shape => :plaintext, :fillcolor => '#FFFFFF')
    
    return g
  end
  
  def map_render(g)
    # Generate output to temp file
    tempfile = Tempfile::open( File.basename(__FILE__) )
    g.output( :png => tempfile.path )
    
    # Send the generated file
    send_file(tempfile.path ,
                :filename      =>  tempfile.path,
                :type          =>  'image/png',
                :disposition  =>  'inline')
    
    # And finally, remove it
    File.unlink(tempfile.path)
  end

end
