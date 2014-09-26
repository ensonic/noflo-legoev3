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
      chai.expect(c.inPorts.mode).to.be.an 'object'

