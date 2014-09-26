noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai' unless chai
  module = require '../components/Buttons.coffee'
else
  module = require 'noflo-legoev3/components/Buttons.js'

describe 'Buttons component', ->
  c = null
  kick = null
  button = null

  beforeEach ->
    c = module.getComponent()
    kick = noflo.internalSocket.createSocket()
    c.inPorts.kick.attach kick
    button = noflo.internalSocket.createSocket()
    c.outPorts.button.attach button

  describe 'when instantiated', ->
    it 'should have an input port', ->
      chai.expect(c.inPorts.kick).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.button).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.value).to.be.an 'object'

  describe 'when kicked', ->
    it 'connects the output ports', ->
      kick.send true
      kick.disconnect()
      chai.expect(c.outPorts.button.isConnected()).to.be.true

