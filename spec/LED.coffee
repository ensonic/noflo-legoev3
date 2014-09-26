noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai' unless chai
  module = require '../components/LED.coffee'
else
  module = require 'noflo-legoev3/components/LED.js'

describe 'LED component', ->
  c = null
  ins = null

  beforeEach ->
    c = module.getComponent()
    ins = noflo.internalSocket.createSocket()
    c.inPorts.port.attach ins

  describe 'when instantiated', ->
    it 'should have an input port', ->
      chai.expect(c.inPorts.color).to.be.an 'object'
    it 'should have an input port', ->
      chai.expect(c.inPorts.port).to.be.an 'object'

  describe 'when port changes', ->
    it 'updates base', ->
      ins.send 'right'
      chai.expect(c.r_base).to.be.equal '/sys/class/leds/ev3:red:right/'

