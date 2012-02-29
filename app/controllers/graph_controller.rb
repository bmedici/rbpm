require 'graphviz'

class GraphController < ApplicationController

  def map
    self.map_graph(params[:id])
  end

protected
  
  def map_graph(active_step_id = nil)
    #render :text => GraphViz::Constants::FORMATS.to_yaml
    #return
    
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
    
    # Transpose all steps as nodes
    step_node = []
    Step.all.each do |step|
      if (step.id == active_step_id.to_i)
        penwidth = 2
        color = '#444444'
      end
      
      fillcolor = step.color
    
      step_node[step.id] = g.add_node(step.label.to_s, :color => color, :fillcolor => fillcolor, :penwidth => penwidth )
      #:shape => :box
    end
    
    # Transpose all links as edges
    Link.all.each do |link|
      node_origin = step_node[link.step_id]
      node_target = step_node[link.next_id]
      g.add_edge(node_origin, node_target, :label => link.label.to_s)
    end


    # Fetch all links with corresponding steps
    steps = Step.all
    
    # Debug dot file
    #render :text => "<xmp>" +  g.to_s + "</cmp>" and return
    
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
