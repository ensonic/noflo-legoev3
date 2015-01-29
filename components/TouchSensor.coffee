fs = require 'fs'
noflo = require 'noflo'

# @runtime noflo-nodejs
# http://www.ev3dev.org/docs/sensors/lego-ev3-touch-sensor/
# https://github.com/ev3dev/ev3dev/wiki/Using-the-Mindstorms-Sensor-Device-Class

LOG_PREFIX = 'legoev3/TouchSensor:'
ENC = { encoding: 'utf8' }

class TouchSensor extends noflo.Component
  description: 'Detect touch events.'
  icon: 'power-off'

  constructor: ->
    #console.log "#{LOG_PREFIX} creating new component"

    @last_value = null
    @in_read_file = false
    @base = null
    @updateBase 1

    @inPorts = new noflo.InPorts
      kick:
        datatype: 'bang'
        description: 'Probe the sensor'
      port:
        datatype: 'int'
        values: [1,2,3,4]
        description: 'Sensor port'

    @outPorts = new noflo.OutPorts
      value:
        datatype: 'boolean'
        description: 'Sends true, if touch sensor pressed'

    @inPorts.kick.on 'data', =>
      return if @in_read_file or @base is null
      @in_read_file = true
      new_value = parseInt (fs.readFileSync @base + '/value0', ENC)
      # Only send messages on change
      if new_value isnt @last_value
        @last_value = new_value
        @outPorts.value.send (new_value is 1)
      @in_read_file = false

    @inPorts.port.on 'data', (data) =>
      @updateBase data

    #console.log "#{LOG_PREFIX} created new component"

  updateBase: (port) ->
    try
      files = fs.readdirSync '/sys/class/msensor/'
      files = (file for file in files when file.slice(0, 6) isnt 'sensor')
      wanted = 'in' + port
      for file in files
        port_name = fs.readFileSync file + '/port_name', ENC
        if port_name is wanted
          type_id = fs.readFileSync file + '/type_id', ENC
          if type_id is "16"
            @base = file
            console.log "#{LOG_PREFIX} new base: #{@base}"
          else
            console.log "#{LOG_PREFIX} wrong sensor type: #{type_id} != 16"
          break
    catch err
      console.log "#{LOG_PREFIX} readdir failed: #{err}"

exports.getComponent = -> new TouchSensor()

