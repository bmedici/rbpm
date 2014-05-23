  function cells_from_adjacency(adjacency_list) {

      var elements = [];
      var links = [];

      _.each(adjacency_list, function(edges, parentElementLabel) {
          elements.push(joinjs_make_element(parentElementLabel));

          _.each(edges, function(childElementLabel) {
              links.push(joinjs_make_link(parentElementLabel, childElementLabel));
          });
      });

      // Links must be added after all the elements. This is because when the links
      // are added to the graph, link source/target
      // elements must be in the graph already.
      return elements.concat(links);
  }

  function joinjs_make_link(parentElementLabel, childElementLabel) {
      return new joint.dia.Link({
          source: { id: parentElementLabel },
          target: { id: childElementLabel },
          attrs: {
            '.connection': { stroke: 'blue' },
            //'.marker-source': { fill: 'red', d: 'M 10 0 L 0 5 L 10 10 z' },
            '.marker-target': { fill: 'blue', d: 'M 10 0 L 0 5 L 10 10 z' },
            //'.marker-target': { d: 'M 4 0 L 0 2 L 4 4 z' },
            },
          labels: [
            { position: .5, attrs: { text: { text: 'label' } } }
            ],
          smooth: false
      });
  }

  function joinjs_make_element(label) {

      var maxLineLength = _.max(label.split('\n'), function(l) { return l.length; }).length;

      // Compute width/height of the rectangle based on the number
      // of lines in the label and the letter size. 0.6 * letterSize is
      // an approximation of the monospace font letter width.
      var letterSize = 14;
      // var width = 2 * (letterSize * (0.6 * maxLineLength + 1));
      // var height = 2 * ((label.split('\n').length + 1) * letterSize);
      var width = (letterSize * (0.6 * maxLineLength + 2));
      var height = ((label.split('\n').length + 1) * letterSize);

      return new joint.shapes.basic.Rect({
          id: label,
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
              stroke: '#555',
              fill: '#888'
              }

          }
      });
  }
