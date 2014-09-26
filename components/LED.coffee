fs = require 'fs'
noflo = require 'noflo'

# @runtime noflo-nodejs
# https://github.com/ev3dev/ev3dev/wiki/Using-the-LEDs
# https://github.com/ev3dev/ev3dev/wiki/EV3-LEDs

# TODO(ensonic): support trigger=timer to make it blink

class LED extends noflo.Component
  description: 'Control LED'
  icon: 'lightbulb-o'

  constructor: ->
    @updateBase 'left'

    @inPorts = new noflo.InPorts
      color:
        datatype: 'color'
        values: ['#000000', '#ff0000', '#ffff00', '#00ff00']
        description: 'LED color'
      port:
        datatype: 'string'
        values: ['left', 'right']
        description: 'LED port'
        
    @inPorts.color.on 'data', (data) =>
      r_val = parseInt(data.substr(1,2),16)
      g_val = parseInt(data.substr(3,2),16)
      fs.writeFile @r_base + 'trigger', 'none'
      fs.writeFile @r_base + 'brightness', if (r_val == 255) then 1 else 0
      fs.writeFile @g_base + 'trigger', 'none'
      fs.writeFile @g_base + 'brightness', if (g_val == 255) then 1 else 0

    @inPorts.port.on 'data', (data) =>
      @updateBase data

  updateBase: (port) ->
    @r_base = '/sys/class/leds/ev3:red:' + port + '/'
    @g_base = '/sys/class/leds/ev3:green:' + port + '/'
 
exports.getComponent = -> new LED

