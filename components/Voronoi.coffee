noflo = require 'noflo'
Voronoi = require '../vendor/rhill-voronoi-core.js'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'location-arrow'
  c.description = 'Calculates Voronoi Diagram for given points'
  
  c.bbox = null
  c.points = null

  c.inPorts.add 'points',
    datatype: 'array'
    process: (event, data) ->
      return unless event is 'data'
      c.points = data
      c.compute()

  c.inPorts.add 'bbox',
    datatype: 'object'
    description: 'bounding box as a rectangle (default: 200x200)'
    process: (event, data) ->
      return unless event is 'data'
      c.bbox = data
      c.compute()

  c.outPorts.add 'paths',
    datatype: 'array'

  c.compute = ->
    return unless c.outPorts.paths.isAttached()
    return unless c.points? and c.points.length > 2
    
    sites = c.points
    if c.bbox?
      bbox = 
        xl: c.bbox.point.x
        xr: c.bbox.width
        yt: c.bbox.point.y
        yb: c.bbox.height
    else
      bbox = {xl: 0, xr: 200, yt: 0, yb: 200}

    voronoi = new Voronoi()
    diagram = voronoi.compute(sites, bbox)

    paths = []
    for cell in diagram.cells
      points = []
      for halfedge in cell.halfedges
        endpoint = halfedge.getEndpoint()
        points.push
          type: 'point'
          x: endpoint.x
          y: endpoint.y
      if points.length > 0
        paths.push
          type: 'path'
          items: points

    c.outPorts.paths.send paths

  c
