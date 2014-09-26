noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai' unless chai
  module = require '../components/Beep.coffee'
else
  module = require 'noflo-legoev3/components/Beep.js'

describe 'Beep component', ->
  c = null
  ins = null
  beforeEach ->
    c = module.getComponent()
    ins = noflo.internalSocket.createSocket()
    c.inPorts.frequency.attach ins

  describe 'when instantiated', ->
    it 'should have an input port', ->
      chai.expect(c.inPorts.frequency).to.be.an 'object'
    it 'should have an input port', ->
      chai.expect(c.inPorts.volume).to.be.an 'object'

