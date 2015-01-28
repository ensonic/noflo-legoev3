fs = require 'fs'
noflo = require 'noflo'

# @runtime noflo-nodejs
# https://github.com/ev3dev/ev3dev/wiki/Using-Sensors

LOG_PREFIX = 'legoev3/ColorSensor:'

class ColorSensor extends noflo.Component
  description: 'Detect colors/brightness.'
  icon: 'tint'

  constructor: ->
    #console.log "#{LOG_PREFIX} creating new component"

    @inPorts = new noflo.InPorts
      mode:
        # values: /sys/class/msensor/sensorX/modes
        datatype: 'string'
        description: 'Sensor mode: ambient, reflective, color'

    #console.log "#{LOG_PREFIX} created new component"

exports.getComponent = -> new ColorSensor

