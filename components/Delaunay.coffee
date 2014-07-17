noflo = require 'noflo'
Delaunay = require '../vendor/delaunay.js'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'toggle-up'
  c.description = 'Calculates Delaunay Triangulation for given points'
  
  c.points = null

  c.inPorts.add 'points',
    datatype: 'array'
    process: (event, data) ->
      return unless event is 'data'
      c.points = data
      c.compute()

  c.outPorts.add 'paths',
    datatype: 'array'

  c.compute = ->
    return unless c.outPorts.paths.isAttached()
    return unless c.points? and c.points.length > 2

    vertices = ([point.x, point.y] for point in c.points)
    console.log c.points, vertices
    ids = Delaunay.triangulate vertices

    v = (vertices[i] for i in ids)

    paths = []
    for i in [0...v.length] by 3
      path =
        type: 'path',
        items: ({'type': 'point', 'x': v[i+j][0], 'y': v[i+j][1]} for j in [0...3])
      paths.push path

    c.outPorts.paths.send paths

  c