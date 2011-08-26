require 'graphviz'

class GraphController < ApplicationController
  
  
  def workflow
    #render :text => GraphViz::Constants::FORMATS.to_yaml
    #return
    
    g = GraphViz::new("G")

    main        = g.add_node( Time.to_s )
    parse       = g.add_node( "parse" )
    execute     = g.add_node( "execute" )
    init        = g.add_node( "init" )
    cleanup     = g.add_node( "cleanup" )
    make_string = g.add_node( "make_string" )
    printf      = g.add_node( "printf" )
    compare     = g.add_node( "compare" )

    g.add_edge( main, parse )
    g.add_edge( parse, execute )
    g.add_edge( main, init )
    g.add_edge( main, cleanup )
    g.add_edge( execute, make_string )
    g.add_edge( execute, printf )
    g.add_edge( init, make_string )
    g.add_edge( main, printf )
    g.add_edge( execute, compare )
    
    #data = g.output(:png => :nil)
    data = g.to_s
    
    # Generate output to temp file
    tempfile = Tempfile::open( File.basename(__FILE__) )
    g.output( :png => tempfile.path )
    
    # Send the generated file
    send_file(tempfile.path ,
                :filename      =>  tempfile.path,
                :type          =>  'image/png',
                :disposition  =>  'inline')
    #render :text => tempfile.path
    
    # And finally, remove it
    File.unlink(tempfile.path)
    return
    #send_data data, :type => "image/png", :disposition => "inline"
  end

end
