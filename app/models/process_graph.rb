#require 'graphviz'
class ProcessGraph

  def initialize
    #@step_skip = []
    @step_attributes = {}
    @link_attributes = {}
    @step_history = []
    @link_history = []

    @nodes = {}
    @edges = {}
    @id = 1000
  end

  def get_nodes
    @nodes
  end

  def get_edges
    @edges
  end

  def node_add_class(id, name)
    @nodes[id] ||= {}
    @nodes[id][:class] ||= ''
    @nodes[id][:class] += " #{name}"
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

  def map_recurse_forward(step_id)
    return self.map_recurse(step_id.to_i, false, nil)
  end

  def map_recurse_around(step_id, radius)
    return self.map_recurse(step_id.to_i, true, radius)
  end

  def map_whole_database
    # Read and inject all steps
    Step.all.map do |step|
      self.add_step(step)
    end

    # Read and inject all steps
    Link.all.map do |link|
      self.add_link(link, link.step_id, link.next_id)
    end
  end

protected

  def add_link link, step1_id, step2_id, debug = ''
    # Default values
    # pen_width = 1
    # border_color = COLOR_DEFAULT
    # link_color = link.color
    # pen_width = link.penwidth

    # Skip partial links
    return if step1_id.nil? || step2_id.nil?

    # Build labels
    label = []
    label << "k#{link.id.to_s} #{link.label.to_s}"
    label << link.type.to_s

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
    attrs = {
      id: link.id.to_s,
      label: label.join("\n"),
      class: "link #{link.type}",
      :color => link_color,
      :penwidth => pen_width,
      :URL => href,
      from: step1_id.to_s,
      to: step2_id.to_s,
      }
    @edges[link.id] = attrs

    # Add it to the history and return
    #@link_history[link.id] = link_node
    #return link_node
  end

  def add_step step, depth = ''
    # Default values
    pen_width = 1
    border_color = COLOR_DEFAULT
    step_color = step.color

    # Build labels
    label = []
    label << "s#{step.id.to_s} #{step.label.to_s} [#{depth.to_s}]"
    label << step.type.to_s

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

    # Add step
    attrs = {
      id: step.id.to_s,
      class: "step #{step.class.to_s.underscore}",
      label: label.join("\n"),
      :color => border_color,
      :fillcolor => step_color,
      :penwidth => pen_width,
      :shape => shape,
      :URL => href,
      }
    @nodes[step.id] = attrs

    # Add it to the history and return
    #@step_history[step.id] = step_node
    return step.id
    #return step_node
  end

  def map_recurse(step_id, go_backward = false, depth = nil)
    # Do nothing with this iteration if step already in the cache
    #return @nodes[step_id] unless @nodes[step_id].nil?
    return step_id unless @nodes[step_id].nil?

    # Read this step
    step = Step.includes(:links, :ancestors).find(step_id)
    #step = self.find_step(step_id)

    # Render current step
    current_step_node = self.add_step(step, depth)

    # If we reached depth, stop recursing into links
    unless depth.nil?
      depth -=1
      return current_step_node if depth < 0
    end

    # Do the same job for every NEXT link
    step.links.each do |link|
      # Skip if this link is weird and pointing nowhere OR if the pointed step has already been explored
      #edge_id = link.next_id
      next if link.next_id.nil?

      # If I'm a LinkFork link, just recurse one step more (force depth = 0)
      depth = 0 if link.type == 'LinkFork'

      # Browse the next step, only if not already in the cache
      node = self.map_recurse(link.next_id, go_backward, depth)

      # Link it to the current one
      # if @link_history[link.id].nil? and !node.nil?
      self.add_link(link, current_step_node, node, "step.links.each (#{link.to_json})")
      # end
    end

    # Return now if we don't have to go backward
    return current_step_node unless go_backward

    # Do the same job for every ANCESTOR link
    step.ancestor_links.each do |link|
      # Skip if this link is weird and pointing nowhere, or has already been parsed
      #edge_id = link.step_id
      next if link.step_id.nil?

      # If I'm a LinkFork link, just recurse one step more (force depth = 0)
      depth = 0 if link.type == 'LinkFork'

      # Browse the ancestor step, only if not linked through
      node = self.map_recurse(link.step_id, go_backward, depth)
      #node = "ancestor"

      # Handle the ancestor step and link it to the current one
      # Do nothing with this iteration if step already in the cache
      # if @link_history[link.id].nil? and !node.nil?
        self.add_link(link, node, current_step_node, "step.ancestor_links.each (#{link.to_json})")
      # end
    end

    # Return current node
    return current_step_node
  end

end
