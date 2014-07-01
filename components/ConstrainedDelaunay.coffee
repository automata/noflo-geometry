noflo = require 'noflo'
poly2tri = require '../vendor/poly2tri.min.js'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'toggle-up'
  c.description = 'Calculates de constrained Delaunay triangulation of given points'
  
  c.x = null
  c.y = null

  c.inPorts.add 'x',
    datatype: 'array'
    process: (event, x) ->
      return unless event is 'data'
      c.x = x
      c.compute()

  c.inPorts.add 'y',
    datatype: 'array'
    process: (event, y) ->
      return unless event is 'data'
      c.y = y
      c.compute()

  c.outPorts.add 'paths',
    datatype: 'array'

  c.compute = ->
    return unless c.outPorts.paths.isAttached()
    return unless c.x? and c.y? and c.x.length > 2

    try
      contour = (new poly2tri.Point(c.x[i], c.y[i]) for i in [0...c.x.length])
      swctx = new poly2tri.SweepContext contour
      swctx.triangulate()
    catch error
      console.log 'ConstrainedDelaunay error:', error
      return

    # TODO Add holes and Steiner points: https://github.com/r3mi/poly2tri.js
    
    triangles = swctx.getTriangles()

    paths = []
    for t in triangles
      points = t.getPoints()
      path =
        type: 'path',
        items: ({'type': 'point', 'x': p.x, 'y': p.y} for p in points)
      paths.push path
    
    c.outPorts.paths.send paths

  c