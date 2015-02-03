noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai' unless chai
  module = require '../components/ColorSensor.coffee'
else
  module = require 'noflo-legoev3/components/ColorSensor.js'

describe 'ColorSensor component', ->
  c = null
  ins = null
  beforeEach ->
    c = module.getComponent()
    ins = noflo.internalSocket.createSocket()
    c.inPorts.mode.attach ins

  describe 'when instantiated', ->
    it 'should have an input port', ->
      chai.expect(c.inPorts.kick).to.be.an 'object'
    it 'should have an input port', ->
      chai.expect(c.inPorts.port).to.be.an 'object'
    it 'should have an input port', ->
      chai.expect(c.inPorts.mode).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.value).to.be.an 'object'

