  var letterSize = 12;
  var linkFontSize = 10;

  function cells_from_hash(nodes, edges) {
      var elements = [];

      $.each(nodes, function(index, struct) {
        elements.push(graph_element(struct));
      });

      $.each(edges, function(index, struct) {
        elements.push(graph_link(struct));
      });

      return elements;
    }

  function graph_element(struct) {
      var label = struct.label;

      var maxLineLength = _.max(label.split('\n'), function(l) { return l.length; }).length;
      var width = (letterSize * (0.6 * maxLineLength + 2));
      var height = ((label.split('\n').length + 1) * letterSize);

      return new joint.shapes.basic.Rect({
          id: struct.id,
          size: { width: width, height: height },
          attrs: {
            text: {
              text: label,
              'font-size': letterSize,
              'font-family': 'monospace',
              fill: '#fff'
              },
            rect: {
              width: width,
              height: height,
              rx: 5,
              ry: 5,
              // stroke: '#555',
              // fill: '#888',
              class: struct.class
              }

          }
      });
    }

  function graph_link(struct) {
      var from = struct.from;
      var to = struct.to;
      var label = struct.label;
      // link.set('router', { name: 'manhattan' });
      // link.set('router', { name: 'metro' });
      // link.set('router', { name: 'orthogonal' });
      return new joint.dia.Link({
          source: { id: from },
          target: { id: to },
          attrs: {
            '.connection': { stroke: 'blue' },
            //'.marker-source': { fill: 'red', d: 'M 10 0 L 0 5 L 10 10 z' },
            '.marker-target': { fill: 'blue', d: 'M 10 0 L 0 5 L 10 10 z' },
            //'.marker-target': { d: 'M 4 0 L 0 2 L 4 4 z' },
            },
          labels: [
            { position: .5, attrs: { text: { text: label, 'font-size': linkFontSize } } }
            ],
          smooth: false
      });
  }

  function graph_layout(graph) {
    joint.layout.DirectedGraph.layout(graph, { setLinkVertices: false, rankDir: 'LR', debugLevel: 0, rankSep: 80, edgeSep: 50, nodeSep: 20 });
    }
