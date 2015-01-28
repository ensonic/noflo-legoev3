fs = require 'fs'
noflo = require 'noflo'

# @runtime noflo-nodejs
# https://www.kernel.org/doc/Documentation/input/input.txt

LOG_PREFIX = 'legoev3/Buttons:'

class Buttons extends noflo.Component
  description: 'Detect button events.'
  icon: 'power-off'

  constructor: ->
    #console.log "#{LOG_PREFIX} creating new component"

    @fd = null
    @base = '/dev/input/by-path/platform-gpio-keys.0-event'

    @buttons =
      105:
        name: 'left'
        pressed: undefined
      106:
        name: 'right'
        pressed: undefined
      103:
        name: 'up'
        pressed: undefined
      108:
        name: 'down'
        pressed: undefined
      28:
        name: 'center'
        pressed: undefined
      1:
        name: 'back'
        pressed: undefined

    @inPorts = new noflo.InPorts
      kick:
        datatype: 'bang'
        description: 'Probe the buttons'

    @outPorts = new noflo.OutPorts
      button:
        datatype: 'string'
        description: 'Sends the name of the key'
      value:
        datatype: 'boolean'
        description: 'Sends the true, if the button is pressed'

    @inPorts.kick.on 'data', =>
      @outPorts.button.connect()
      @outPorts.value.connect()
      try
        @fd = fs.openSync @base, 'r'
        return unless @fd
        buf = new Buffer(16)
        fs.read @fd, buf, 0, buf.length, null, @readButtons
      catch err
        console.log "#{LOG_PREFIX} open(#{@base}) failed: #{err}"

    #console.log "#{LOG_PREFIX} created new component"

  decodeButton: (buf) =>
    # EV_KEY=0x1 or EV_SYN=0x0
    return unless buf.readInt16LE(8) is 1
    # the key code
    button = buf.readInt16LE(10)
    return unless button of @buttons
    # value: 0 release, 1 press, 2 repeat
    pressed = buf.readInt32LE(12)
    return if pressed is @buttons[button].pressed
    @buttons[button].pressed = pressed
    @outPorts.button.send @buttons[button].name
    @outPorts.value.send (pressed is 1)

  readButtons: (err, bytesRead, buf) =>
    if err
      console.log "#{LOG_PREFIX} error #{err}"
    else if bytesRead < 16
      console.log "#{LOG_PREFIX} short read: #{bytesRead}"
    else
      @decodeButton buf
    if @fd
      # use null for offset, if we use 0 we get ESPIPE
      fs.read @fd, buf, 0, buf.length, null, @readButtons

  shutdown: ->
    return unless @fd
    fs.closeSync @fd
    @fd = null

exports.getComponent = -> new Buttons()

