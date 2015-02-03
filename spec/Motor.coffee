noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai' unless chai
  module = require '../components/Motor.coffee'
else
  module = require 'noflo-legoev3/components/Motor.js'

describe 'Motor component', ->
  c = null
  port = null
  speed = null

  beforeEach ->
    c = module.getComponent()
    port = noflo.internalSocket.createSocket()
    c.inPorts.port.attach port
    speed = noflo.internalSocket.createSocket()
    c.inPorts.speed.attach speed

  describe 'when instantiated', ->
    it 'should have an input port', ->
      chai.expect(c.inPorts.speed).to.be.an 'object'
    it 'should have an input port', ->
      chai.expect(c.inPorts.port).to.be.an 'object'

