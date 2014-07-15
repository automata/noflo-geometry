noflo = require 'noflo'
Voronoi = require '../vendor/rhill-voronoi-core.js'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'location-arrow'
  c.description = 'Calculates Voronoi cells of given points'
  
  c.x = null
  c.y = null
  c.w = 200
  c.h = 200

  c.inPorts.add 'x',
    datatype: 'array',
    process: (event, data) ->
      return unless event is 'data'
      c.x = data
      c.compute()

  c.inPorts.add 'y',
    datatype: 'array'
    process: (event, data) ->
      return unless event is 'data'
      c.y = data
      c.compute()

  c.inPorts.add 'w',
    datatype: 'number'
    description: 'max width (optional)'
    process: (event, data) ->
      return unless event is 'data'
      c.w = data
      c.compute()

  c.inPorts.add 'h',
    datatype: 'number'
    description: 'max height (optional)'
    process: (event, data) ->
      return unless event is 'data'
      c.h = data
      c.compute()

  c.outPorts.add 'paths',
    datatype: 'array'

  c.compute = ->
    return unless c.outPorts.paths.isAttached()
    return unless c.x? and c.y? and c.x.length > 2

    sites = ({x: c.x[i], y: c.y[i]} for i in [0...c.x.length])
    bbox = {xl:0, xr:c.w, yt:0, yb:c.h}

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
