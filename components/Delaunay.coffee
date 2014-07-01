noflo = require 'noflo'
Delaunay = require '../vendor/delaunay.js'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'toggle-up'
  c.description = 'Calculates de Delaunay triangulation of given points'
  
  c.x = null
  c.y = null

  c.inPorts.add 'x',
    datatype: 'array'
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

  c.outPorts.add 'paths',
    datatype: 'array'

  c.compute = ->
    return unless c.outPorts.paths.isAttached()
    return unless c.x? and c.y? and c.x.length > 2

    vertices = ([c.x[i], c.y[i]] for i in [0...c.x.length])

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