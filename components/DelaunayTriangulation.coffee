noflo = require 'noflo'
Delaunay = require '../vendor/delaunay.js'

exports.getComponent = ->
  c = new noflo.Component
  c.icon = 'cog'
  c.description = 'Calculates de Delaunay triangulation of given points'
  
  c.x = []
  c.y = []

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

  c.outPorts.add 'x',
    datatype: 'array'

  c.outPorts.add 'y',
    datatype: 'array'

  c.compute = ->    
    return unless c.outPorts.x.isAttached() and c.outPorts.y.isAttached()
    return unless c.x? and c.y?

    vertices = [[c.x[i], c.y[i]] for i in [0...c.x.length]][0]

    ids = Delaunay.triangulate vertices

    x = [vertices[i][0] for i in ids][0]
    y = [vertices[i][1] for i in ids][0]
    
    c.outPorts.x.send x
    c.outPorts.y.send y

  c
